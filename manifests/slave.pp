# == Define: openvpn::slave
#
# This define runs a openvpn slave for redundancy
#
# === Parameters
#
# [*tls_auth*]
#   Boolean. Determins if a tls key is generated
#   Default: False
#
# === Examples
#
#   openvpn::slave {
#     'my_slave':
#       master => 'vpn.mycompany.com'
#    }
#
# === Authors
#
# * Raffael Schmid <mailto:raffael@yux.ch>
# * John Kinsella <mailto:jlkinsel@gmail.com>
# * Justin Lambert <mailto:jlambert@letsevenup.com>
# * Marius Rieder <mailto:marius.rieder@nine.ch>
# * Kevin Häfeli <mailto:kevin@zattoo.com>
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
define openvpn::slave(
) {
  include openvpn
  Class['openvpn::install'] ->
  Openvpn::Slave[$name]


  Vpnserver <<| |>>

  #$query_profiles = ['from', 'resources', ['=', 'type','Vpnserver'], ['=', 'parameters.tag','crt']]
  #$crt = puppetdb_query($query_profiles)
  #err("result ${crt}")
}
