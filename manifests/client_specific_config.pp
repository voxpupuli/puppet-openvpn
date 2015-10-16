# == Define: openvpn::client_specific_config
#
# This define configures options which will be pushed by the server to a
# specific client only. This feature is explained here:
#  http://openvpn.net/index.php/open-source/documentation/howto.html#policy
#
# === Parameters
#
# All the parameters are explained in the openvpn documentation:
#   http://openvpn.net/index.php/open-source/documentation/howto.html#policy
#
# [*server*]
#   String.  Name of the corresponding openvpn endpoint
#   Required
#
# [*iroute*]
#   Array.  Array of iroute combinations.
#   Default: []
#
# [*iroute_ipv6*]
#   Array.  Array of IPv6 iroute combinations.
#   Default: []
#
# [*route*]
#   Array.  Array of route combinations pushed to client.
#   Default: []
#
# [*ifconfig*]
#   String.  IP configuration to push to the client.
#   Default: false
#
# [*dhcp_options]
#   Array.  DHCP options to push to the client.
#   Default: []
#
# [*redirect_gateway]
#   Array.  Redirect all traffic to gateway
#   Default: false
#
# [*ensure]
#   Keyword. Sets the client specific configuration file status (present or absent)
#   Default: present
#
#
# === Examples
#
#   openvpn::client_specific_config {
#     'vpn_client':
#       server       => 'contractors',
#       iroute       => ['10.0.1.0 255.255.255.0'],
#       ifconfig     => '10.10.10.1 10.10.10.2',
#       dhcp_options => ['DNS 8.8.8.8']
#    }
#
# * Removal:
#     Use $ensure => absent
#
#
# === Authors
#
# * Raffael Schmid <mailto:raffael@yux.ch>
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
define openvpn::client_specific_config(
  $server,
  $ensure           = present,
  $iroute           = [],
  $iroute_ipv6      = [],
  $route            = [],
  $ifconfig         = false,
  $dhcp_options     = [],
  $redirect_gateway = false,
) {

  Openvpn::Server[$server] ->
  Openvpn::Client[$name] ->
  Openvpn::Client_specific_config[$name]

  file { "${::openvpn::params::etc_directory}/openvpn/${server}/client-configs/${name}":
    ensure  => $ensure,
    content => template('openvpn/client_specific_config.erb')
  }

}
