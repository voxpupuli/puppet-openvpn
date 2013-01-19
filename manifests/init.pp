# == Class: openvpn
#
# This module installs the openvpn service, configures vpn endpoints, generates
# client certificates, and generates client config files
#
#
# === Examples
#
# * Installation:
#     class { 'openvpn': }
#
#
# === Authors
#
# * Raffael Schmid <mailto:raffael@yux.ch>
# * John Kinsella <mailto:jlkinsel@gmail.com>
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class openvpn {

  class {'openvpn::params': } ->
  class {'openvpn::install': } ->
  class {'openvpn::config': } ~>
  class {'openvpn::service': } ->
  Class['openvpn']


}
