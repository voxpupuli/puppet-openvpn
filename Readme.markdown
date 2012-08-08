# OpenVPN Puppet module

OpenVPN module for puppet including client config/cert creation (tarball to download)

## Dependencies
  - [puppet-concat](https://github.com/ripienaar/puppet-concat)

## Supported OS
  - Debian Squeeze (should, as it works on Ubuntu Lucid)
  - Ubuntu 10.4, 12.04 (other untested)
  - CentOS

## Example

    # add a server instance
    openvpn::server {
        "server1":
            country      => "CH",
            province     => "ZH",
            city         => "Winterthur",
            organization => "example.org",
            email        => "root@example.org";
    }

    # configure server
    openvpn::option {
        "dev server1":
            key    => "dev",
            value  => "tun0",
            server => "server1";
        "script-security server1":
            key    => "script-security",
            value  => "3",
            server => "server1";
        "daemon server1":
            key    => "daemon",
            server => "server1";
        "keepalive server1":
            key    => "keepalive",
            value  => "10 60",
            server => "server1";
        "ping-timer-rem server1":
            key    => "ping-timer-rem",
            server => "server1";
        "persist-tun server1":
            key    => "persist-tun",
            server => "server1";
        "persist-key server1":
            key    => "persist-key",
            server => "server1";
        "proto server1":
            key    => "proto",
            value  => "tcp-server",
            server => "server1";
        "cipher server1":
            key    => "cipher",
            value  => "BF-CBC",
            server => "server1";
        "local server1":
            key    => "local",
            value  => $ipaddress,
            server => "server1";
        "tls-server server1":
            key    => "tls-server",
            server => "server1";
        "server server1":
            key    => "server",
            value  => "10.10.10.0 255.255.255.0",
            server => "server1";
        "lport server1":
            key    => "lport",
            value  => "1194",
            server => "server1";
        "management server1":
            key    => "management",
            value  => "/var/run/openvpn-server1.sock unix",
            server => "server1";
        "comp-lzo server1":
            key    => "comp-lzo",
            server => "server1";
        "topology server1":
            key    => "topology",
            value  => "subnet",
            server => "server1";
        "client-to-client server1":
            key    => "client-to-client",
            server => "server1";
    }


    # define clients
    openvpn::client {
        [ "client1.example.org", "client2.example.org" ]:
            server      => "server1";
    }

    # add options to the client-config-dir file
    openvpn::option {
        "iroute server1 client1.example.org home network":
            key    => "iroute",
            value  => "192.168.0.0 255.255.255.0",
            client => "client1.example.org",
            server => "server1",
            csc    => true;
    }

    # add an option to the client config
    openvpn::option {
        "ifconfig server1 client2.example.org":
            key    => "ifconfig-push",
            value  => "10.10.10.2 255.255.255.0",
            client => "client2.example.org",
            server => "server1";
    }

Don't forget the [sysctl](https://github.com/luxflux/puppet-sysctl) directive ```net.ipv4.ip_forward```!
