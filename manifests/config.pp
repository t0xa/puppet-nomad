# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nomad::config
class nomad::config (
  Hash    $config_hash       = $nomad::config_hash_real,
  Boolean $purge             = $nomad::purge_config_dir,
  Boolean $restart_on_change = $nomad::restart_on_change,
) {

  case $nomad::init_style {
    'systemd': {
      systemd::unit_file { 'nomad.service':
        content => template('nomad/nomad.systemd.erb'),
        notify  => Service['nomad'],
      }
    }
    default: {
      fail("I don't know how to create an init script for style ${nomad::init_style}")
    }
  }

  file { $nomad::config_dir:
    ensure  => 'directory',
    owner   => $nomad::user,
    group   => $nomad::user,
    purge   => $purge,
    recurse => $purge,
  }

  if $nomad::server == true {
    $nomad_config = lookup('nomad::server::config', Data, 'deep', {})
  } else {
    $nomad_config = lookup('nomad::client::config', Data, 'deep', {})
  }

  file { "${nomad::config_dir}/${nomad::config_file}":
    ensure  => present,
    path    => "${nomad::config_dir}/${nomad::config_file}",
    owner   => $nomad::user,
    group   => $nomad::group,
    mode    => $nomad::config_mode,
    content => to_json_pretty($nomad_config),
    notify  => Service['nomad'],
  }

}
