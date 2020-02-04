class nomad::params {

  case $facts['architecture'] {
    'x86_64', 'x64', 'amd64': { $arch = 'amd64' }
    'i386':                   { $arch = '386'   }
    'aarch64':                { $arch = 'arm64' }
    /^arm.*/:                 { $arch = 'arm'   }
    default:                  {
      fail("Unsupported kernel architecture: ${facts['architecture']}")
    }
  }

  $config_file = "nomad.json"

  $config_dir = $facts['os']['family'] ? {
    'windows' => 'C:\\ProgramData\\nomad\\config',
    default   => '/etc/nomad'
  }

  $bin_dir = $facts['os']['family'] ? {
    'windows' => 'C:\\Pr  ogramData\\nomad',
    default   => '/usr/local/bin'
  }

  case $facts['os']['name'] {
    'windows': {
      $data_dir_mode = '0775'
      $binary_group = undef
      $binary_mode = '0775'
      $binary_name = 'nomad.exe'
      $binary_owner = 'NT AUTHORITY\NETWORK SERVICE'
      $config_defaults  = {
        data_dir => 'C:\\ProgramData\\nomad'
      }
      $manage_user = false
      $manage_group = false
      $user = 'NT AUTHORITY\NETWORK SERVICE'
      $group = 'Administrators'
    }
    default: {
      # 0 instead of root because OS X uses "wheel".
      $data_dir_mode = '0755'
      $binary_group = '0'
      $binary_mode = '0555'
      $binary_name = 'nomad'
      $binary_owner = 'root'
      $config_defaults  = {
        data_dir => '/opt/nomad'
      }
      $manage_user = false
      $manage_group = false
      $user = 'root'
      $group = 'root'
    }
  }

  case $facts['os']['name'] {
    'Ubuntu': {
      $shell = '/usr/sbin/nologin'
    }
    'RedHat': {
      $shell = '/sbin/nologin'
    }
    'Debian': {
      $shell = '/usr/sbin/nologin'
    }
    default: {
      $shell = undef
    }
  }

  if $facts['os']['family'] == 'windows' {
    $init_style = 'unmanaged'
  } else {
    $init_style = $facts['service_provider'] ? {
      undef   => 'systemd',
      default => $facts['service_provider']
    }
  }
}