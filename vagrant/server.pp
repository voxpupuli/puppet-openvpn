node default {
  openvpn::server { 'winterthur':
    country      => 'CH',
    province     => 'ZH',
    city         => 'Winterthur',
    organization => 'example.org',
    email        => 'root@example.org',
    server       => '10.200.200.0 255.255.255.0'
  }

  openvpn::client { 'client1':
    server => 'winterthur';
  }

  openvpn::client_specific_config { 'client1':
    server   => 'winterthur',
    ifconfig => '10.200.200.100 255.255.255.0'
  }

  openvpn::client { 'client2':
    server => 'winterthur';
  }

  openvpn::client { 'client3':
    server => 'winterthur';
  }

  openvpn::revoke { 'client3':
    server => 'winterthur';
  }
}
