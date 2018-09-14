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
class openvpn::params {

  case $facts['os']['family'] {
    'RedHat': { # RedHat/CentOS
      $etc_directory       = '/etc'
      $root_group          = 'root'
      $group               = 'nobody'
      $link_openssl_cnf    = true
      $pam_module_path     = '/usr/lib64/openvpn/plugin/lib/openvpn-auth-pam.so'
      $namespecific_rclink = false
      $default_easyrsa_ver = '3.0'
      $easyrsa_source      = '/usr/share/easy-rsa/3'

      case $facts['os']['release']['major'] {
        '7': {
          $additional_packages = ['easy-rsa']
          $ldap_auth_plugin_location = undef
          $systemd = true
        }
        '6': {
          $additional_packages = ['easy-rsa','openvpn-auth-ldap']
          $ldap_auth_plugin_location = '/usr/lib64/openvpn/plugin/lib/openvpn-auth-ldap.so'
          $systemd = false
        }
        default: {
          fail("unsupported OS ${facts['os']['name']} ${facts['os']['release']['major']}")
        }
      }
    }
    'Debian': { # Debian/Ubuntu
      $etc_directory             = '/etc'
      $root_group                = 'root'
      $group                     = 'nogroup'
      $link_openssl_cnf          = true
      $namespecific_rclink       = false
      $default_easyrsa_ver       = '2.0'
      $additional_packages       = ['easy-rsa','openvpn-auth-ldap']
      $easyrsa_source            = '/usr/share/easy-rsa/'
      $ldap_auth_plugin_location = '/usr/lib/openvpn/openvpn-auth-ldap.so'
      $pam_module_path           = '/usr/lib/openvpn/openvpn-plugin-auth-pam.so'

      case $facts['os']['name'] {
        'Debian': {
          case $facts['os']['release']['major'] {
            '8','9': {
              $systemd = true
            }
            default: {
              fail("unsupported OS ${facts['os']['name']} ${facts['os']['release']['major']}")
            }
          }
        }
        'Ubuntu': {
          case $facts['os']['release']['major'] {
            '16.04': {
              $systemd = true
            }
            '14.04': {
              $systemd = false
            }
            default: {
              fail("unsupported OS ${facts['os']['name']} ${facts['os']['release']['major']}")
            }
          }
        }
        default: {
          fail("unsupported OS ${facts['os']['name']} ${facts['os']['release']['major']}")
        }
      }
    }
    'Archlinux': {
      $default_easyrsa_ver = '3.0'
      $etc_directory             = '/etc'
      $root_group                = 'root'
      $additional_packages       = ['easy-rsa']
      $easyrsa_source            = '/usr/share/easy-rsa/'
      $group                     = 'nobody'
      $ldap_auth_plugin_location = undef # unsupported
      $link_openssl_cnf          = true
      $systemd                   = true
      $namespecific_rclink       = false
    }
    'FreeBSD': {
      $etc_directory       = '/usr/local/etc'
      $root_group          = 'wheel'
      $group               = 'nogroup'
      $link_openssl_cnf    = true
      $pam_module_path     = '/usr/local/lib/openvpn/openvpn-auth-pam.so'
      $additional_packages = ['easy-rsa']
      $easyrsa_source      = '/usr/local/share/easy-rsa'
      $default_easyrsa_ver = '2.0'
      $namespecific_rclink = true
      $systemd             = false
    }
    default: {
      fail("unsupported OS ${facts['os']['name']} ${facts['os']['release']['major']}")
    }
  }

  $easyrsa_version = $facts['easyrsa'] ? {
    undef   => $default_easyrsa_ver,
    default => $facts['easyrsa'],
  }
}
