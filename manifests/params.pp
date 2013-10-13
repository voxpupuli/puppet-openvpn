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
      if($::operatingsystemmajrelease >= 6) { # Redhat/Centos >= 6
        # http://docs.puppetlabs.com/references/latest/function.html#versioncmp
        if(versioncmp($::operatingsystemrelease, '6.4') < 0) { # Version < 6.4
          $easyrsa_source = '/usr/share/openvpn/easy-rsa/2.0'
        }
        else { # Version >= 6.4
          package { 'easy-rsa':
            ensure => installed,
          }
          $easyrsa_source = '/usr/share/easy-rsa/2.0'
        }
      }
      else { # Redhat/CentOS < 6
        $easyrsa_source = '/usr/share/doc/openvpn/examples/easy-rsa/2.0'
      }
    }
    default: { # Debian/Ubuntu
      $easyrsa_source = '/usr/share/doc/openvpn/examples/easy-rsa/2.0'
    }
  }

  $link_openssl_cnf = $::osfamily ? {
    /(Debian|RedHat)/ => true,
    default           => false
  }

}
