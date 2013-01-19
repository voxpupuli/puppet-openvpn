class openvpn::params {

  $group = $::osfamily ? {
    'RedHat' => 'nobody',
    default  => 'nogroup'
  }

  $easyrsa_source = $::osfamily ? {
    'RedHat'  => '/usr/share/doc/openvpn-2.2.2/easy-rsa/2.0',
    default   => '/usr/share/doc/openvpn/examples/easy-rsa/2.0'
  }

  $link_openssl_cnf = $::osfamily ? {
    /(Debian|RedHat)/ => true,
    default           => false
  }

}
