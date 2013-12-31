class openvpn::setup_server(
  $vpn_name     = 'vpn',
  $country      = 'US',
  $province     = 'Springfield',
  $city         = 'Springfield',
  $organization = 'vpn',
  $email        = 'info@changeme.com',
  $server       = '10.10.0.0 255.255.255.0',
  $ipp          = true,
  $remote_host  = 'vpn.changeme.com',
  $clients      = {}
) {

  package {'openssl': ensure => present}

  openvpn::server { $vpn_name:
    country      => $country,
    province     => $province,
    city         => $city,
    organization => $organization,
    email        => $email,
    server       => $server,
    ipp          => $ipp,
    require      => Package['openssl']
  }

  $clients.each |$client_name, $specific_config| {
    openvpn::client{$client_name:
      server      => $vpn_name,
      remote_host => $remote_host,
    }
    if $specific_config {
      openvpn::client_specific_config {$client_name:
        server            => $vpn_name,
        ifconfig          => $specific_config['ifconfig'],
        redirect_gateway  => $specific_config['redirect_gateway'],
        iroute            => $specific_config['iroute'],
        dhcp_options      => $specific_config['dhcp_options'],
      }
    }
  }
}
