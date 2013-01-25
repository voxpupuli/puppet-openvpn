# OpenVPN Puppet module

OpenVPN module for puppet including client config/cert creation (tarball to download)

## Dependencies
  - [puppet-concat](https://github.com/ripienaar/puppet-concat)

## Supported OS
  - Debian Squeeze (should, as it works on Ubuntu Lucid)
  - Ubuntu 10.4, 12.04 (other untested)
  - CentOS, RedHat

## Example

```puppet
  # add a server instance
  openvpn::server { 'winterthur':
    country      => "CH",
    province     => "ZH",
    city         => "Winterthur",
    organization => "example.org",
    email        => "root@example.org",
    server       => '10.200.200.0 255.255.255.0'
  }

  # define clients
  openvpn::client { 'client1':
    server => 'winterthur'
  }
  openvpn::client { 'client2':
    server   => 'winterthur'
  }
  
  openvpn::client_specific_config { 'client1':
    server => 'winterthur',
    ifconfig => '10.200.200.50 255.255.255.0'
  }
```

Don't forget the [sysctl](https://github.com/luxflux/puppet-sysctl) directive ```net.ipv4.ip_forward```!


# Contributors

These fine folks helped to get this far with this module:
* [@jlambert121](https://github.com/jlambert121)
* [@jlk](https://github.com/jlk)
