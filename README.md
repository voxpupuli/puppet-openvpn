# OpenVPN Puppet module

Puppet module to manage OpenVPN servers

## Features

* Client-specific rules and access policies
* Generated client configurations and SSL-Certificates
* Downloadable client configurations and SSL-Certificates for easy client configuration
* Support for multiple server instances
* Support for LDAP-Authentication

## Supported OS

* Ubuntu
* Debian
* CentOS
* RedHat


## Dependencies
  - [puppetlabs-concat 1.0.0+](https://github.com/puppetlabs/puppet-concat)


## Example

```puppet
  # add a server instance
  openvpn::server { 'winterthur':
    country      => 'CH',
    province     => 'ZH',
    city         => 'Winterthur',
    organization => 'example.org',
    email        => 'root@example.org',
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
    ifconfig => '10.200.200.50 10.200.200.51'
  }

  # a revoked client
  openvpn::client { 'client3':
    server => 'winterthur',
  }
  openvpn::revoke { 'client3':
    server => 'winterthur',
  }
```

Don't forget the sysctl directive ```net.ipv4.ip_forward```!


# Contributions

Pull requests are very welcome. Join [these fine folks](https://github.com/luxflux/puppet-openvpn/graphs/contributors) who already helped to get this far with this module.

Make sure to add tests to your pull request. **Contributions will not be accepted without tests.**
