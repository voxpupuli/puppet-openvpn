#
# @summary This class sets up the openvpn enviornment as well as the default config file
#
class openvpn::config {

  if $facts['os']['family'] == 'Debian' {
    concat { '/etc/default/openvpn':
      owner => root,
      group => 0,
      mode  => '0644',
      warn  => true,
    }

    concat::fragment { 'openvpn.default.header':
      content => template('openvpn/etc-default-openvpn.erb'),
      target  => '/etc/default/openvpn',
      order   => '01',
    }
  }
}
