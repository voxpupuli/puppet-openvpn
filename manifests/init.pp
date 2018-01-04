# == Class: openvpn
#
# This module installs the openvpn service, configures vpn endpoints, generates
# client certificates, and generates client config files
#
# === Parameters
#
# [*autostart_all*]
#   Boolean. Whether openvpn instances should be started automatically on boot.
#   Default: true
# [*manage_service*]
#   Boolean. Wether the openvpn service should be managed by puppet.
#   Default: true
# [*client_defaults*]
#   Hash of defaults for clients passed to openvpn::client defined type.
#   Default: {} (hiera_hash)
# [*clients*]
#   Hash of clients passed to openvpn::client defined type.
#   Default: {} (hiera_hash)
# [*client_specific_config_defaults*]
#   Hash of defaults for client specific configurations passed to
#   openvpn::client_specific_config defined type.
#   Default: {} (hiera_hash)
# [*client_specific_configs*]
#   Hash of client specific configurations passed to
#   openvpn::client_specific_config defined type.
#   Default: {} (hiera_hash)
# [*revoke_defaults*]
#   Hash of defaults for revokes passed to openvpn::revoke defined type.
#   Default: {} (hiera_hash)
# [*revokes*]
#   Hash of revokes passed to openvpn::revoke defined type.
#   Default: {} (hiera_hash)
# [*server_defaults*]
#   Hash of defaults for servers passed to openvpn::server defined type.
#   Default: {} (hiera_hash)
# [*servers*]
#   Hash of servers passed to openvpn::server defined type.
#   Default: {} (hiera_hash)
#
#
# === Examples
#
#   class { 'openvpn':
#     autostart_all => true,
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
class openvpn (
  Boolean $autostart_all                = true,
  Boolean $manage_service               = true,
  Hash $client_defaults                 = hiera_hash('openvpn::client_defaults', {}),
  Hash $clients                         = hiera_hash('openvpn::clients', {}),
  Hash $client_specific_config_defaults = hiera_hash('openvpn::client_specific_config_defaults', {}),
  Hash $client_specific_configs         = hiera_hash('openvpn::client_specific_configs', {}),
  Hash $revoke_defaults                 = hiera_hash('openvpn::revoke_defaults', {}),
  Hash $revokes                         = hiera_hash('openvpn::revokes', {}),
  Hash $server_defaults                 = hiera_hash('openvpn::server_defaults', {}),
  Hash $servers                         = hiera_hash('openvpn::servers', {}),
) {

  class { 'openvpn::params': }
  -> class { 'openvpn::install': }
  -> class { 'openvpn::config': }
  -> Class['openvpn']

  if !$::openvpn::params::systemd {
    class { 'openvpn::service':
      subscribe => [Class['openvpn::config'], Class['openvpn::install'] ],
    }
    if empty($servers) {
      Class['openvpn::service'] -> Class['openvpn']
    }
  }

  create_resources('openvpn::client', $clients, $client_defaults)
  create_resources('openvpn::client_specific_config', $client_specific_configs, $client_specific_config_defaults)
  create_resources('openvpn::revoke', $revokes, $revoke_defaults)
  create_resources('openvpn::server', $servers, $server_defaults)

}
