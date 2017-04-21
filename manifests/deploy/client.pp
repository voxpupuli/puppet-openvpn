# == Define: openvpn::deploy::client
#
# Collect the exported configs for an Host and ensure a running Openvpn Service
#
# === Parameters
#
# $server   which Openvpn::Server[$server] does the config belong to?
# String
#
# $manage_etc should the /etc/openvpn directory be managed? (warning, all unmanaged files will be purged!)
#
# === Variables
#
# None
#
# === Examples
#
#  openvpn::deploy::client { 'test-client':
#    server => 'test_server',
#  }
#
# === Authors
#
# Phil Bayfield https://bitbucket.org/Philio/
#

define openvpn::deploy::client (
  String $server,
  Boolean $manage_etc = true,
) {

  include openvpn::deploy::prepare

  Class['openvpn::deploy::install']
  -> Openvpn::Deploy::Client[$name]
  ~> Class['openvpn::deploy::service']


  if $manage_etc {
    file { [
      "${::openvpn::params::etc_directory}/openvpn",
      "${::openvpn::params::etc_directory}/openvpn/keys",
      "${::openvpn::params::etc_directory}/openvpn/keys/${name}",
    ]:
      ensure  => directory,
      require => Package['openvpn'];
    }
  } else {
    file { "${::openvpn::params::etc_directory}/openvpn/keys/${name}":
      ensure  => directory,
      require => Package['openvpn'];
    }
  }

  File <<| tag == "${server}-${name}" |>>
  ~> Class['openvpn::deploy::service']

}
