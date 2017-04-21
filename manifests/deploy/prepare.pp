# == Class: openvpn::deploy::prepare
#
# Base profile
#
# === Parameters
#
# None
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

class openvpn::deploy::prepare {

  class { 'openvpn::params': }

  class { 'openvpn::deploy::install': }
  ~> class { 'openvpn::deploy::service': }

}
