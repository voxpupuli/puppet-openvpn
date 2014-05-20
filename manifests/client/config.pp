# == Define: openvpn::client::config
#
# This define creates an openvpn client config file
#
#
# === Parameters
# == Required Parameters:
#
# [*path*]
#   String.  Full path and name of the config to create
#
# [*remote_host*]
#   String.  The IP or hostname of the openvpn server service
#
# == Optional Parameters:
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
# [*pam*]
#   Boolean, Enable/Disable.
#   Default: false
#
# [*authuserpass*]
#   Boolean. Set if username and password required
#   Default: false
#
# [*shared_secret*]
#   String.  Name of shared secret file
#   NOTE:   If this is defined then the client will use a shared key and
#           ignore any certs that are in place for TLS authentication.
#
# === Examples
#
#   openvpn::client::config {
#     'my_user':
#       remote_host => "vpn.mycompany.com",
#       path => "/etc/openvpn/my_user.conf",
#    }
#
#  Removal:
#   openvpn::client::config {
#     'my_user':
#       ensure => 'absent',
#    }
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
define openvpn::client::config (
  $path,
  $remote_host,
  $ensure = 'present',
  $compression = 'comp-lzo',
  $dev = 'tun',
  $mute = '20',
  $mute_replay_warnings = true,
  $nobind = true,
  $persist_key = true,
  $persist_tun = true,
  $port = '1194',
  $proto = 'tcp',
  $resolv_retry = 'infinite',
  $verb = '3',
  $pam = false,
  $authuserpass = false,
  $shared_secret = '',
) {

  if $pam {
    warning('Using $pam is deprecated. Use $authuserpass instead!')
  }

  file { "${path}":
        ensure => $ensure,
        owner   => root,
        group   => root,
        mode    => '0444',
        content => template('openvpn/client.erb'),
        require => Class ['::openvpn::install'],
  }

}
