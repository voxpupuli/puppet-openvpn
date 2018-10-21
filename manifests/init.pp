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
# [*etc_directory*]
#   String. Path of the configuration directory.
#   Default: /etc
# [*group*]
#   String. File group of the generated config files.
#   Default: nobody
# [*link_openssl_cnf*]
#   Boolean. Link easy-rsa/openssl.cnf to easy-rsa/openssl-1.0.0.cnf
#   Default: true
# [*pam_module_path*]
#   String. Path to openvpn-auth-pam.so
#   Default: undef
# [*namespecific_rclink*]
#   Boolean. Enable namespecific rclink's (BSD-style)
#   Default: false
# [*default_easyrsa_ver*]
#   String. Expected version of easyrsa.
#   Default: 2.0
# [*easyrsa_source*]
#   String. Location of easyrsa.
#   Default: /usr/share/easy-rsa/
# [*additional_packages*]
#   Array. Additional packages
#   Default: ['easy-rsa']
# [*ldap_auth_plugin_location*]
#   String. Path to the ldap auth pam module
#   Default: undef
# [*client_defaults*]
#   Hash of defaults for clients passed to openvpn::client defined type.
#   Default: {}
# [*clients*]
#   Hash of clients passed to openvpn::client defined type.
#   Default: {}
# [*client_specific_config_defaults*]
#   Hash of defaults for client specific configurations passed to
#   openvpn::client_specific_config defined type.
#   Default: {}
# [*client_specific_configs*]
#   Hash of client specific configurations passed to
#   openvpn::client_specific_config defined type.
#   Default: {}
# [*revoke_defaults*]
#   Hash of defaults for revokes passed to openvpn::revoke defined type.
#   Default: {}
# [*revokes*]
#   Hash of revokes passed to openvpn::revoke defined type.
#   Default: {}
# [*server_defaults*]
#   Hash of defaults for servers passed to openvpn::server defined type.
#   Default: {}
# [*servers*]
#   Hash of servers passed to openvpn::server defined type.
#   Default: {}
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
  Boolean                              $autostart_all,
  Boolean                              $manage_service,
  Stdlib::Absolutepath                 $etc_directory,
  String[1]                            $group,
  Boolean                              $link_openssl_cnf,
  Optional[Stdlib::Absolutepath]       $pam_module_path,
  Boolean                              $namespecific_rclink,
  Pattern[/^[23]\.0$/]                 $default_easyrsa_ver,
  Stdlib::Unixpath                     $easyrsa_source,
  Variant[String[1], Array[String[1]]] $additional_packages,
  Optional[Stdlib::Absolutepath]       $ldap_auth_plugin_location,

  Hash                                 $client_defaults                 = {},
  Hash                                 $clients                         = {},
  Hash                                 $client_specific_config_defaults = {},
  Hash                                 $client_specific_configs         = {},
  Hash                                 $revoke_defaults                 = {},
  Hash                                 $revokes                         = {},
  Hash                                 $server_defaults                 = {},
  Hash                                 $servers                         = {},
) {
  $easyrsa_version = $facts['easyrsa'] ? {
    undef   => $default_easyrsa_ver,
    default => $facts['easyrsa'],
  }

  include openvpn::install
  include openvpn::config

  Class['openvpn::install']
  -> Class['openvpn::config']
  -> Class['openvpn']

  if $facts['service_provider'] != 'systemd' {
    class { 'openvpn::service':
      subscribe => [Class['openvpn::config'], Class['openvpn::install'] ],
    }

    if empty($servers) {
      Class['openvpn::service'] -> Class['openvpn']
    }
  }

  $clients.each |$name, $params| {
    openvpn::client {
      default:
        * => $client_defaults;
      $name:
        * => $params;
    }
  }

  $client_specific_configs.each |$name, $params| {
    openvpn::client_specific_config {
      default:
        * => $client_specific_config_defaults;
      $name:
        * => $params;
    }
  }

  $revokes.each |$name, $params| {
    openvpn::revoke {
      default:
        * => $revoke_defaults;
      $name:
        * => $params;
    }
  }

  $servers.each |$name, $params| {
    openvpn::server {
      default:
        * => $server_defaults;
      $name:
        * => $params;
    }
  }
}
