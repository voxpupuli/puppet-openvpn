#
# @summary This define creates a revocation on a certificate for a specified server.
#
# @param server Name of the corresponding openvpn endpoint
# @example
#   openvpn::client {
#     'my_user':
#       server      => 'contractors'
#   }
# @example
#   openvpn::revoke {
#     'my_user':
#       server      => 'contractors'
#    }
#
define openvpn::revoke (
  String $server,
) {

  Openvpn::Server[$server]
  -> Openvpn::Revoke[$name]

  Openvpn::Client[$name]
  -> Openvpn::Revoke[$name]

  $server_directory = $openvpn::server_directory

  $revocation_command = $openvpn::easyrsa_version ? {
    '2.0' => ". ./vars && ./revoke-full ${name}; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))' && touch revoked/${name}",
    '3.0' => ". ./vars && ./easyrsa revoke --batch ${name}; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))' && touch revoked/${name}",
  }

  $renew_command = $openvpn::easyrsa_version ? {
    '2.0'   => ". ./vars && KEY_CN='' KEY_OU='' KEY_NAME='' KEY_ALTNAMES='' openssl ca -gencrl -out ${openvpn::server_directory}/${name}/crl.pem -config ${openvpn::server_directory}/${name}/easy-rsa/openssl.cnf",
    '3.0'   => ". ./vars && EASYRSA_REQ_CN='' EASYRSA_REQ_OU='' openssl ca -gencrl -out ${server_directory}/${name}/crl.pem -config ${server_directory}/${name}/easy-rsa/openssl.cnf",
    default => fail("unexepected value for EasyRSA version, got '${openvpn::easyrsa_version}', expect 2.0 or 3.0."),
  }

  exec { "revoke certificate for ${name} in context of ${server}":
    command  => $revocation_command,
    cwd      => "${server_directory}/${server}/easy-rsa",
    creates  => "${server_directory}/${server}/easy-rsa/revoked/${name}",
    provider => 'shell',
    notify   => Exec["renew crl.pem on ${name}"],
  }

  exec { "renew crl.pem on ${name}":
    command  => $renew_command,
    cwd      => "${openvpn::server_directory}/${name}/easy-rsa",
    provider => 'shell',
    schedule => "renew crl.pem schedule on ${name}",
  }
}
