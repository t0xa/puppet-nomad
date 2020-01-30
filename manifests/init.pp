# == Class: nomad
#
# Installs, configures and manages nomad
#
class nomad (
  String[1]                             $version              = '0.10.2',
  String[1]                             $download_url_base    = 'https://releases.hashicorp.com/nomad/',
  String[1]                             $download_extension   = 'zip',
  Optional[Stdlib::HTTPUrl]             $download_url         = undef,
  Optional[Stdlib::HTTPUrl]             $proxy_server         = undef,
  String[1]                             $arch                 = $nomad::params::arch,
  String[1]                             $package_ensure       = 'latest',
  String[1]                             $package_name         = 'nomad',
  String[1]                             $os                   = $facts['kernel'].downcase,
  String[1]                             $user                 = $nomad::params::user,
  String[1]                             $group                = $nomad::params::group,
  String[1]                             $init_style           = $nomad::params::init_style,
  Hash                                  $config_defaults      = $nomad::params::config_defaults,
  Hash                                  $config_hash          = {},
  Optional[String[1]]                   $extra_options        = undef,
  Boolean                               $service_enable       = true,
  Enum['stopped', 'running']            $service_ensure       = 'running',
  String[1]                             $install_method       = 'url',
  String[1]                             $service_name         = 'nomad',
  Optional[Stdlib::Absolutepath]        $archive_path         = undef,
  Boolean                               $purge_config_dir     = true,
  Boolean                               $restart_on_change    = true,
  String[1]                             $config_mode          = '0664',
  Boolean                               $pretty_config        = false,
  Integer                               $pretty_config_indent = 4,
) inherits nomad::params {

  $real_download_url = pick(
    $download_url,
    "${download_url_base}${version}/${package_name}_${version}_${os}_${arch}.${download_extension}",
  )

  $config_hash_real = deep_merge($config_defaults, $config_hash)

  if $config_hash_real['data_dir'] {
    $data_dir = $config_hash_real['data_dir']
  } else {
    $data_dir = undef
  }

  contain 'nomad::install'
  contain 'nomad::config'
  contain 'nomad::run_service'
  contain 'nomad::reload_service'

  Class['nomad::install']
  -> Class['nomad::config']
  -> Class['nomad::run_service']
}
