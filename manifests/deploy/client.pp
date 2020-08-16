#
# @summary Collect the exported configs for an Host and ensure a running Openvpn Service
# @param server which Openvpn::Server[$server] does the config belong to?
# @param manage_etc should the /etc/openvpn directory be managed? (warning, all unmanaged files will be purged!)
#
# @example
#  openvpn::deploy::client { 'test-client':
#    server => 'test_server',
#  }
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
        "${openvpn::deploy::prepare::etc_directory}/openvpn",
        "${openvpn::deploy::prepare::etc_directory}/openvpn/keys",
        "${openvpn::deploy::prepare::etc_directory}/openvpn/keys/${name}",
      ]:
        ensure  => directory,
        require => Package['openvpn'];
    }
  } else {
    file { "${openvpn::deploy::prepare::etc_directory}/openvpn/keys/${name}":
      ensure  => directory,
      require => Package['openvpn'];
    }
  }

  File <<| tag == "${server}-${name}" |>>
  ~> Class['openvpn::deploy::service']
}
