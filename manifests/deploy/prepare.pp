#
# @summary Base profile
#
# @param etc_directory Path of the configuration directory.
# @example
#   include openvpn::deploy::prepare
#
class openvpn::deploy::prepare (
  Stdlib::Absolutepath $etc_directory
) {
  class { 'openvpn::deploy::install': }
  ~> class { 'openvpn::deploy::service': }
}
