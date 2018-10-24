# == Class: openvpn::deploy::prepare
#
# Base profile
#
# === Parameters
#
# [*etc_directory*]
#   String. Path of the configuration directory.
#   Default: /etc
#
# === Variables
#
# None
#
# === Examples
#
#  include openvpn::deploy::prepare
#
# === Authors
#
# Phil Bayfield https://bitbucket.org/Philio/
#

class openvpn::deploy::prepare(
  Stdlib::Absolutepath $etc_directory
) {

  class { 'openvpn::deploy::install': }
  ~> class { 'openvpn::deploy::service': }

}
