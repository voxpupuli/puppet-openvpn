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
    '2.0': {
      exec { "revoke certificate for ${name} in context of ${server}":
        command  => ". ./vars && ./revoke-full ${name}; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))' && touch revoked/${name}",
        cwd      => "${etc_directory}/openvpn/${server}/easy-rsa",
        creates  => "${etc_directory}/openvpn/${server}/easy-rsa/revoked/${name}",
        provider => 'shell',
      }
    }
    '3.0': {
      # if $openvpn::manage_service {
      #   if $facts['service_provider'] == 'systemd' {
      #     $lnotify = Service["openvpn@${name}"]
      #   } elsif $openvpn::namespecific_rclink {
      #     $lnotify = Service["openvpn_${name}"]
      #   } else {
      #     $lnotify = Service['openvpn']
      #     Openvpn::Server[$name] -> Service['openvpn']
      #   }
      # }
      # else {
      #   $lnotify = undef
      # }

      exec { "revoke certificate for ${name} in context of ${server}":
        command  => ". ./vars && echo yes | ./easyrsa revoke ${name} 2>&1 | grep -E 'Already revoked|was successful|not a valid certificate' && ./easyrsa gen-crl && /bin/cp -f keys/crl.pem ../crl.pem && touch revoked/${name}",
        cwd      => "/etc/openvpn/${server}/easy-rsa",
        creates  => "/etc/openvpn/${server}/easy-rsa/revoked/${name}",
        provider => 'shell',
        # notify   => $lnotify,
      }
    }
    default: {
      fail("unexepected value for EasyRSA version, got '${openvpn::easyrsa_version}', expect 2.0 or 3.0.")
    }
  }
}
