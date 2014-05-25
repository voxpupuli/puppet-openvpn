# == Define: openvpn::client
#
# This define creates the client certs for a specified openvpn server as well
# as creating a tarball that can be directly imported into openvpn clients. It
# also passes client parameters through to openvpn::client::config to create
# a client configuration file that will be bundled with the tarball. To just
# generate a client configuration file without certs or anything else call
# openvpn::client::config directly.
#
#
# === Parameters
#
# [*server*]
#   String.  Name of the corresponding openvpn endpoint
#   Required
#
# See openvpn::client::config for client configuration parameters
#
# [*remote_host*]
#   String.  The IP or hostname of the openvpn server service
#   Default: FQDN of host if not explicitly declared.
# NOTE: When invoked through openvpn::client remote_host defaults to the
#   FQDN of the host it is invoked on. When invoked directly through
#   openvpn::client::config it is assumed that you are creating an openvpn
#   configuration file somewhere other than the server so the remote_host
#   must be explicitly declared.
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
# * John Bowman <mailto:jbowman@macprofessionals.com>
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
  $compression = undef,
  $dev = undef,
  $mute = undef,
  $mute_replay_warnings = undef,
  $nobind = undef,
  $persist_key = undef,
  $persist_tun = undef,
  $port = undef,
  $proto = undef,
  $remote_host = $::fqdn,
  $resolv_retry = undef,
  $verb = undef,
  $pam = undef,
  $authuserpass = undef,
  $shared_secret = undef,
) {

  Openvpn::Server[$server] ->
  Openvpn::Client[$name]

  exec {
    "generate certificate for ${name} in context of ${server}":
      command  => ". ./vars && ./pkitool ${name}",
      cwd      => "/etc/openvpn/${server}/easy-rsa",
      creates  => "/etc/openvpn/${server}/easy-rsa/keys/${name}.crt",
      provider => 'shell';
  }

  file {
    [ "/etc/openvpn/${server}/download-configs/${name}",
      "/etc/openvpn/${server}/download-configs/${name}/keys"]:
        ensure  => directory;

    "/etc/openvpn/${server}/download-configs/${name}/keys/${name}.crt":
      ensure  => link,
      target  => "/etc/openvpn/${server}/easy-rsa/keys/${name}.crt",
      require => Exec["generate certificate for ${name} in context of ${server}"];

    "/etc/openvpn/${server}/download-configs/${name}/keys/${name}.key":
      ensure  => link,
      target  => "/etc/openvpn/${server}/easy-rsa/keys/${name}.key",
      require => Exec["generate certificate for ${name} in context of ${server}"];

    "/etc/openvpn/${server}/download-configs/${name}/keys/ca.crt":
      ensure  => link,
      target  => "/etc/openvpn/${server}/easy-rsa/keys/ca.crt",
      require => Exec["generate certificate for ${name} in context of ${server}"];
  }

  ::openvpn::client::config { "${name}":
      path => "/etc/openvpn/${server}/download-configs/${name}/${name}.conf",
      compression => $compression,
      dev => $dev,
      mute => $mute,
      mute_replay_warnings => $mute_replay_warnings,
      nobind => $nobind,
      persist_key => $persist_key,
      persist_tun => $persist_tun,
      port => $port,
      proto => $proto,
      remote_host => $remote_host,
      resolv_retry => $resolv_retry,
      verb => $verb,
      pam => $pam,
      shared_secret => $shared_secret,
      authuserpass => $authuserpass,
      notify  => Exec["tar the thing ${server} with ${name}"],
  }


  exec {
    "tar the thing ${server} with ${name}":
      cwd         => "/etc/openvpn/${server}/download-configs/",
      command     => "/bin/rm ${name}.tar.gz; tar --exclude=\\*.conf.d -chzvf ${name}.tar.gz ${name}",
      refreshonly => true,
      require     => [  File["/etc/openvpn/${server}/download-configs/${name}/${name}.conf"],
                        File["/etc/openvpn/${server}/download-configs/${name}/keys/ca.crt"],
                        File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}.key"],
                        File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}.crt"]
                      ],
      notify      => Exec["generate ${name}.ovpn in ${server}"];
  }

  exec {
    "generate ${name}.ovpn in ${server}":
      cwd         => "/etc/openvpn/${server}/download-configs/",
      command     => "/bin/rm ${name}.ovpn; cat  ${name}/${name}.conf|perl -lne 'if(m|^ca keys/ca.crt|){ chomp(\$ca=`cat ${name}/keys/ca.crt`); print \"<ca>\n\$ca\n</ca>\"} elsif(m|^cert keys/${name}.crt|) { chomp(\$crt=`cat ${name}/keys/${name}.crt`); print \"<cert>\n\$crt\n</cert>\"} elsif(m|^key keys/${name}.key|){ chomp(\$key=`cat ${name}/keys/${name}.key`); print \"<key>\n\$key\n</key>\"} else { print} ' > ${name}.ovpn",
      refreshonly => true,
      require     => [  File["/etc/openvpn/${server}/download-configs/${name}/${name}.conf"],
                        File["/etc/openvpn/${server}/download-configs/${name}/keys/ca.crt"],
                        File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}.key"],
                        File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}.crt"],
                      ],
  }

  file { "/etc/openvpn/${server}/download-configs/${name}.ovpn":
    mode    => '0400',
    require => Exec["generate ${name}.ovpn in ${server}"],
  }
}
