#
# @summary This module installs the openvpn service, configures vpn endpoints, generates client certificates, and generates client config files
#
# @param autostart_all Whether openvpn instances should be started automatically on boot.
# @param manage_service Whether the openvpn service should be managed by puppet.
# @param etc_directory  Path of the configuration directory.
# @param group  File group of the generated config files.
# @param link_openssl_cnf Link easy-rsa/openssl.cnf to easy-rsa/openssl-1.0.0.cnf
# @param pam_module_path  Path to openvpn-auth-pam.so
# @param namespecific_rclink Enable namespecific rclink's (BSD-style)
# @param default_easyrsa_ver Expected version of easyrsa.
# @param easyrsa_source  Location of easyrsa.
# @param additional_packages Additional packages
# @param ldap_auth_plugin_location  Path to the ldap auth pam module
# @param client_defaults Hash of defaults for clients passed to openvpn::client defined type.
# @param clients Hash of clients passed to openvpn::client defined type.
# @param client_specific_config_defaults Hash of defaults for client specific configurations passed to openvpn::client_specific_config defined type.
# @param client_specific_configs Hash of client specific configurations passed to openvpn::client_specific_config defined type.
# @param revoke_defaults Hash of defaults for revokes passed to openvpn::revoke defined type.
# @param revokes Hash of revokes passed to openvpn::revoke defined type.
# @param server_defaults Hash of defaults for servers passed to openvpn::server defined type.
# @param servers Hash of servers passed to openvpn::server defined type.
# @param server_directory  Path of the server configuration. This is usually `/etc_directory/openvpn`, but RHEL/CentOS 8 uses `/etc_directory/openvpn/server`
# @param server_service_name  Name of the openvpn server service. This is usually `openvpn`, but RHEL/CentOS 8 uses `openvpn-server`.
#
# @example
#   class { 'openvpn':
#     autostart_all => true,
#   }
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
  String[1]                            $server_service_name,
  Optional[Stdlib::Absolutepath]       $server_directory,

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
