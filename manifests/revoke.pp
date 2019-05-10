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

  $etc_directory = $openvpn::etc_directory

  case $openvpn::easyrsa_version {
    '3.0': {
      exec { "revoke certificate for ${name} in context of ${server}":
        command  => ". ./vars && ./easyrsa --batch revoke ${name}; echo \"exit $?\" | grep -qE '(error 23|exit (0|2|))' && touch revoked/${name}",
        cwd      => "${etc_directory}/openvpn/${server}/easy-rsa",
        creates  => "${etc_directory}/openvpn/${server}/easy-rsa/revoked/${name}",
        provider => 'shell',
      }
      # `easyrsa gen-crl` does not work, since it will create the crl.pem
      # to keys/crl.pem which is a symlinked to crl.pem in the servers etc
      # directory
      exec { "renew crl.pem for ${name}":
        command  => ". ./vars && EASYRSA_REQ_CN='' EASYRSA_REQ_OU='' openssl ca -gencrl -out ../crl.pem -config ./openssl.cnf",
        cwd      => "${openvpn::etc_directory}/openvpn/${server}/easy-rsa",
        provider => 'shell',
      }
    }
    '2.0': {
      exec { "revoke certificate for ${name} in context of ${server}":
        command  => ". ./vars && ./revoke-full ${name}; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))' && touch revoked/${name}",
        cwd      => "${etc_directory}/openvpn/${server}/easy-rsa",
        creates  => "${etc_directory}/openvpn/${server}/easy-rsa/revoked/${name}",
        provider => 'shell',
      }
    }
    default: {
      fail("unexepected value for EasyRSA version, got '${openvpn::easyrsa_version}', expect 2.0 or 3.0.")
    }
  }
}
