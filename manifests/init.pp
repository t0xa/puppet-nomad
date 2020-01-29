# == Class: nomad
#
# Installs, configures and manages nomad
#
class nomad (
  String[1]                             $version            = '0.10.2',
  String[1]                             $download_url_base  = 'https://releases.hashicorp.com/nomad/',
  String[1]                             $download_extension = 'zip',
  Optional[Stdlib::HTTPUrl]             $download_url       = undef,
  Optional[Stdlib::HTTPUrl]             $proxy_server       = undef,
  String[1]                             $arch               = $nomad::params::arch,
  String[1]                             $package_ensure     = 'latest',
  String[1]                             $package_name       = 'nomad',
  String[1]                             $os                 = $facts['kernel'].downcase,
  String[1]                             $user               = $nomad::params::user,
  String[1]                             $group              = $nomad::params::group,
  String[1]                             $init_style         = $nomad::params::init_style,
  Hash                                  $config_defaults    = $nomad::params::config_defaults,
  Hash                                  $config_hash        = {},
) inherits nomad::params {

  $real_download_url = pick(
    $download_url,
    "${download_url_base}${version}/${package_name}_${version}_${os}_${arch}.${download_extension}",
  )

  $user_real = $user
  $group_real = $group
  $init_style_real = $init_style

  $config_hash_real = deep_merge($config_defaults, $config_hash)

  contain 'nomad::install'

  Class['nomad::install']
}
