# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v11.0.0](https://github.com/voxpupuli/puppet-openvpn/tree/v11.0.0) (2025-05-08)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v10.3.0...v11.0.0)

Allow puppetlabs/concat version 9.x [\#479](https://github.com/voxpupuli/puppet-openvpn/issues/479)
Add Puppet 8 support [\#478](https://github.com/voxpupuli/puppet-openvpn/issues/478)
Allow puppetlabs/stdlib version 9.x [\#477](https://github.com/voxpupuli/puppet-openvpn/issues/477)

**Breaking changes:**

- Drop Ubuntu 20.04 support [\#475](https://github.com/voxpupuli/puppet-openvpn/pull/475) ([Valantin](https://github.com/Valantin))
- Fix archlinux support [\#471](https://github.com/voxpupuli/puppet-openvpn/pull/471) ([Valantin](https://github.com/Valantin))
- Move to EasyRSA 3 [\#470](https://github.com/voxpupuli/puppet-openvpn/pull/470) ([Valantin](https://github.com/Valantin))
- Drop unsupported RedHat family OS [\#467](https://github.com/voxpupuli/puppet-openvpn/pull/467) ([Valantin](https://github.com/Valantin))
- Drop CentOS and Redhat 7 support [\#456](https://github.com/voxpupuli/puppet-openvpn/pull/456) ([zilchms](https://github.com/zilchms))
- Drop Debian 9 and 10 support [\#455](https://github.com/voxpupuli/puppet-openvpn/pull/455) ([zilchms](https://github.com/zilchms))
- Drop Ubuntu 18.04 support [\#454](https://github.com/voxpupuli/puppet-openvpn/pull/454) ([zilchms](https://github.com/zilchms))
- Drop Puppet 6 support [\#443](https://github.com/voxpupuli/puppet-openvpn/pull/443) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add freebsd release [\#472](https://github.com/voxpupuli/puppet-openvpn/pull/472) ([Valantin](https://github.com/Valantin))
- Add Ubuntu 24.04 support [\#469](https://github.com/voxpupuli/puppet-openvpn/pull/469) ([Valantin](https://github.com/Valantin))
- Add Debian 12 support [\#468](https://github.com/voxpupuli/puppet-openvpn/pull/468) ([Valantin](https://github.com/Valantin))
- Add RedHat 9 family OS [\#466](https://github.com/voxpupuli/puppet-openvpn/pull/466) ([Valantin](https://github.com/Valantin))
- Add OpenVox to metadata.json [\#464](https://github.com/voxpupuli/puppet-openvpn/pull/464) ([jstraw](https://github.com/jstraw))
- Add `route_ipv6` client specific config support [\#451](https://github.com/voxpupuli/puppet-openvpn/pull/451) ([antondollmaier](https://github.com/antondollmaier))

## [v10.3.0](https://github.com/voxpupuli/puppet-openvpn/tree/v10.3.0) (2022-08-24)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v10.2.1...v10.3.0)

**Implemented enhancements:**

- Make ecdh-curve optional [\#436](https://github.com/voxpupuli/puppet-openvpn/pull/436) ([jkroepke](https://github.com/jkroepke))
- Add Ubuntu 22.04 [\#435](https://github.com/voxpupuli/puppet-openvpn/pull/435) ([jkroepke](https://github.com/jkroepke))

## [v10.2.1](https://github.com/voxpupuli/puppet-openvpn/tree/v10.2.1) (2022-06-28)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v10.2.0...v10.2.1)

**Fixed bugs:**

- Fix path for crl\_auto\_renew with easy\_rsa 3.0 [\#437](https://github.com/voxpupuli/puppet-openvpn/pull/437) ([cible](https://github.com/cible))

## [v10.2.0](https://github.com/voxpupuli/puppet-openvpn/tree/v10.2.0) (2022-04-26)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v10.1.0...v10.2.0)

**Implemented enhancements:**

- Add support for easyrsa X509 DN mode 'cn\_only' [\#432](https://github.com/voxpupuli/puppet-openvpn/pull/432) ([jkroepke](https://github.com/jkroepke))
- Add support for elliptic curve keys [\#431](https://github.com/voxpupuli/puppet-openvpn/pull/431) ([jkroepke](https://github.com/jkroepke))

## [v10.1.0](https://github.com/voxpupuli/puppet-openvpn/tree/v10.1.0) (2022-03-28)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v10.0.0...v10.1.0)

**Implemented enhancements:**

- Add basic support for Solaris/Illumos/SmartOS [\#429](https://github.com/voxpupuli/puppet-openvpn/pull/429) ([smokris](https://github.com/smokris))
- Support custom\_options in client\_specific\_config [\#428](https://github.com/voxpupuli/puppet-openvpn/pull/428) ([smokris](https://github.com/smokris))

## [v10.0.0](https://github.com/voxpupuli/puppet-openvpn/tree/v10.0.0) (2022-03-25)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v9.1.0...v10.0.0)

**Breaking changes:**

- Remove openvpn::deploy [\#424](https://github.com/voxpupuli/puppet-openvpn/pull/424) ([jkroepke](https://github.com/jkroepke))
- Replace ns\_cert\_type with remote\_cert\_tls \(\*\*client config regeneration needed\*\*\) [\#415](https://github.com/voxpupuli/puppet-openvpn/pull/415) ([jkroepke](https://github.com/jkroepke))
- Drop Ubuntu 16.04 [\#413](https://github.com/voxpupuli/puppet-openvpn/pull/413) ([jkroepke](https://github.com/jkroepke))
- Disable compression and set cipher to AES-256-GCM by default [\#412](https://github.com/voxpupuli/puppet-openvpn/pull/412) ([jkroepke](https://github.com/jkroepke))
- Use Deferred functions instead facts [\#410](https://github.com/voxpupuli/puppet-openvpn/pull/410) ([jkroepke](https://github.com/jkroepke))

**Implemented enhancements:**

- Allowed openvpn::ca declared in openvpn::server to set crl\_days parameter [\#419](https://github.com/voxpupuli/puppet-openvpn/pull/419) ([Deroin](https://github.com/Deroin))

**Closed issues:**

- Client configurations with the new Deferred function aren't working [\#421](https://github.com/voxpupuli/puppet-openvpn/issues/421)
- Warning: Fact value '...' with the value length: '5274' exceeds the value length limit: 4096 [\#409](https://github.com/voxpupuli/puppet-openvpn/issues/409)
- openvpn facts not generated on server [\#352](https://github.com/voxpupuli/puppet-openvpn/issues/352)
- Fact openvpn exposes private keys [\#322](https://github.com/voxpupuli/puppet-openvpn/issues/322)

**Merged pull requests:**

- Unbreak vagrant [\#422](https://github.com/voxpupuli/puppet-openvpn/pull/422) ([mattock](https://github.com/mattock))

## [v9.1.0](https://github.com/voxpupuli/puppet-openvpn/tree/v9.1.0) (2021-09-18)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v9.0.0...v9.1.0)

**Implemented enhancements:**

- Add Debian 11 support [\#414](https://github.com/voxpupuli/puppet-openvpn/pull/414) ([root-expert](https://github.com/root-expert))

**Closed issues:**

- Latest tags are not really up to date [\#398](https://github.com/voxpupuli/puppet-openvpn/issues/398)
- New release with script-pushing [\#359](https://github.com/voxpupuli/puppet-openvpn/issues/359)

**Merged pull requests:**

- Allow stdlib 8.0.0 [\#408](https://github.com/voxpupuli/puppet-openvpn/pull/408) ([smortex](https://github.com/smortex))

## [v9.0.0](https://github.com/voxpupuli/puppet-openvpn/tree/v9.0.0) (2021-08-09)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v8.3.0...v9.0.0)

**Breaking changes:**

- Drop Puppet 5 support [\#399](https://github.com/voxpupuli/puppet-openvpn/pull/399) ([root-expert](https://github.com/root-expert))
- Drop CentOS 6 support [\#393](https://github.com/voxpupuli/puppet-openvpn/pull/393) ([bastelfreak](https://github.com/bastelfreak))
- Drop EOL Debian 8 support [\#388](https://github.com/voxpupuli/puppet-openvpn/pull/388) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Add Ubuntu 20.04 support [\#401](https://github.com/voxpupuli/puppet-openvpn/pull/401) ([root-expert](https://github.com/root-expert))
- Add Puppet 7 support [\#400](https://github.com/voxpupuli/puppet-openvpn/pull/400) ([root-expert](https://github.com/root-expert))

**Closed issues:**

- FREQ: Please update/certify for Ubuntu 20.04 LTS support please   [\#395](https://github.com/voxpupuli/puppet-openvpn/issues/395)

**Merged pull requests:**

- Update badges in README and regenerate REFERENCE [\#406](https://github.com/voxpupuli/puppet-openvpn/pull/406) ([root-expert](https://github.com/root-expert))
- Change ensure to "installed" instead of "present" in specs [\#405](https://github.com/voxpupuli/puppet-openvpn/pull/405) ([root-expert](https://github.com/root-expert))
- Allow puppetlabs/concat and puppetlabs/stdlib 7.x [\#404](https://github.com/voxpupuli/puppet-openvpn/pull/404) ([root-expert](https://github.com/root-expert))
- Fix typo [\#397](https://github.com/voxpupuli/puppet-openvpn/pull/397) ([itzwam](https://github.com/itzwam))
- fix\(client\): Handle expire value for easyrsa version 3 [\#392](https://github.com/voxpupuli/puppet-openvpn/pull/392) ([Turgon37](https://github.com/Turgon37))

## [v8.3.0](https://github.com/voxpupuli/puppet-openvpn/tree/v8.3.0) (2020-10-20)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v8.2.0...v8.3.0)

Debian 8 is end of life since a few months. We do not support EOL operating systems. This is the last puppet-openvpn release with Debian 8 support. Afterwards we will do a 9.0.0 release which only supports Debian 9 and 10.

**Implemented enhancements:**

- Update code to set status parameter optional [\#385](https://github.com/voxpupuli/puppet-openvpn/pull/385) ([smutel](https://github.com/smutel))
- Add Debian Buster support [\#379](https://github.com/voxpupuli/puppet-openvpn/pull/379) ([NITEMAN](https://github.com/NITEMAN))
- Enable revocation when easyrsa version 3.0 is used [\#369](https://github.com/voxpupuli/puppet-openvpn/pull/369) ([Rubueno](https://github.com/Rubueno))
- Add RHEL 8 support [\#364](https://github.com/voxpupuli/puppet-openvpn/pull/364) ([yakatz](https://github.com/yakatz))
- Add remote-random and remote-random-hostname to managed server parameters [\#363](https://github.com/voxpupuli/puppet-openvpn/pull/363) ([yakatz](https://github.com/yakatz))
- Add debian buster to collect easyrsa fact [\#362](https://github.com/voxpupuli/puppet-openvpn/pull/362) ([smutel](https://github.com/smutel))
- Optionally manage logfile parent directory [\#343](https://github.com/voxpupuli/puppet-openvpn/pull/343) ([Bluewind](https://github.com/Bluewind))
- Add scripts with server [\#339](https://github.com/voxpupuli/puppet-openvpn/pull/339) ([yakatz](https://github.com/yakatz))

**Fixed bugs:**

- Fixes \#374 - Revocation command update and crl renew [\#375](https://github.com/voxpupuli/puppet-openvpn/pull/375) ([Rubueno](https://github.com/Rubueno))
- Update server.erb - fix proto for tcp client mode [\#349](https://github.com/voxpupuli/puppet-openvpn/pull/349) ([jimirocks](https://github.com/jimirocks))

**Closed issues:**

- Problem while revoking certificate [\#374](https://github.com/voxpupuli/puppet-openvpn/issues/374)
- Revoke command missing on easy-rsa 3.0 [\#331](https://github.com/voxpupuli/puppet-openvpn/issues/331)

**Merged pull requests:**

- Repair link to REFERENCE.md in README.md [\#366](https://github.com/voxpupuli/puppet-openvpn/pull/366) ([gabe-sky](https://github.com/gabe-sky))
- drop Ubuntu 14.04 support [\#361](https://github.com/voxpupuli/puppet-openvpn/pull/361) ([bastelfreak](https://github.com/bastelfreak))
- Clean up acceptance spec helper [\#356](https://github.com/voxpupuli/puppet-openvpn/pull/356) ([ekohl](https://github.com/ekohl))
- cleanup types in openvpn::client\_specific\_config [\#342](https://github.com/voxpupuli/puppet-openvpn/pull/342) ([bastelfreak](https://github.com/bastelfreak))

## [v8.2.0](https://github.com/voxpupuli/puppet-openvpn/tree/v8.2.0) (2019-07-19)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v8.1.0...v8.2.0)

**Implemented enhancements:**

- Add tls\_crypt [\#334](https://github.com/voxpupuli/puppet-openvpn/pull/334) ([jkroepke](https://github.com/jkroepke))
- Adjust clients $compression type to match servers [\#333](https://github.com/voxpupuli/puppet-openvpn/pull/333) ([jkroepke](https://github.com/jkroepke))
- client\_specific\_config: add support for ifconfig-ipv6-push [\#235](https://github.com/voxpupuli/puppet-openvpn/pull/235) ([invidian](https://github.com/invidian))

**Fixed bugs:**

- Apparently openvpn 2.4 needs double quotes around client specific push options [\#329](https://github.com/voxpupuli/puppet-openvpn/issues/329)
- Only output ldap\_tls\_client\_cert\_file and ldap\_tls\_client\_key\_file when set [\#341](https://github.com/voxpupuli/puppet-openvpn/pull/341) ([Bluewind](https://github.com/Bluewind))
- Allow puppetlabs/concat 6.x, puppetlabs/stdlib 6.x [\#340](https://github.com/voxpupuli/puppet-openvpn/pull/340) ([dhoppe](https://github.com/dhoppe))
- use double quotes on all push options [\#330](https://github.com/voxpupuli/puppet-openvpn/pull/330) ([qs5779](https://github.com/qs5779))

**Closed issues:**

- var renaming overlooked KEY\_DIR =\> EASYRSA\_PKI [\#336](https://github.com/voxpupuli/puppet-openvpn/issues/336)

**Merged pull requests:**

- Add option to disable ordering dependencies on Openvpn::Client [\#344](https://github.com/voxpupuli/puppet-openvpn/pull/344) ([Bluewind](https://github.com/Bluewind))
- Updated KEY\_DIR to match new variable [\#337](https://github.com/voxpupuli/puppet-openvpn/pull/337) ([xepa](https://github.com/xepa))
- Use stdlib functions for hash key discovery [\#324](https://github.com/voxpupuli/puppet-openvpn/pull/324) ([towo](https://github.com/towo))

## [v8.1.0](https://github.com/voxpupuli/puppet-openvpn/tree/v8.1.0) (2019-02-03)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v8.0.0...v8.1.0)

**Fixed bugs:**

- Allow 4 and 6 suffix inside proto to limit ip4 or ip6 connection only. [\#327](https://github.com/voxpupuli/puppet-openvpn/pull/327) ([jkroepke](https://github.com/jkroepke))

## [v8.0.0](https://github.com/voxpupuli/puppet-openvpn/tree/v8.0.0) (2019-01-29)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v7.4.0...v8.0.0)

**Breaking changes:**

- modulesync 2.5.1 and drop Puppet 4 support [\#325](https://github.com/voxpupuli/puppet-openvpn/pull/325) ([bastelfreak](https://github.com/bastelfreak))
- Data in Modules, Modern facts & Cleanup [\#305](https://github.com/voxpupuli/puppet-openvpn/pull/305) ([jkroepke](https://github.com/jkroepke))

**Implemented enhancements:**

- Timeout when generating Diffie-Hellman  parameters on a low-performance CPU [\#316](https://github.com/voxpupuli/puppet-openvpn/issues/316)
- Implement Ubuntu 18.04 support [\#306](https://github.com/voxpupuli/puppet-openvpn/issues/306)
- Should be an option to install openvpn from http://swupdate.openvpn.net/ repo [\#218](https://github.com/voxpupuli/puppet-openvpn/issues/218)
- Set DH timeout to accommodate low performance CPU [\#317](https://github.com/voxpupuli/puppet-openvpn/pull/317) ([dspinellis](https://github.com/dspinellis))

**Fixed bugs:**

- crl auto renewal broken with easyrsa 3.0 [\#318](https://github.com/voxpupuli/puppet-openvpn/issues/318)
- consider the easyrsa version to trigger the renew crl command [\#321](https://github.com/voxpupuli/puppet-openvpn/pull/321) ([Dan33l](https://github.com/Dan33l))

**Closed issues:**

- New release ? [\#323](https://github.com/voxpupuli/puppet-openvpn/issues/323)
- Non-executable easy-rsa files cause module to fail [\#313](https://github.com/voxpupuli/puppet-openvpn/issues/313)
- Do not fail fatal if OS is unsupported. [\#304](https://github.com/voxpupuli/puppet-openvpn/issues/304)
- Failures after upgrade [\#303](https://github.com/voxpupuli/puppet-openvpn/issues/303)
- OpenVPN is now generating blank/empty user certificates [\#225](https://github.com/voxpupuli/puppet-openvpn/issues/225)

**Merged pull requests:**

- updated documentation to conform with REFERENCE.md standard for forge [\#311](https://github.com/voxpupuli/puppet-openvpn/pull/311) ([danquack](https://github.com/danquack))
- add acceptance tests with real vpn client/server setup [\#310](https://github.com/voxpupuli/puppet-openvpn/pull/310) ([Dan33l](https://github.com/Dan33l))
- modulesync 2.2.0 and allow puppet 6.x [\#299](https://github.com/voxpupuli/puppet-openvpn/pull/299) ([bastelfreak](https://github.com/bastelfreak))

## [v7.4.0](https://github.com/voxpupuli/puppet-openvpn/tree/v7.4.0) (2018-10-16)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v7.3.0...v7.4.0)

**Implemented enhancements:**

- update supported OSes in params.pp [\#296](https://github.com/voxpupuli/puppet-openvpn/pull/296) ([Dan33l](https://github.com/Dan33l))
- use new fact easyrsa to configure easyrsa 2 or 3 [\#292](https://github.com/voxpupuli/puppet-openvpn/pull/292) ([Dan33l](https://github.com/Dan33l))

**Fixed bugs:**

- Support for easy-rsa version 3 [\#216](https://github.com/voxpupuli/puppet-openvpn/issues/216)

**Closed issues:**

- debian 7 support broken [\#291](https://github.com/voxpupuli/puppet-openvpn/issues/291)
- Epel has upgraded `easy-rsa` to version 3.x and removed 2.x, breaking the module [\#269](https://github.com/voxpupuli/puppet-openvpn/issues/269)

**Merged pull requests:**

- FreeBSD: change additional\_packages to easy-rsa2 [\#301](https://github.com/voxpupuli/puppet-openvpn/pull/301) ([olevole](https://github.com/olevole))
- Update puppetlabs-stdlib dependency version in README [\#298](https://github.com/voxpupuli/puppet-openvpn/pull/298) ([simonrondelez](https://github.com/simonrondelez))
- move concat version\_requirement to \>= 3.0.0 \< 6.0.0 [\#294](https://github.com/voxpupuli/puppet-openvpn/pull/294) ([Dan33l](https://github.com/Dan33l))
- allow puppetlabs/stdlib 5.x [\#290](https://github.com/voxpupuli/puppet-openvpn/pull/290) ([bastelfreak](https://github.com/bastelfreak))
- Remove deprecated hiera\_hash [\#289](https://github.com/voxpupuli/puppet-openvpn/pull/289) ([Dan33l](https://github.com/Dan33l))
- Remove deprecated hiera\_hash [\#276](https://github.com/voxpupuli/puppet-openvpn/pull/276) ([jkroepke](https://github.com/jkroepke))

## [v7.3.0](https://github.com/voxpupuli/puppet-openvpn/tree/v7.3.0) (2018-08-18)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v7.2.0...v7.3.0)

**Implemented enhancements:**

- Allow management\_port to be a string; require stdlib \>= 4.25.0 [\#275](https://github.com/voxpupuli/puppet-openvpn/pull/275) ([marieof9](https://github.com/marieof9))

**Fixed bugs:**

- Configuring management unix socket is no longer possible [\#274](https://github.com/voxpupuli/puppet-openvpn/issues/274)
- openvpn::server, documentation doesn't match the code for parameter 'port' [\#272](https://github.com/voxpupuli/puppet-openvpn/issues/272)

**Merged pull requests:**

- Remove docker nodesets [\#282](https://github.com/voxpupuli/puppet-openvpn/pull/282) ([bastelfreak](https://github.com/bastelfreak))
- drop EOL OSs; fix puppet version range [\#280](https://github.com/voxpupuli/puppet-openvpn/pull/280) ([bastelfreak](https://github.com/bastelfreak))
- Changed type for port in class documentation [\#273](https://github.com/voxpupuli/puppet-openvpn/pull/273) ([clxnetom](https://github.com/clxnetom))

## [v7.2.0](https://github.com/voxpupuli/puppet-openvpn/tree/v7.2.0) (2018-03-17)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v7.1.0...v7.2.0)

**Implemented enhancements:**

- Allow to define remote-cert-tls [\#266](https://github.com/voxpupuli/puppet-openvpn/pull/266) ([jkroepke](https://github.com/jkroepke))

**Fixed bugs:**

- Bug Fix: Ensure cipher and tls\_cipher can be disabled entirely [\#270](https://github.com/voxpupuli/puppet-openvpn/pull/270) ([jcarr-sailthru](https://github.com/jcarr-sailthru))

**Closed issues:**

- Looking for Maintainers [\#228](https://github.com/voxpupuli/puppet-openvpn/issues/228)

## [v7.1.0](https://github.com/voxpupuli/puppet-openvpn/tree/v7.1.0) (2018-01-11)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v7.0.0...v7.1.0)

**Implemented enhancements:**

- add openvpn::deploy::\(export/client\) [\#261](https://github.com/voxpupuli/puppet-openvpn/pull/261) ([to-kn](https://github.com/to-kn))

**Closed issues:**

- Elegant solution for renewing CRL [\#236](https://github.com/voxpupuli/puppet-openvpn/issues/236)

## [v7.0.0](https://github.com/voxpupuli/puppet-openvpn/tree/v7.0.0) (2018-01-06)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v6.0.0...v7.0.0)

**Breaking changes:**

- add datatypes to all params [\#259](https://github.com/voxpupuli/puppet-openvpn/pull/259) ([to-kn](https://github.com/to-kn))

**Implemented enhancements:**

- Add crl renewal [\#256](https://github.com/voxpupuli/puppet-openvpn/pull/256) ([to-kn](https://github.com/to-kn))

## [v6.0.0](https://github.com/voxpupuli/puppet-openvpn/tree/v6.0.0) (2017-11-21)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v5.0.0...v6.0.0)

**Breaking changes:**

- Turned up options for encryption [\#223](https://github.com/voxpupuli/puppet-openvpn/pull/223) ([mcrmonkey](https://github.com/mcrmonkey))

**Fixed bugs:**

- Doesn't work properly with "remote" in openvpn::server [\#252](https://github.com/voxpupuli/puppet-openvpn/issues/252)
- Correct 252 [\#253](https://github.com/voxpupuli/puppet-openvpn/pull/253) ([cjeanneret](https://github.com/cjeanneret))

**Merged pull requests:**

- replace validate\_\* with datatypes in init.pp [\#251](https://github.com/voxpupuli/puppet-openvpn/pull/251) ([bastelfreak](https://github.com/bastelfreak))

## [v5.0.0](https://github.com/voxpupuli/puppet-openvpn/tree/v5.0.0) (2017-11-13)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v4.1.1...v5.0.0)

**Breaking changes:**

- Breaking: Update puppet, stdlib, and concat requirements in prep for release [\#242](https://github.com/voxpupuli/puppet-openvpn/pull/242) ([wyardley](https://github.com/wyardley))

**Implemented enhancements:**

- Upped version requirement of concat and added Debian 9 \(stretch\) [\#243](https://github.com/voxpupuli/puppet-openvpn/pull/243) ([hp197](https://github.com/hp197))

## [v4.1.1](https://github.com/voxpupuli/puppet-openvpn/tree/v4.1.1) (2017-10-07)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/v4.1.0...v4.1.1)

## [v4.1.0](https://github.com/voxpupuli/puppet-openvpn/tree/v4.1.0) (2017-10-06)

[Full Changelog](https://github.com/voxpupuli/puppet-openvpn/compare/4.0.1...v4.1.0)

**Closed issues:**

- Install openvpn & certs also on client nodes [\#231](https://github.com/voxpupuli/puppet-openvpn/issues/231)
- Download config has incorrect protocol [\#219](https://github.com/voxpupuli/puppet-openvpn/issues/219)
- Error while evaluating a Function Call, cannot currently create client configs when corresponding openvpn::server is extca\_enabled [\#199](https://github.com/voxpupuli/puppet-openvpn/issues/199)

**Merged pull requests:**

- Fix auth tls ovpn profile and ldap auth file perms [\#220](https://github.com/voxpupuli/puppet-openvpn/pull/220) ([szponek](https://github.com/szponek))
- Correct path of openvpn-auth-pam.so on modern Debian distros. [\#217](https://github.com/voxpupuli/puppet-openvpn/pull/217) ([oc243](https://github.com/oc243))
- Add rhel6 support for ldap auth plugin [\#215](https://github.com/voxpupuli/puppet-openvpn/pull/215) ([miguelwhite](https://github.com/miguelwhite))
- fix broken namespecific rclink [\#209](https://github.com/voxpupuli/puppet-openvpn/pull/209) ([alxwr](https://github.com/alxwr))

## 4.0.1 (2016-09-25)

* Fix namespecific_rclink variable warning for non BSD systems ([#214](https://github.com/luxflux/puppet-openvpn/pull/214))

## 4.0.0

* Workaround for [MODULES-2874](https://tickets.puppetlabs.com/browse/MODULES-2874) ([#201](https://github.com/luxflux/puppet-openvpn/pull/201))
* Fix for [external CA handling with exported resources](https://github.com/luxflux/puppet-openvpn/pull/200) ([#201](https://github.com/luxflux/puppet-openvpn/pull/201))
* Drop Support for Puppet 3.x ([#212](https://github.com/luxflux/puppet-openvpn/pull/212))

## 3.1.0

* Support for FreeBSD ([#180](https://github.com/luxflux/puppet-openvpn/pull/180))
* Support for port-share ([#182](https://github.com/luxflux/puppet-openvpn/issues/182)/[#185](https://github.com/luxflux/puppet-openvpn/pull/185))
* Support for pre-shared keys ([#186](https://github.com/luxflux/puppet-openvpn/pull/186))
* Support LDAP anonymous binds ([#189](https://github.com/luxflux/puppet-openvpn/pull/189))
* Fix `.ovpn` files generation ([#190](https://github.com/luxflux/puppet-openvpn/pull/190))
* Support for external CAs ([#192](https://github.com/luxflux/puppet-openvpn/pull/192))
* Small Typo fix ([#192](https://github.com/luxflux/puppet-openvpn/pull/193))
* Fix support for Amazon Linux ([#194](https://github.com/luxflux/puppet-openvpn/pull/194))
* Client `pull` option ([#195](https://github.com/luxflux/puppet-openvpn/pull/195))
* Allow `remote_host` to be an array of servers ([#195](https://github.com/luxflux/puppet-openvpn/pull/195))
* More robust Shared CA handling ([#191](https://github.com/luxflux/puppet-openvpn/pull/191), [#196](https://github.com/luxflux/puppet-openvpn/pull/196))

## 3.0.0

* Support for Ubuntu 15.04 ([#168](https://github.com/luxflux/puppet-openvpn/pull/168))
* Support for specifying TLS-Cipher ([#169](https://github.com/luxflux/puppet-openvpn/pull/169))
* Support for specifying custom certificate expiry ([#169](https://github.com/luxflux/puppet-openvpn/pull/169))
* Support for README in download configs ([#169](https://github.com/luxflux/puppet-openvpn/pull/169))
* Support for Tunnelblick configurations ([#169](https://github.com/luxflux/puppet-openvpn/pull/169))
* Fix certificate revocation in Ubuntu Precise ([#169](https://github.com/luxflux/puppet-openvpn/pull/169))
* Use concat for ovpn generation ([#176](https://github.com/luxflux/puppet-openvpn/pull/176))

## 2.9.0

This will be the last version of version 2.x with new features.

* Support to send ipv6 routes ([#153](https://github.com/luxflux/puppet-openvpn/pull/153), [#154](https://github.com/luxflux/puppet-openvpn/pull/154))
* Support for `nobind` param for server in client mode ([#156](https://github.com/luxflux/puppet-openvpn/pull/156))
* Fixing autostart_all behaviour ([#163](https://github.com/luxflux/puppet-openvpn/pull/163))
* Add systemd support for Debian >= 8.0 ([#161](https://github.com/luxflux/puppet-openvpn/pull/161))
* Support for Archlinux ([#162](https://github.com/luxflux/puppet-openvpn/pull/162))
* Support to enable/disable service management([#158](https://github.com/luxflux/puppet-openvpn/pull/158))
* Fix installation for older Redhat based systems ([#165](https://github.com/luxflux/puppet-openvpn/pull/165))
* Add ability to specify custom options for clients ([#167](https://github.com/luxflux/puppet-openvpn/pull/167))

## 2.8.0

* Support for systems without `lsb-release` package ([#134](https://github.com/luxflux/puppet-openvpn/pull/134))
* Support for Amazon EC2 OS ([#134](https://github.com/luxflux/puppet-openvpn/pull/134))
* Move default log path for status log to `/var/log/openvpn` ([#139](https://github.com/luxflux/puppet-openvpn/pull/139))
* Support for `format` parameter ([#138](https://github.com/luxflux/puppet-openvpn/pull/138))
* Ability to configure autostart management on debian ([#144](https://github.com/luxflux/puppet-openvpn/pull/144))
* Fix ordering in `/etc/default/openvpn` with puppet future parser ([#142](https://github.com/luxflux/puppet-openvpn/issues/142)
* Support for TLS auth when server acts as client ([#147](https://github.com/luxflux/puppet-openvpn/pull/147))
* Support for customer server options ([#147](https://github.com/luxflux/puppet-openvpn/pull/147))
* Allow disabling `ns-cert-type server` for server-clients ([#147](https://github.com/luxflux/puppet-openvpn/pull/147))
* Fix pam plugin path on RedHat/CentOS ([#148](https://github.com/luxflux/puppet-openvpn/pull/148))

## 2.7.1

* Fix server in client mode ([#137](https://github.com/luxflux/puppet-openvpn/pull/137))

## 2.7.0

* Support for removing a client specific conf file ([#115](https://github.com/luxflux/puppet-openvpn/pull/115))
* Support for `rcvbuf` and `sndbuf` ([#116](https://github.com/luxflux/puppet-openvpn/pull/116))
* Fix RedHat and CentOS package selection ([#97](https://github.com/luxflux/puppet-openvpn/pull/97))
* Support for TLS and x509-name verification ([#118](https://github.com/luxflux/puppet-openvpn/pull/118))
* Fix unset client cipher producing invalid configs ([#129](https://github.com/luxflux/puppet-openvpn/pull/129))
* Support to share a CA between multiple server instances ([#112](https://github.com/luxflux/puppet-openvpn/pull/112))
* Support for systemd ([#127](https://github.com/luxflux/puppet-openvpn/pull/127))

## 2.6.0

* Support for setting `up` and/or `down` scripts for clients  ([#89](https://github.com/luxflux/puppet-openvpn/pull/89))
* Fixing the permissions of the created directories and files ([#90](https://github.com/luxflux/puppet-openvpn/pull/90), [#92](https://github.com/luxflux/puppet-openvpn/pull/92), [#94](https://github.com/luxflux/puppet-openvpn/pull/94), [#102](https://github.com/luxflux/puppet-openvpn/pull/102))
* Refactor templates to use instance variables instead of `scope.lookupvar` ([#100](https://github.com/luxflux/puppet-openvpn/pull/100))
* Add client mode server ([#100](https://github.com/luxflux/puppet-openvpn/pull/100))
* Move CA management into its own defined type ([#100](https://github.com/luxflux/puppet-openvpn/pull/100))
* Fix LDAP-Support on Debian Wheezy ([#103](https://github.com/luxflux/puppet-openvpn/pull/103))
* Support for status-version ([#108](https://github.com/luxflux/puppet-openvpn/pull/108))
* Change layout of downloadable client config to prevent overriding other client configurations when extracting the tarball ([#104](https://github.com/luxflux/puppet-openvpn/pull/104))
* Add `ns-cert-type server` for server-clients ([#109](https://github.com/luxflux/puppet-openvpn/pull/109))

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


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
