# @summary This define configures options which will be pushed by the server to a specific client only.

# This feature is explained here: http://openvpn.net/index.php/open-source/documentation/howto.html#policy
# All the parameters are explained in the openvpn documentation http://openvpn.net/index.php/open-source/documentation/howto.html#policy
#
# @param server Name of the corresponding openvpn endpoint
# @param iroute Array of iroute combinations.
# @param iroute_ipv6 Array of IPv6 iroute combinations.
# @param route  Array of route combinations pushed to client.
# @param ifconfig IP configuration to push to the client.
# @param ifconfig_ipv6 IPv6 configuration to push to the client.
# @param dhcp_options DHCP options to push to the client.
# @param redirect_gateway Redirect all traffic to gateway
# @param ensure Sets the client specific configuration file status (present or absent)
# @param manage_client_configs Manage dependencies on Openvpn::Client ressources
#
# @example
#   openvpn::client_specific_config {
#     'vpn_client':
#       server       => 'contractors',
#       iroute       => ['10.0.1.0 255.255.255.0'],
#       ifconfig     => '10.10.10.1 10.10.10.2',
#       dhcp_options => ['DNS 8.8.8.8']
#    }
define openvpn::client_specific_config (
  String[1] $server,
  Enum['present', 'absent'] $ensure  = present,
  Array[String[1]] $iroute           = [],
  Array[String[1]] $iroute_ipv6      = [],
  Array[String[1]] $route            = [],
  Optional[String[1]] $ifconfig      = undef,
  Optional[String[1]] $ifconfig_ipv6 = undef,
  Array[String[1]]  $dhcp_options    = [],
  Boolean $redirect_gateway          = false,
  Boolean $manage_client_configs     = true,
) {

  if $manage_client_configs {
    Openvpn::Server[$server]
    -> Openvpn::Client[$name]
    -> Openvpn::Client_specific_config[$name]
  } else {
    Openvpn::Server[$server]
    -> Openvpn::Client_specific_config[$name]
  }

  file { "${openvpn::etc_directory}/openvpn/${server}/client-configs/${name}":
    ensure  => $ensure,
    content => template('openvpn/client_specific_config.erb'),
  }

}
