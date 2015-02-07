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

  $group = $::osfamily ? {
    'RedHat' => 'nobody',
    default  => 'nogroup'
  }

  case $::osfamily {
    'RedHat': {
      # Redhat/Centos >= 6.4
      if(versioncmp($::operatingsystemrelease, '6.4') >= 0) {
        $additional_packages = ['easy-rsa']
        $easyrsa_source = '/usr/share/easy-rsa/2.0'

      # Redhat/Centos < 6.4 >= 6
      } elsif(versioncmp($::operatingsystemrelease, '6') >= 0) {
        $easyrsa_source = '/usr/share/openvpn/easy-rsa/2.0'

      # Redhat/Centos < 6
      } else {
        $easyrsa_source = '/usr/share/doc/openvpn/examples/easy-rsa/2.0'
      }

      $ldap_auth_plugin_location = undef # no ldap plugin on redhat/centos

      if(versioncmp($::operatingsystemrelease, '7.0') >= 0) {
        $systemd = true
      } else {
        $systemd = false
      }
    }
    'Debian': { # Debian/Ubuntu
      case $::operatingsystem {
        'Debian': {
          # Version > 8.0.0, jessie
          if(versioncmp($::operatingsystemdistrelease, '8.0.0') >= 0) {
            $additional_packages = ['easy-rsa', 'openvpn-auth-ldap']
            $easyrsa_source = '/usr/share/easy-rsa/'
            $ldap_auth_plugin_location = '/usr/lib/openvpn/openvpn-auth-ldap.so'

          # Version > 7.0.0, wheezy
          } elsif(versioncmp($::operatingsystemdistrelease, '7.0.0') >= 0) {
            $additional_packages = ['openvpn-auth-ldap']
            $easyrsa_source = '/usr/share/doc/openvpn/examples/easy-rsa/2.0'
            $ldap_auth_plugin_location = '/usr/lib/openvpn/openvpn-auth-ldap.so'
          } else {
            $easyrsa_source = '/usr/share/doc/openvpn/examples/easy-rsa/2.0'
          }
        }
        'Ubuntu': {
          # Version > 13.10, saucy
          if(versioncmp($::operatingsystemdistrelease, '13.10') >= 0) {
            $additional_packages = ['easy-rsa', 'openvpn-auth-ldap']
            $easyrsa_source = '/usr/share/easy-rsa/'
            $ldap_auth_plugin_location = '/usr/lib/openvpn/openvpn-auth-ldap.so'
          } else {
            $easyrsa_source = '/usr/share/doc/openvpn/examples/easy-rsa/2.0'
          }
        }
        default: {
          fail("Not supported OS / Distribution: ${::osfamily}/${::operatingsystem}")
        }
      }

      $systemd = false
    }
    default: {
      fail("Not supported OS family ${::osfamily}")
    }
  }

  $link_openssl_cnf = $::osfamily ? {
    /(Debian|RedHat)/ => true,
    default           => false
  }

}
