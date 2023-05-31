#
# @summary This define creates client certs for a specified server as well as a tarball that can be directly imported into clients
#
# @param server Name of the corresponding openvpn endpoint
# @param compression Which compression algorithm to use. This parameter is deprecated in OpenVPN 2.5.
# @param dev Device method
# @param mute Set log mute level
# @param mute_replay_warnings Silence duplicate packet warnings (common on wireless networks)
# @param nobind Whether or not to bind to a specific port number
# @param persist_key Try to retain access to resources that may be unavailable because of privilege downgrades
# @param persist_tun Try to retain access to resources that may be unavailable because of privilege downgrades
# @param port The port the openvpn server service is running on
# @param proto What IP protocol is being used.
# @param remote_host  The IP or hostname of the openvpn server service.
# @param cipher Cipher to use for packet encryption
# @param tls_cipher TLS Ciphers to use
# @param data_ciphers Ciphers to allow for packet encryption
# @param data_ciphers_fallback Cipher to use if peer cipher config cannot be determined
# @param resolv_retry  How many seconds should the openvpn client try to resolve the server's hostname
# @param auth_retry Controls how OpenVPN responds to username/password verification errors such as the client-side response to an AUTH_FAILED message from the server or verification failure of the private key password.
# @param verb Level of logging verbosity
# @param pam DEPRECATED: Boolean, Enable/Disable.
# @param authuserpass Set if username and password required
# @param tls_auth Activates tls-auth to Add an additional layer of HMAC authentication on top of the TLS control channel to protect against DoS attacks. This has to be set to the same value as on the Server
# @param tls_crypt Encrypt and authenticate all control channel packets with the key from keyfile. (See --tls-auth for more background.)
# @param x509_name Common name of openvpn server to make an x509-name verification
# @param setenv Set a custom environmental variable name=value to pass to script.
# @param setenv_safe  Set a custom environmental variable OPENVPN_name=value to pass to script. This directive is designed to be pushed by the server to clients, and the prepending of "OPENVPN_" to the environmental variable is a safety precaution to prevent a LD_PRELOAD style attack from a malicious or compromised server.
# @param up Script which we want to run when openvpn client is connecting
# @param down Script which we want to run when openvpn client is disconneting
# @param sndbuf  Set the TCP/UDP socket send buffer size.
# @param rcvbuf  Set the TCP/UDP socket receive buffer size.
# @param shared_ca The name of an openssl::ca resource to use.
# @param custom_options Hash of additional options that you want to append to the configuration file.
# @param expire Set a custom expiry time to pass to script. Value is the number of days the certificate is valid for.
# @param readme Text to place in a README file which is included in download-configs archive.
# @param pull Allow server to push options like dns or routes
# @param server_extca_enabled Turn this on if you are using an external CA solution, like FreeIPA. Use this in Combination with exported_ressourced, since they don't have Access to the Serverconfig
# @param remote_cert_tls Enable or disable use of remote-cert-tls used with client configuration
#
# @example
#   openvpn::client {
#     'my_user':
#       server      => 'contractors',
#       remote_host => 'vpn.mycompany.com'
#    }
#
define openvpn::client (
  String $server,
  Optional[String[1]] $compression                     = undef,
  Enum['tap', 'tun'] $dev                              = 'tun',
  Integer $mute                                        = 20,
  Boolean $mute_replay_warnings                        = true,
  Boolean $nobind                                      = true,
  Boolean $persist_key                                 = true,
  Boolean $persist_tun                                 = true,
  String $port                                         = '1194',
  Enum['tcp','udp'] $proto                             = 'tcp',
  Variant[String, Array[String]] $remote_host          = $facts['networking']['fqdn'],
  String $resolv_retry                                 = 'infinite',
  Enum['none', 'nointeract', 'interact'] $auth_retry   = 'none',
  String $verb                                         = '3',
  Boolean $pam                                         = false,
  String $cipher                                       = 'AES-256-GCM',
  String $tls_cipher                                   = 'TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256',
  String $data_ciphers                                 = 'AES-256-GCM:AES-128-GCM',
  String $data_ciphers_fallback                        = undef,
  Boolean $authuserpass                                = false,
  Hash $setenv                                         = {},
  Hash $setenv_safe                                    = {},
  Optional[String[1]] $up                              = undef,
  Optional[String[1]] $down                            = undef,
  Boolean $tls_auth                                    = false,
  Boolean $tls_crypt                                   = false,
  Optional[String] $x509_name                          = undef,
  Optional[Integer] $sndbuf                            = undef,
  Optional[Integer] $rcvbuf                            = undef,
  Optional[String] $shared_ca                          = undef,
  Hash $custom_options                                 = {},
  Optional[Integer] $expire                            = undef,
  Optional[String] $readme                             = undef,
  Boolean $pull                                        = false,
  Boolean $server_extca_enabled                        = false,
  Boolean $remote_cert_tls                             = true,
) {
  if $pam {
    warning('Using $pam is deprecated. Use $authuserpass instead!')
  }

  Openvpn::Server[$server]
  -> Openvpn::Client[$name]

  $extca_enabled = pick(getparam(Openvpn::Server[$server], 'extca_enabled'), $server_extca_enabled)
  if $extca_enabled { fail('cannot currently create client configs when corresponding openvpn::server is extca_enabled') }
  if $tls_auth and $tls_crypt { fail('tls_auth and tls_crypt are mutually exclusive') }

  $ca_name = pick($shared_ca, $server)
  Openvpn::Ca[$ca_name]
  -> Openvpn::Client[$name]

  $server_directory = $openvpn::server_directory

  if $expire {
    if is_integer($expire) {
      case $openvpn::easyrsa_version {
        '2.0': {
          $env_expire = "KEY_EXPIRE=${expire}"
        }
        '3.0': {
          $env_expire = "EASYRSA_CERT_EXPIRE=${expire} EASYRSA_NO_VARS=1"
        }
        default: {
          fail("unexepected value for EasyRSA version, got '${openvpn::easyrsa_version}', expect 2.0 or 3.0.")
        }
      }
    } else {
      warning("Custom expiry time ignored: only integer is accepted but ${expire} is given.")
    }
  } else {
    $env_expire = ''
  }

  case $openvpn::easyrsa_version {
    '2.0': {
      exec { "generate certificate for ${name} in context of ${ca_name}":
        command  => ". ./vars && ${env_expire} ./pkitool ${name}",
        cwd      => "${server_directory}/${ca_name}/easy-rsa",
        creates  => "${server_directory}/${ca_name}/easy-rsa/keys/${name}.crt",
        provider => 'shell';
      }

      file { "${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.crt":
        ensure  => link,
        target  => "${server_directory}/${ca_name}/easy-rsa/keys/${name}.crt",
        require => Exec["generate certificate for ${name} in context of ${ca_name}"],
      }

      file { "${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.key":
        ensure  => link,
        target  => "${server_directory}/${ca_name}/easy-rsa/keys/${name}.key",
        require => Exec["generate certificate for ${name} in context of ${ca_name}"],
      }
    }
    '3.0': {
      exec { "generate certificate for ${name} in context of ${ca_name}":
        command  => ". ./vars && ${env_expire} ./easyrsa --batch build-client-full ${name} nopass",
        cwd      => "${server_directory}/${ca_name}/easy-rsa",
        creates  => "${server_directory}/${ca_name}/easy-rsa/keys/issued/${name}.crt",
        provider => 'shell';
      }

      file { "${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.crt":
        ensure  => link,
        target  => "${server_directory}/${ca_name}/easy-rsa/keys/issued/${name}.crt",
        require => Exec["generate certificate for ${name} in context of ${ca_name}"],
      }

      file { "${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.key":
        ensure  => link,
        target  => "${server_directory}/${ca_name}/easy-rsa/keys/private/${name}.key",
        require => Exec["generate certificate for ${name} in context of ${ca_name}"],
      }
    }
    default: {
      fail("unexepected value for EasyRSA version, got '${openvpn::easyrsa_version}', expect 2.0 or 3.0.")
    }
  }

  file {
    [
      "${server_directory}/${server}/download-configs/${name}",
      "${server_directory}/${server}/download-configs/${name}/keys",
      "${server_directory}/${server}/download-configs/${name}/keys/${name}",
    ]:
      ensure => directory,
  }

  file { "${server_directory}/${server}/download-configs/${name}/keys/${name}/ca.crt":
    ensure  => link,
    target  => "${server_directory}/${ca_name}/easy-rsa/keys/ca.crt",
    require => Exec["generate certificate for ${name} in context of ${ca_name}"],
  }

  if $tls_auth or $tls_crypt {
    file { "${server_directory}/${server}/download-configs/${name}/keys/${name}/ta.key":
      ensure  => link,
      target  => "${server_directory}/${server}/easy-rsa/keys/ta.key",
      require => Exec["generate certificate for ${name} in context of ${server}"],
      before  => [
        Exec["tar the thing ${server} with ${name}"],
        Concat["${server_directory}/${server}/download-configs/${name}.ovpn"],
      ],
      notify  => Exec["tar the thing ${server} with ${name}"],
    }
  }

  if $readme {
    file { "${server_directory}/${server}/download-configs/${name}/README":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0444',
      content => $readme,
      notify  => Exec["tar the thing ${server} with ${name}"];
    }
  }

  file {
    "${server_directory}/${server}/download-configs/${name}.tblk":
      ensure => directory;

    "${server_directory}/${server}/download-configs/${name}.tblk/${name}.ovpn":
      ensure  => link,
      target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
      require => [
        Concat["${server_directory}/${server}/download-configs/${name}.ovpn"],
        File["${server_directory}/${server}/download-configs/${name}.tblk"],
      ],
      before  => Exec["tar the thing ${server} with ${name}"];
  }

  file { "${server_directory}/${server}/download-configs/${name}/${name}.conf":
    owner   => root,
    group   => 0,
    mode    => '0444',
    content => template('openvpn/client.erb', 'openvpn/client_external_auth.erb'),
  }

  exec { "tar the thing ${server} with ${name}":
    cwd         => "${server_directory}/${server}/download-configs/",
    command     => "/bin/rm ${name}.tar.gz; tar --exclude=\\*.conf.d -chzvf ${name}.tar.gz ${name} ${name}.tblk",
    refreshonly => true,
    require     => [
      File["${server_directory}/${server}/download-configs/${name}/${name}.conf"],
      File["${server_directory}/${server}/download-configs/${name}/keys/${name}/ca.crt"],
      File["${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.key"],
      File["${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.crt"],
      Concat["${server_directory}/${server}/download-configs/${name}.ovpn"],
      File["${server_directory}/${server}/download-configs/${name}.tblk"],
      File["${server_directory}/${server}/download-configs/${name}.tblk/${name}.ovpn"],
    ],
  }

  file { "${server_directory}/${server}/download-configs/${name}.tar.gz":
    ensure  => file,
    replace => 'no',
    require => Exec["tar the thing ${server} with ${name}"],
  }

  concat { "${server_directory}/${server}/download-configs/${name}.ovpn":
    mode    => '0400',
    notify  => Exec["tar the thing ${server} with ${name}"],
    require => [
      File["${server_directory}/${server}/download-configs/${name}/keys/${name}/ca.crt"],
      File["${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.key"],
      File["${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.crt"],
    ],
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/client_config":
    target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
    content => template('openvpn/client.erb'),
    order   => '01',
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/ca_open_tag":
    target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
    content => "# Authentication \n<ca>\n",
    order   => '02',
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/ca":
    target => "${server_directory}/${server}/download-configs/${name}.ovpn",
    source => "${server_directory}/${server}/download-configs/${name}/keys/${name}/ca.crt",
    order  => '03',
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/ca_close_tag":
    target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
    content => "</ca>\n",
    order   => '04',
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/key_open_tag":
    target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
    content => "<key>\n",
    order   => '05',
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/key":
    target => "${server_directory}/${server}/download-configs/${name}.ovpn",
    source => "${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.key",
    order  => '06',
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/key_close_tag":
    target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
    content => "</key>\n",
    order   => '07',
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/cert_open_tag":
    target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
    content => "<cert>\n",
    order   => '08',
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/cert":
    target => "${server_directory}/${server}/download-configs/${name}.ovpn",
    source => "${server_directory}/${server}/download-configs/${name}/keys/${name}/${name}.crt",
    order  => '09',
  }

  concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/cert_close_tag":
    target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
    content => "</cert>\n",
    order   => '10',
  }

  if $tls_auth {
    concat::fragment { "/etc/openvpn/${server}/download-configs/${name}.ovpn/tls_auth_open_tag":
      target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
      content => "<tls-auth>\n",
      order   => '11',
    }

    concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/tls_auth":
      target => "${server_directory}/${server}/download-configs/${name}.ovpn",
      source => "${server_directory}/${server}/download-configs/${name}/keys/${name}/ta.key",
      order  => '12',
    }

    concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/tls_auth_close_tag":
      target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
      content => "</tls-auth>\nkey-direction 1\n",
      order   => '13',
    }
  }
  elsif $tls_crypt {
    concat::fragment { "/etc/openvpn/${server}/download-configs/${name}.ovpn/tls_crypt_open_tag":
      target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
      content => "<tls-crypt>\n",
      order   => '11',
    }

    concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/tls_crypt":
      target => "${server_directory}/${server}/download-configs/${name}.ovpn",
      source => "${server_directory}/${server}/download-configs/${name}/keys/${name}/ta.key",
      order  => '12',
    }

    concat::fragment { "${server_directory}/${server}/download-configs/${name}.ovpn/tls_crypt_close_tag":
      target  => "${server_directory}/${server}/download-configs/${name}.ovpn",
      content => "</tls-crypt>\n",
      order   => '13',
    }
  }
}
