# == Class: openvpn::deploy::service
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
#  include openvpn::deploy::service
#
# === Authors
#
# Phil Bayfield https://bitbucket.org/Philio/
#

class openvpn::deploy::service {

  service { 'openvpn':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true;
  }

}
