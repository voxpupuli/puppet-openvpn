#
# @summary Base profile
#
class openvpn::deploy::service {
  service { 'openvpn':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true;
  }
}
