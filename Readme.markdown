# OpenVPN Puppet module

Puppet module to manage OpenVPN servers

## Features:

* Client-specific rules and access policies
* Generated client configurations and SSL-Certificates
* Downloadable client configurations and SSL-Certificates for easy client configuration
* Support for multiple server instances

Tested on Ubuntu Precise Pangolin, CentOS 6, RedHat 6.


## Dependencies
  - [puppet-concat](https://github.com/ripienaar/puppet-concat)


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
* [@elisiano](https://github.com/elisiano)
