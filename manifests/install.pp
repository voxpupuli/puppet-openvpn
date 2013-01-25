# == Class: openvpn
#
# This module installs the openvpn service, configures vpn endpoints, generates
# client certificates, and generates client config files
#
#
# === Examples
#
# This class should not be directly invoked
#
#
# === Authors
#
# * Raffael Schmid <mailto:raffael@yux.ch>
# * John Kinsella <mailto:jlkinsel@gmail.com>
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class openvpn::install {

  package {
    'openvpn':
      ensure => installed;
  }

  file {
    [ '/etc/openvpn', '/etc/openvpn/keys' ]:
      ensure  => directory,
      require => Package['openvpn'];
  }
}