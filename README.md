# OpenVPN Puppet module

[![License](https://img.shields.io/github/license/voxpupuli/puppet-openvpn.svg)](https://github.com/voxpupuli/puppet-openvpn/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/voxpupuli/puppet-openvpn.svg?branch=master)](https://travis-ci.org/voxpupuli/puppet-openvpn)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-openvpn/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-openvpn)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/openvpn.svg)](https://forge.puppetlabs.com/puppet/openvpn)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/openvpn.svg)](https://forge.puppetlabs.com/puppet/openvpn)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/openvpn.svg)](https://forge.puppetlabs.com/puppet/openvpn)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/openvpn.svg)](https://forge.puppetlabs.com/puppet/openvpn)

Puppet module to manage OpenVPN servers and clients.

## Features

* Client-specific rules and access policies
* Generated client configurations and SSL-Certificates
* Downloadable client configurations and SSL-Certificates for easy client configuration
* Support for multiple server instances
* Support for LDAP-Authentication
* Support for server instance in client mode
* Support for TLS

## Supported OS

* Ubuntu
* Debian
* CentOS
* RedHat
* Amazon

## Dependencies
  - [puppetlabs-concat 3.0.0+](https://github.com/puppetlabs/puppetlabs-concat)
  - [puppetlabs-stdlib 4.13.1+](https://github.com/puppetlabs/puppetlabs-stdlib)

## Puppet

* Version >= 4.7.1

## Example

```puppet
  # add a server instance
  openvpn::server { 'winterthur':
    country      => 'CH',
    province     => 'ZH',
    city         => 'Winterthur',
    organization => 'example.org',
    email        => 'root@example.org',
    server       => '10.200.200.0 255.255.255.0',
  }

  # define clients
  openvpn::client { 'client1':
    server => 'winterthur',
  }
  openvpn::client { 'client2':
    server   => 'winterthur',
  }

  openvpn::client_specific_config { 'client1':
    server => 'winterthur',
    ifconfig => '10.200.200.50 10.200.200.51',
  }

  # a revoked client
  openvpn::client { 'client3':
    server => 'winterthur',
  }
  openvpn::revoke { 'client3':
    server => 'winterthur',
  }

  # a server in client mode
  file {
    '/etc/openvpn/zurich/keys/ca.crt':
      source => 'puppet:///path/to/ca.crt';
    '/etc/openvpn/zurich/keys/zurich.crt':
      source => 'puppet:///path/to/zurich.crt';
    '/etc/openvpn/zurich/keys/zurich.key':
      source => 'puppet:///path/to/zurich.key';
  }
  openvpn::server { 'zurich':
    remote  => [ 'mgmtnet3.nine.ch 1197', 'mgmtnet2.nine.ch 1197' ],
    require => [ File['/etc/openvpn/zurich/keys/ca.crt'],
                 File['/etc/openvpn/zurich/keys/zurich.crt'],
                 File['/etc/openvpn/zurich/keys/zurich.key'] ];

  }
```

## Example with hiera

```yaml
---
classes:
  - openvpn

openvpn::servers:
  'winterthur':
    country: 'CH'
    province: 'ZH'
    city: 'Winterthur'
    organization: 'example.org'
    email: 'root@example.org'
    server: '10.200.200.0 255.255.255.0'

openvpn::client_defaults:
  server: 'winterthur'

openvpn::clients:
  'client1': {}
  'client2': {}
  'client3': {}

openvpn::client_specific_configs:
  'client1':
    server: 'winterthur'
    ifconfig: '10.200.200.50 10.200.200.51'

openvpn::revokes:
  'client3':
    server: 'winterthur'
```

Don't forget the sysctl directive ```net.ipv4.ip_forward```!

## Encryption Choices

This module provides certain default parameters for the openvpn encryption
settings.

These settings have been applied in line with current "best practices" but no
guarantee is given for their saftey and they could change in future.

You should double check these settings yourself to make sure they are suitable for your needs and in line with current best practices.

## Example for automating client deployment to nodes managed by Puppet

Exporting the configurations for a client in the VPN server manifest:
```
  openvpn::deploy::export { 'client1':
    server => 'winterthur',
  }
```
Installation, configuration and starting the OpenVPN client in a configured node manifest:
```
  openvpn::deploy::client { 'client1':
    server => 'winterthur',
  }
```

##### References

* The readme file of [github.com/Angristan/OpenVPN-install](https://github.com/Angristan/OpenVPN-install/tree/f47fc795d5e2d53f74431aadc58ef9de5784103a) outlines some of reasoning behind
such choices.

* The OpenVPN documentation about the [SWEET32](https://community.openvpn.net/openvpn/wiki/SWEET32) attack gives some reasons and
recommendations for which ciphers to use.

* The OpenVPN [hardening documentation](https://community.openvpn.net/openvpn/wiki/Hardening) also gives further examples

### ssl_key_size

The default key size is now set to `2048` bits.
This setting also affects the size of the dhparam file.

##### Why

> 2048 bits is OK, but both [NSA](https://cryptome.org/2016/01/CNSA-Suite-and-Quantum-Computing-FAQ.pdf) and [ANSSI](https://www.ssi.gouv.fr/uploads/2015/01/RGS_v-2-0_B1.pdf) recommend at least a 3072 bits for a future-proof key. As the size of the key will have an impact on speed, I leave the choice to use 2048, 3072 or 4096 bits RSA key. 4096 bits is what's most used and recommened today, but 3072 bits is still good.



### Cipher

The default data channel cipher is now set to `AES-256-CBC`

##### Why

OpenVPN was setting its default value to `BF-CBC`. In newer versions of OpenVPN
it warns that this is no longer a secure cipher.
The OpenVPN documentation recommends using this setting.



### tls_cipher

The default tls_cipher option is now set to: `TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256`

##### Why

Details of these ciphers and their uses can be found in the documentation links
above.



## Contributions

This module is maintained by [Vox Pupuli](https://voxpupuli.org/). Voxpupuli
welcomes new contributions to this module, especially those that include
documentation and rspec tests. We are happy to provide guidance if necessary.

Please see [CONTRIBUTING](.github/CONTRIBUTING.md) for more details.

### Authors

* Raffael Schmid <raffael@yux.ch>
* Vox Pupuli Team
