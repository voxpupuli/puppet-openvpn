# == Class: openvpn
#
# This module installs the openvpn service, configures vpn endpoints, generates
# client certificates, and generates client config files
#
# === Parameters
#
# [*autostart_all*]
#   Boolean. Wether the openvpn instances should be started automatically on boot.
#   Default: true
#
# [*config_home*]
#   String. Directory for OpenVPN configuration files. If set to something other
#     than "/etc/openvpn" then /etc/openvpn will be created as a symbolic link to
#     the specified location.
#   Default: /etc/openvpn
#
#
# === Examples
#
#   class { 'openvpn':
#     autostart_all => true,
#   }
#
#   class { 'openvpn':
#     config_home => '/home/openvpn',
#   }
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
class openvpn(
  $autostart_all = true,
  $config_home = '/etc/openvpn',
) {

  class { 'openvpn::params': } ->
  class { 'openvpn::install': } ->
  class { 'openvpn::config': } ->
  Class['openvpn']

  if ! $::openvpn::params::systemd {
    class { 'openvpn::service':
      subscribe => [Class['openvpn::config'], Class['openvpn::install'] ],
      before    => Class['openvpn'],
    }
  }

}
