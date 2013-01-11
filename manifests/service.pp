# == Class: openvpn::config
#
# This class maintains the openvpn service
#
#
# === Examples
#
# This class should not be directly invoked
#
# === Authors
#
# * Raffael Schmid <mailto:raffael@yux.ch>
# * John Kinsella <mailto:jlkinsel@gmail.com>
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class openvpn::service {
  service {
    'openvpn':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true;
  }
}