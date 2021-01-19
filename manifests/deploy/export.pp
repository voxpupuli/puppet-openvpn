#
# @summary Prepare all Openvpn-Client-Configs to be exported
#
# @param server which Openvpn::Server[$server] does the config belong to?
# @param tls_auth should the ta* files be exported too?
#
# @example
#  openvpn::deploy::export { 'test-client':
#    server => 'test_server',
#  }
#
define openvpn::deploy::export (
  String $server,
  Boolean $tls_auth = false,
) {
  Openvpn::Server[$server]
  -> Openvpn::Client[$name]
  -> Openvpn::Deploy::Export[$name]

  if fact("openvpn.${server}.${name}") {
    $data = $facts['openvpn'][$server][$name]

    @@file { "exported-${server}-${name}-config":
      ensure  => file,
      path    => "${openvpn::etc_directory}/openvpn/${name}.conf",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $data['conf'],
      tag     => "${server}-${name}",
    }

    @@file { "exported-${server}-${name}-ca":
      ensure  => file,
      path    => "${openvpn::etc_directory}/openvpn/keys/${name}/ca.crt",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $data['ca'],
      tag     => "${server}-${name}",
    }

    @@file { "exported-${server}-${name}-crt":
      ensure  => file,
      path    => "${openvpn::etc_directory}/openvpn/keys/${name}/${name}.crt",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $data['crt'],
      tag     => "${server}-${name}",
    }

    @@file { "exported-${server}-${name}-key":
      ensure  => file,
      path    => "${openvpn::etc_directory}/openvpn/keys/${name}/${name}.key",
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $data['key'],
      tag     => "${server}-${name}",
    }

    if $tls_auth {
      @@file { "exported-${server}-${name}-ta":
        ensure  => file,
        path    => "${openvpn::etc_directory}/openvpn/keys/${name}/ta.key",
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        content => $data['ta'],
        tag     => "${server}-${name}",
      }
    }
  }
}
