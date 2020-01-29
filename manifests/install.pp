# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nomad::install
class nomad::install {

  $real_data_dir = pick($nomad::data_dir, $nomad::config_hash[data_dir], $nomad::config_defaults[data_dir])

  file { $real_data_dir:
    ensure => 'directory',
    owner  => $nomad::user,
    group  => $nomad::group,
    mode   => $nomad::data_dir_mode,
  }

  if $facts['nomad_version'] != $nomad::version {
    $do_notify_service = Class['nomad::run_service']
  } else {
    $do_notify_service = undef
  }

  case $nomad::install_method {
    'url': {
      $install_path = pick($nomad::archive_path, "${real_data_dir}/archives")

      include archive

      file { [$install_path, "${install_path}/nomad-${nomad::version}"]:
        ensure => directory,
        owner  => $nomad::binary_owner,
        group  => $nomad::binary_group,
        mode   => $nomad::binary_mode,
      }

      archive { "${install_path}/nomad-${nomad::version}.${nomad::download_extension}":
        ensure       => present,
        source       => $nomad::real_download_url,
        proxy_server => $nomad::proxy_server,
        extract      => true,
        extract_path => "${install_path}/nomad-${nomad::version}",
        creates      => "${install_path}/nomad-${nomad::version}/${nomad::binary_name}",
        require      => File["${install_path}/nomad-${nomad::version}"],
      }

      file { "${install_path}/nomad-${nomad::version}/${nomad::binary_name}":
        owner   => $nomad::binary_owner,
        group   => $nomad::binary_group,
        mode    => $nomad::binary_mode,
        require => Archive["${install_path}/nomad-${nomad::version}.${nomad::download_extension}"],
      }

      file { "${nomad::bin_dir}/${nomad::binary_name}":
        ensure  => link,
        notify  => $do_notify_service,
        target  => "${install_path}/nomad-${nomad::version}/${nomad::binary_name}",
        require => File["${install_path}/nomad-${nomad::version}/${nomad::binary_name}"],
      }
    }
  }

}
