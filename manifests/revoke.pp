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

  exec { "revoke certificate for ${name} in context of ${server}":
    command  => ". ./vars && ./revoke-full ${name}; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))' && touch revoked/${name}",
    cwd      => "${etc_directory}/openvpn/${server}/easy-rsa",
    creates  => "${etc_directory}/openvpn/${server}/easy-rsa/revoked/${name}",
    provider => 'shell',
  }
}
