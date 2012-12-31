# server.pp

define openvpn::server(
  $country, 
  $province, 
  $city, 
  $organization, 
  $email,
  $compression = 'comp-lzo'
  $port = '1194',
  $proto = 'tcp',
) {
    include openvpn

    $easyrsa_source = $::osfamily ? {
      'RedHat'  => '/usr/share/doc/openvpn-2.2.2/easy-rsa/2.0',
      default   => '/usr/share/doc/openvpn/examples/easy-rsa/2.0'
    }

    $link_openssl_cnf = $::osfamily ? {
      /(Debian|RedHat)/ => true,
      default           => false
    }

    file {
        ["/etc/openvpn/${name}", "/etc/openvpn/${name}/client-configs", "/etc/openvpn/${name}/download-configs" ]:
            ensure  => directory,
            require => Package['openvpn'];
    }

    exec {
        "copy easy-rsa to openvpn config folder ${name}":
            command => "/bin/cp -r ${easyrsa_source} /etc/openvpn/${name}/easy-rsa",
            creates => "/etc/openvpn/${name}/easy-rsa",
            notify  => Exec['fix_easyrsa_file_permissions'],
            require => File["/etc/openvpn/${name}"];
    }
    exec {
        'fix_easyrsa_file_permissions':
            refreshonly => true,
            command     => "/bin/chmod 755 /etc/openvpn/${name}/easy-rsa/*";
    }
    file {
        "/etc/openvpn/${name}/easy-rsa/vars":
            ensure  => present,
            content => template('openvpn/vars.erb'),
            require => Exec["copy easy-rsa to openvpn config folder ${name}"];
    }

    file {
      "/etc/openvpn/${name}/easy-rsa/openssl.cnf":
        require => Exec["copy easy-rsa to openvpn config folder ${name}"];
    }
    if $link_openssl_cnf == true {
        File["/etc/openvpn/${name}/easy-rsa/openssl.cnf"] {
            ensure => link,
            target => "/etc/openvpn/${name}/easy-rsa/openssl-1.0.0.cnf"
        }
    }

    exec {
        "generate dh param ${name}":
            command  => '. ./vars && ./clean-all && ./build-dh',
            cwd      => "/etc/openvpn/${name}/easy-rsa",
            creates  => "/etc/openvpn/${name}/easy-rsa/keys/dh1024.pem",
            provider => 'shell',
            require  => File["/etc/openvpn/${name}/easy-rsa/vars"];

        "initca ${name}":
            command  => '. ./vars && ./pkitool --initca',
            cwd      => "/etc/openvpn/${name}/easy-rsa",
            creates  => "/etc/openvpn/${name}/easy-rsa/keys/ca.key",
            provider => 'shell',
            require  => [ Exec["generate dh param ${name}"], File["/etc/openvpn/${name}/easy-rsa/openssl.cnf"] ];

        "generate server cert ${name}":
            command  => '. ./vars && ./pkitool --server server',
            cwd      => "/etc/openvpn/${name}/easy-rsa",
            creates  => "/etc/openvpn/${name}/easy-rsa/keys/server.key",
            provider => 'shell',
            require  => Exec["initca ${name}"];
    }

    file {
        "/etc/openvpn/${name}/keys":
            ensure  => link,
            target  => "/etc/openvpn/${name}/easy-rsa/keys",
            require => Exec["copy easy-rsa to openvpn config folder ${name}"];
    }

    concat::fragment {
        "openvpn.default.autostart.${name}":
            content => "AUTOSTART=\"\$AUTOSTART ${name}\"\n",
            target  => '/etc/default/openvpn',
            order   => 10;
    }

    concat {
        "/etc/openvpn/${name}.conf":
            owner   => root,
            group   => root,
            mode    => 644,
            warn    => true,
            require => File['/etc/openvpn'],
            notify  => Service['openvpn'];
    }

    concat::fragment {
        "openvpn.${server}.${name}":
            target  => "/etc/openvpn/${name}.conf",
            content => template('openvpn/server.erb')
    }
}
