# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include nomad::run_service
class nomad::run_service {

}

define resource::run_service {
  if $nomad::manage_service == true and $nomad::install_method != 'docker' {
    service { 'nomad':
      ensure    => $nomad::service_ensure,
      name      => $nomad::service_name,
      enable    => $nomad::service_enable,
      provider  => $nomad::init_style,
    }
  }
}
