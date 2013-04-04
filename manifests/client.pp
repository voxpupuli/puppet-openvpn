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
# [*resolv_retry*]
#   Integer/String. How many seconds should the openvpn client try to resolve
#     the server's hostname
#   Default: infinite
#   Options: Integer or infinite
#
# [*verb*]
#   Integer.  Level of logging verbosity
#   Default: 3
#
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
  $compression = 'comp-lzo',
  $dev = 'tun',
  $mute = '20',
  $mute_replay_warnings = true,
  $nobind = true,
  $persist_key = true,
  $persist_tun = true,
  $port = '1194',
  $proto = 'tcp',
  $remote_host = $::fqdn,
  $resolv_retry = 'infinite',
  $verb = '3',
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

        "/etc/openvpn/${server}/download-configs/${name}/${name}.conf":
            owner   => root,
            group   => root,
            mode    => '0444',
            content => template('openvpn/client.erb'),
            notify  => Exec["tar the thing ${server} with ${name}"];
    }

#    concat {
#        "/etc/openvpn/${server}/client-configs/${name}":
#            owner   => root,
#            group   => root,
#            mode    => 644,
#            warn    => true,
#            force   => true,
#            notify  => Exec["tar the thing ${server} with ${name}"],
#            require => [ File['/etc/openvpn'], File["/etc/openvpn/${server}/download-configs/${name}"] ];
#    }

    exec {
        "tar the thing ${server} with ${name}":
            cwd         => "/etc/openvpn/${server}/download-configs/",
            command     => "/bin/rm ${name}.tar.gz; tar --exclude=\\*.conf.d -chzvf ${name}.tar.gz ${name}",
            refreshonly => true,
            require     => [  File["/etc/openvpn/${server}/download-configs/${name}/${name}.conf"],
                              File["/etc/openvpn/${server}/download-configs/${name}/keys/ca.crt"],
                              File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}.key"],
                              File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}.crt"] ],
            notify => Exec["generate ${name}.ovpn in ${server}"];

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


}
