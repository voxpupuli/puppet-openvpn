# == Define: openvpn::revoke
#
# This define creates a revocation on a certificate for a specified openvpn
# server.
#
# === Parameters
#
# [*server*]
#   String.  Name of the corresponding openvpn endpoint
#   Required
#
# === Note
#
# In order for a certificate to be revoked, it must exist first.
# You cannot declare a revoked certificate that has not been created by the
# module.
#
# === Examples
#
#   openvpn::client {
#     'my_user':
#       server      => 'contractors'
#   }
#
#   openvpn::revoke {
#     'my_user':
#       server      => 'contractors'
#    }
#
# === Authors
#
# * Alessandro Grassi <mailto:alessandro.grassi@devise.it>
#
# === License
#
# Copyright 2013 Alessandro Grassi <alessandro.grassi@devise.it>
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
define openvpn::revoke(
  $server,
) {

  Openvpn::Server[$server] ->
  Openvpn::Revoke[$name]

  Openvpn::Client[$name] ->
  Openvpn::Revoke[$name]

  $etc_directory = $::openvpn::params::etc_directory

  exec { "revoke certificate for ${name} in context of ${server}":
    command  => ". ./vars && ./revoke-full ${name}; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))' && touch revoked/${name}",
    cwd      => "${etc_directory}/openvpn/${server}/easy-rsa",
    creates  => "${etc_directory}/openvpn/${server}/easy-rsa/revoked/${name}",
    provider => 'shell',
  }
}
