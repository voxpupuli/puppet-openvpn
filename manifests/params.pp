class openvpn::params {

  $group = $::osfamily ? {
    'RedHat' => 'nobody',
    default  => 'nogroup'
  }

}
