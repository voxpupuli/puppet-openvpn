# == Define: openvpn::client
#
# This define creates the client certs for a specified openvpn server as well
# as creating a tarball that can be directly imported into openvpn clients
#
#
# === Parameters
#
# [*server*]
#   String.  Name of the corresponding openvpn endpoint
#   Required
#
# [*compression*]
#   String.  Which compression algorithim to use
#   Default: comp-lzo
#   Options: comp-lzo or '' (disable compression)
#
# [*dev*]
#   String.  Device method
#   Default: tun
#   Options: tun (routed connections), tap (bridged connections)
#
# [*mute*]
#   Integer.  Set log mute level
#   Default: 20
#
# [*mute_replay_warnings*]
#   Boolean.  Silence duplicate packet warnings (common on wireless networks)
#   Default: true
#
# [*nobind*]
#   Boolean.  Whether or not to bind to a specific port number
#   Default: true
#
# [*persist_key*]
#   Boolean.  Try to retain access to resources that may be unavailable
#     because of privilege downgrades
#   Default: true
#
# [*persist_tun*]
#   Boolean.  Try to retain access to resources that may be unavailable
#     because of privilege downgrades
#   Default: true
#
# [*port*]
#   Integer.  The port the openvpn server service is running on
#   Default: 1194
#
# [*proto*]
#   String.  What IP protocol is being used.
#   Default: tcp
#   Options: tcp or udp
#
# [*remote_host*]
#   String.  The IP or hostname of the openvpn server service
#   Default: FQDN
#
# [*cipher*]
#   String,  Cipher to use for packet encryption
#   Default: None
#
# [*resolv_retry*]
#   Integer/String. How many seconds should the openvpn client try to resolve
#     the server's hostname
#   Default: infinite
#   Options: Integer or infinite
#
# [*auth_retry*]
#   String. Controls how OpenVPN responds to username/password verification
#     errors such as the client-side response to an AUTH_FAILED message from
#     the server or verification failure of the private key password.
#   Default: none
#   Options: 'none' or 'nointeract' or 'interact'
#
# [*verb*]
#   Integer.  Level of logging verbosity
#   Default: 3
#
# [*pam*]
#   DEPRECATED: Boolean, Enable/Disable.
#
# [*authuserpass*]
#   Boolean. Set if username and password required
#   Default: false
#
# [*tls_auth*]
#   Boolean. Activates tls-auth to Add an additional layer of HMAC
#     authentication on top of the TLS control channel to protect
#     against DoS attacks. This has to be set to the same value as on the
#     Server
#   Default: false
#
# [*x509_name*]
#   Common name of openvpn server to make an x509-name verification
#   Default: undef
#
# [*setenv*]
#   Hash. Set a custom environmental variable name=value to pass to script.
#   Default: {}
#
# [*setenv_safe*]
#   Hash. Set a custom environmental variable OPENVPN_name=value to pass to
#     script. This directive is designed to be pushed by the server to clients,
#     and the prepending of "OPENVPN_" to the environmental variable is a
#     safety precaution to prevent a LD_PRELOAD style attack from a malicious
#     or compromised server.
#   Default: {}
#
# [*up*]
#   String,  Script which we want to run when openvpn client is connecting
#
# [*down*]
#   String,  Script which we want to run when openvpn client is disconneting
#
# [*sndbuf*]
#   Integer, Set the TCP/UDP socket send buffer size.
#   Default: undef
#
# [*rcvbuf*]
#   Integer, Set the TCP/UDP socket receive buffer size.
#   Default: undef
#
# [*shared_ca*]
#   String,  The name of an openssl::ca resource to use.
#   Default: undef
#
# === Examples
#
#   openvpn::client {
#     'my_user':
#       server      => 'contractors',
#       remote_host => 'vpn.mycompany.com'
#    }
#
# * Removal:
#     Manual process right now, todo for the future
#
#
# === Authors
#
# * Raffael Schmid <mailto:raffael@yux.ch>
# * John Kinsella <mailto:jlkinsel@gmail.com>
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
# === License
#
# Copyright 2013 Raffael Schmid, <raffael@yux.ch>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
define openvpn::client(
  $server,
  $compression          = 'comp-lzo',
  $dev                  = 'tun',
  $mute                 = '20',
  $mute_replay_warnings = true,
  $nobind               = true,
  $persist_key          = true,
  $persist_tun          = true,
  $port                 = '1194',
  $proto                = 'tcp',
  $remote_host          = $::fqdn,
  $resolv_retry         = 'infinite',
  $auth_retry           = 'none',
  $verb                 = '3',
  $pam                  = false,
  $cipher               = undef,
  $authuserpass         = false,
  $setenv               = {},
  $setenv_safe          = {},
  $up                   = '',
  $down                 = '',
  $tls_auth             = false,
  $x509_name            = undef,
  $sndbuf               = undef,
  $rcvbuf               = undef,
  $shared_ca            = undef,
) {

  if $pam {
    warning('Using $pam is deprecated. Use $authuserpass instead!')
  }

  Openvpn::Server[$server] ->
  Openvpn::Client[$name]

  $ca_name = pick($shared_ca, $server)
  Openvpn::Ca[$ca_name] ->
  Openvpn::Client[$name]

  exec { "generate certificate for ${name} in context of ${ca_name}":
    command  => ". ./vars && ./pkitool ${name}",
    cwd      => "/etc/openvpn/${ca_name}/easy-rsa",
    creates  => "/etc/openvpn/${ca_name}/easy-rsa/keys/${name}.crt",
    provider => 'shell';
  }

  file { [ "/etc/openvpn/${server}/download-configs/${name}",
          "/etc/openvpn/${server}/download-configs/${name}/keys",
          "/etc/openvpn/${server}/download-configs/${name}/keys/${name}" ]:
    ensure  => directory,
  }

  file { "/etc/openvpn/${server}/download-configs/${name}/keys/${name}/${name}.crt":
    ensure  => link,
    target  => "/etc/openvpn/${ca_name}/easy-rsa/keys/${name}.crt",
    require => Exec["generate certificate for ${name} in context of ${ca_name}"],
  }

  file { "/etc/openvpn/${server}/download-configs/${name}/keys/${name}/${name}.key":
    ensure  => link,
    target  => "/etc/openvpn/${ca_name}/easy-rsa/keys/${name}.key",
    require => Exec["generate certificate for ${name} in context of ${ca_name}"],
  }

  file { "/etc/openvpn/${server}/download-configs/${name}/keys/${name}/ca.crt":
    ensure  => link,
    target  => "/etc/openvpn/${ca_name}/easy-rsa/keys/ca.crt",
    require => Exec["generate certificate for ${name} in context of ${ca_name}"],
  }

  if $tls_auth {
    file { "/etc/openvpn/${server}/download-configs/${name}/keys/${name}/ta.key":
      ensure  => link,
      target  => "/etc/openvpn/${server}/easy-rsa/keys/ta.key",
      require => Exec["generate certificate for ${name} in context of ${server}"],
      before  => Exec["tar the thing ${server} with ${name}"],
      notify  => Exec["tar the thing ${server} with ${name}"],
    }
  }

  file { "/etc/openvpn/${server}/download-configs/${name}/${name}.conf":
    owner   => root,
    group   => root,
    mode    => '0444',
    content => template('openvpn/client.erb'),
    notify  => Exec["tar the thing ${server} with ${name}"],
  }

  exec { "tar the thing ${server} with ${name}":
    cwd         => "/etc/openvpn/${server}/download-configs/",
    command     => "/bin/rm ${name}.tar.gz; tar --exclude=\\*.conf.d -chzvf ${name}.tar.gz ${name}",
    refreshonly => true,
    require     => [
      File["/etc/openvpn/${server}/download-configs/${name}/${name}.conf"],
      File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}/ca.crt"],
      File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}/${name}.key"],
      File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}/${name}.crt"]
    ],
    notify      => Exec["generate ${name}.ovpn in ${server}"],
  }

  exec { "generate ${name}.ovpn in ${server}":
    cwd         => "/etc/openvpn/${server}/download-configs/",
    command     => "/bin/rm ${name}.ovpn; cat ${name}/${name}.conf | perl -lne 'if(m|^ca keys/${name}/ca.crt|){ chomp(\$ca=`cat ${name}/keys/${name}/ca.crt`); print \"<ca>\n\$ca\n</ca>\"} elsif(m|^cert keys/${name}/${name}.crt|) { chomp(\$crt=`cat ${name}/keys/${name}/${name}.crt`); print \"<cert>\n\$crt\n</cert>\"} elsif(m|^key keys/${name}/${name}.key|){ chomp(\$key=`cat ${name}/keys/${name}/${name}.key`); print \"<key>\n\$key\n</key>\"} else { print} ' > ${name}.ovpn",
    refreshonly => true,
    require     => [
      File["/etc/openvpn/${server}/download-configs/${name}/${name}.conf"],
      File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}/ca.crt"],
      File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}/${name}.key"],
      File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}/${name}.crt"],
    ],
  }

  file { "/etc/openvpn/${server}/download-configs/${name}.ovpn":
    mode    => '0400',
    require => Exec["generate ${name}.ovpn in ${server}"],
  }
}
