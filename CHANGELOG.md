# Changelog

## Next version

* Support for setting `up` and/or `down` scripts for clients  ([#89](https://github.com/luxflux/puppet-openvpn/pull/89))
* Fixing the permissions of the created directories and files ([#90](https://github.com/luxflux/puppet-openvpn/pull/90), [#92](https://github.com/luxflux/puppet-openvpn/pull/92), [#94](https://github.com/luxflux/puppet-openvpn/pull/94))
* Refactor templates to use instance variables instead of `scope.lookupvar` ([#100](https://github.com/luxflux/puppet-openvpn/pull/100))
* Add client mode server ([#100](https://github.com/luxflux/puppet-openvpn/pull/100))
* Move CA management into its own defined type ([#100](https://github.com/luxflux/puppet-openvpn/pull/100))

## 2.5.0

* Do not include deprecated `concat::setup` anymore ([#71](https://github.com/luxflux/puppet-openvpn/pull/71))
* Only warn about pam deprecation if it's used ([#72](https://github.com/luxflux/puppet-openvpn/pull/72))
* Ability to specify a `down` script ([#75](https://github.com/luxflux/puppet-openvpn/pull/75))
* Support for `client-cert-not-required` in server config ([#76](https://github.com/luxflux/puppet-openvpn/pull/76))
* Support for `auth-retry` in client config ([#76](https://github.com/luxflux/puppet-openvpn/pull/76))
* Support for `setenv` in client config ([#79](https://github.com/luxflux/puppet-openvpn/pull/79))
* Support for `setenv_safe` in client config ([#79](https://github.com/luxflux/puppet-openvpn/pull/79))
* Support for `cipher` in client config ([#80](https://github.com/luxflux/puppet-openvpn/pull/80))
* Support for `push route` in client specific config ([#80](https://github.com/luxflux/puppet-openvpn/pull/80))

## 2.4.0

### Bugfixes
* Fix Ubuntu Trusty support ([#64](https://github.com/luxflux/puppet-openvpn/pull/64))

### New Features
* Basic support to hand out IPv6 addresses ([#66](https://github.com/luxflux/puppet-openvpn/pull/66))
* Ability to specify the common name of a server ([#65](https://github.com/luxflux/puppet-openvpn/pull/65))
* Options for KEY_EXPIRE, CA_EXPIRE, KEY_NAME, KEY_OU, KEY_CN easy-rsa vars. ([#58](https://github.com/luxflux/puppet-openvpn/pull/58), [#70](https://github.com/luxflux/puppet-openvpn/pull/70))
* Options for cipher, verb, persist-key, persist-tun server directives. ([#58](https://github.com/luxflux/puppet-openvpn/pull/58), [#70](https://github.com/luxflux/puppet-openvpn/pull/70))


## Before

* A lot of stuff I don't know anymore :disappointed:
