# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nomad::nomad_config
define nomad::nomad_config(
  String                            $setting = $title,
  Variant[String, Integer, Struct]  $value   = '',
  Enum['present', 'absent']         $ensure  = 'present',
) {

  if type($value) == String {
    $line = "${setting} = \"${value}\""
  }

  if type($value) == Integer {
    $line = "${setting} = ${value}"
  }

  if type($value) == Struct  {
    $line = "${setting} = \"${value}\""
  }

  file_line { "nomad-config-${setting}-${path}":
    ensure            => $ensure,
    path              => "${nomad::config_dir}/nomad.hcl",
    line              => $line,
    match             => "^${setting}=",
    match_for_absence => true, # ignored when ensure == 'present'
  }
}
