#
# @summary Collect the exported configs for an Host and ensure a running Openvpn Service
# @param server which Openvpn::Server[$server] does the config belong to?
# @param manage_etc should the /etc/openvpn directory be managed? (warning, all unmanaged files will be purged!)
#
# @example
#  openvpn::deploy::client { 'test-client':
#    server => 'test_server',
#  }
#
define openvpn::deploy::client (
  String $server,
  Boolean $manage_etc = true,
  Boolean $manage_service = true,
) {

  include openvpn::deploy::prepare

  File <<| tag == "${server}-${name}" |>>

  Class['openvpn::deploy::install']
  -> Openvpn::Deploy::Client[$name]

  if $manage_etc {
    file { [
      "${openvpn::deploy::prepare::etc_directory}/openvpn",
      "${openvpn::deploy::prepare::etc_directory}/openvpn/keys",
      "${openvpn::deploy::prepare::etc_directory}/openvpn/keys/${name}",
    ]:
      ensure  => directory,
      require => Package['openvpn'];
    }
  } else {
    file { "${openvpn::deploy::prepare::etc_directory}/openvpn/keys/${name}":
      ensure  => directory,
      require => Package['openvpn'];
    }
  }

  if $manage_service {

    if $facts['service_provider'] == 'systemd' {
      $service = "openvpn@${name}"
      service { "$service":
        ensure   => running,
        enable   => true,
        provider => 'systemd',
        require  => File["${openvpn::deploy::prepare::etc_directory}/openvpn/${name}.conf"],
      }
    }
    elsif $openvpn::namespecific_rclink {
      $service = "openvpn_${name}"
      file { "/usr/local/etc/rc.d/openvpn_${name}":
        ensure => link,
        target => "${openvpn::deploy::prepare::etc_directory}/rc.d/openvpn",
      }
      file { "/etc/rc.conf.d/openvpn_${name}":
        owner   => root,
        group   => 0,
        mode    => '0644',
        content => template('openvpn/etc-rc.d-openvpn.erb'),
      }
      service { "$service":
        ensure  => running,
        enable  => true,
        require => [
          File["${openvpn::deploy::prepare::etc_directory}/openvpn/${name}.conf"],
          File["/usr/local/etc/rc.d/openvpn_${name}"],
        ],
      }
    }
    else {
      $service = "openvpn"
      service { "$service":
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
      }
    }

  }

}
