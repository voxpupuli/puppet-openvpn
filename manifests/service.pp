#
# @summary This class maintains the openvpn service.
#
class openvpn::service {
  if $openvpn::manage_service and !$openvpn::namespecific_rclink {
    service { 'openvpn':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true,
    }
  }
}
