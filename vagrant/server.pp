node default {
  openvpn::server { 'winterthur':
    country      => 'CH',
    province     => 'ZH',
    city         => 'Winterthur',
    organization => 'example.org',
    email        => 'root@example.org',
    local        => '192.168.61.10',
    server       => '10.200.200.0 255.255.255.0',
  }

  openvpn::client { 'client1':
    server      => 'winterthur',
    remote_host => '192.168.61.10',
  }

  openvpn::client_specific_config { 'client1':
    server   => 'winterthur',
    ifconfig => '10.200.200.100 255.255.255.0',
  }

  openvpn::client { 'client2':
    server      => 'winterthur',
    remote_host => '192.168.61.10',
  }

  openvpn::client { 'client3':
    server      => 'winterthur',
    remote_host => '192.168.61.10',
  }

  openvpn::revoke { 'client3':
    server => 'winterthur',
  }
}
