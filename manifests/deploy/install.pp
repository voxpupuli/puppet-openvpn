# == Class: openvpn::deploy::install
#
# Installs the Openvpn profile
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
#  include openvpn::deploy::install
#
# === Authors
#
# Phil Bayfield https://bitbucket.org/Philio/
#

class openvpn::deploy::install {

  ensure_packages(['openvpn'])

}
