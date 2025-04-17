#
# @summary This module installs the openvpn service, configures vpn endpoints, generates client certificates, and generates client config files
#
class openvpn::install {
  include openvpn

  stdlib::ensure_packages(['openvpn'])
  if $openvpn::additional_packages {
    stdlib::ensure_packages($openvpn::additional_packages)
  }

  file {
    ["${openvpn::etc_directory}/openvpn", "${openvpn::etc_directory}/openvpn/keys", '/var/log/openvpn',]:
      ensure  => directory,
      require => Package['openvpn'];
  }
}
