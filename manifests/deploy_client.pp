class openvpn::deploy_client (
  $gitrepo    = false,
  $clientname = 'client'
  ) {

  if ! $gitrepo { fail 'Need to pass a valid git repository' }

  require 'openvpn::install'
  require 'deployer'
  include 'openvpn::service'

  Class['openvpn::deploy_client'] ~> Class['openvpn::service']

  deployer::git{ "openvpn_${clientname}":
    source => $gitrepo,
    target => "/etc/openvpn/${clientname}",
  }

  file { "/etc/openvpn/${clientname}.conf":
    ensure  => link,
    target  => "/etc/openvpn/${clientname}/${clientname}.conf",
    require => Deployer::Git["openvpn_${clientname}"],
  }

  $keys = ['ca.crt', "${clientname}.crt", "${clientname}.key"]
  $keys.foreach { |$x|
    file { "/etc/openvpn/keys/${x}":
      ensure  => link,
      target  => "/etc/openvpn/${clientname}/keys/${x}",
      require => Deployer::Git["openvpn_${clientname}"],
    }
  }
}
