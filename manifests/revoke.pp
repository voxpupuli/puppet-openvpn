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

  if versioncmp($openvpn::easyrsa_version, '3') == -1 {
    if versioncmp($openvpn::easyrsa_version, '2') == 1 or versioncmp($openvpn::easyrsa_version, '2') == 0 {
      $revocation_command = ". ./vars && ./revoke-full ${name}; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))'"
    } else {
      fail("unexepected value for EasyRSA version, got '${openvpn::easyrsa_version}', expect between 2.0.0 and 3.x.x")
    }
  } else {
    if versioncmp($openvpn::easyrsa_version, '4') == -1 {
      $revocation_command = ". ./vars && ./easyrsa --batch revoke ${name}; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))'"
    } else {
      fail("unexepected value for EasyRSA version, got '${openvpn::easyrsa_version}', expect between 2.0.0 and 3.x.x")
    }
  }

  if versioncmp($openvpn::easyrsa_version, '3') == -1 {
    if versioncmp($openvpn::easyrsa_version, '2') == 1 or versioncmp($openvpn::easyrsa_version, '2') == 0 {
      $renew_command = ". ./vars && KEY_CN='' KEY_OU='' KEY_NAME='' KEY_ALTNAMES='' openssl ca -gencrl -out ${server_directory}/${server}/crl.pem -config ${server_directory}/${server}/easy-rsa/openssl.cnf"
    } else {
      fail("unexepected value for EasyRSA version, got '${openvpn::easyrsa_version}', expect between 2.0.0 and 3.x.x")
    }
  } else {
    if versioncmp($openvpn::easyrsa_version, '4') == -1 {
      $renew_command = './easyrsa gen-crl'
    } else {
      fail("unexepected value for EasyRSA version, got '${openvpn::easyrsa_version}', expect between 2.0.0 and 3.x.x")
    }
  }

  file { "${server_directory}/${server}/easy-rsa/revoked/${name}":
    ensure  => file,
    require => Exec["revoke certificate for ${name} in context of ${server}"],
  }

  exec { "revoke certificate for ${name} in context of ${server}":
    command  => $revocation_command,
    cwd      => "${server_directory}/${server}/easy-rsa",
    provider => 'shell',
    notify   => Exec["renew crl.pem on ${server} because of revocation of ${name}"],
    creates  => "${server_directory}/${server}/easy-rsa/revoked/${name}",
  }

  exec { "renew crl.pem on ${server} because of revocation of ${name}":
    command     => $renew_command,
    cwd         => "${server_directory}/${server}/easy-rsa",
    provider    => 'shell',
    refreshonly => true,
  }

  if versioncmp($openvpn::easyrsa_version, '4') == -1 and
  (versioncmp($openvpn::easyrsa_version, '3') == 1 or
  versioncmp($openvpn::easyrsa_version, '3') == 0) {
    exec { "copy renewed crl.pem to ${name} keys directory because of revocation of ${name}":
      command     => "cp ${server_directory}/${server}/easy-rsa/keys/crl.pem ${server_directory}/${server}/crl.pem",
      subscribe   => Exec["renew crl.pem on ${server} because of revocation of ${name}"],
      provider    => 'shell',
      refreshonly => true,
    }
  }
}
