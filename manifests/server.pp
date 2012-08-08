# server.pp

define openvpn::server($country, $province, $city, $organization, $email) {
    include openvpn

    $easyrsa_source = $operatingsystem ? {
      'centos' => '/usr/share/doc/openvpn-2.2.0/easy-rsa/2.0',
      default => '/usr/share/doc/openvpn/examples/easy-rsa/2.0'
    }

    $link_openssl_cnf = $lsbdistcodename ? {
      'precise' => true,
      default => false
    }

    file {
        "/etc/openvpn/${name}":
            ensure  => directory,
            require => Package["openvpn"];
    }
    file {
        "/etc/openvpn/${name}/client-configs":
            ensure  => directory,
            require => File["/etc/openvpn/${name}"];
        "/etc/openvpn/${name}/download-configs":
            ensure  => directory,
            require => File["/etc/openvpn/${name}"];
    }

    openvpn::option {
        "client-config-dir ${name}":
            key     => 'client-config-dir',
            value   => "/etc/openvpn/${name}/client-configs",
            server  => $name,
            require => File["/etc/openvpn/${name}"];
        "mode ${name}":
            key    => 'mode',
            value  => 'server',
            server => $name;
    }

    exec {
        "copy easy-rsa to openvpn config folder ${name}":
            command => "/bin/cp -r ${easyrsa_source} /etc/openvpn/${name}/easy-rsa",
            creates => "/etc/openvpn/${name}/easy-rsa",
            notify  => Exec["fix_easyrsa_file_permissions"],
            require => File["/etc/openvpn/${name}"];
    }
    exec {
        "fix_easyrsa_file_permissions":
            refreshonly => "true",
            command     => "/bin/chmod 755 /etc/openvpn/${name}/easy-rsa/*";
    }
    file {
        "/etc/openvpn/${name}/easy-rsa/vars":
            ensure  => present,
            content => template("openvpn/vars.erb"),
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
            command  => ". ./vars && ./clean-all && ./build-dh",
            cwd      => "/etc/openvpn/${name}/easy-rsa",
            creates  => "/etc/openvpn/${name}/easy-rsa/keys/dh1024.pem",
            provider => "shell",
            require  => File["/etc/openvpn/${name}/easy-rsa/vars"];

        "initca ${name}":
            command  => ". ./vars && ./pkitool --initca",
            cwd      => "/etc/openvpn/${name}/easy-rsa",
            creates  => "/etc/openvpn/${name}/easy-rsa/keys/ca.key",
            provider => "shell",
            require  => [ Exec["generate dh param ${name}"], File["/etc/openvpn/${name}/easy-rsa/openssl.cnf"] ];

        "generate server cert ${name}":
            command  => ". ./vars && ./pkitool --server server",
            cwd      => "/etc/openvpn/${name}/easy-rsa",
            creates  => "/etc/openvpn/${name}/easy-rsa/keys/server.key",
            provider => "shell",
            require  => Exec["initca ${name}"];
    }

    file {
        "/etc/openvpn/${name}/keys":
            ensure  => link,
            target  => "/etc/openvpn/${name}/easy-rsa/keys",
            require => Exec["copy easy-rsa to openvpn config folder ${name}"];
    }

    openvpn::option {
        "ca ${name}":
            key     => "ca",
            value   => "/etc/openvpn/${name}/keys/ca.crt",
            require => Exec["initca ${name}"],
            server  => "${name}";
        "cert ${name}":
            key     => "cert",
            value   => "/etc/openvpn/${name}/keys/server.crt",
            require => Exec["generate server cert ${name}"],
            server  => "${name}";
        "key ${name}":
            key     => "key",
            value   => "/etc/openvpn/${name}/keys/server.key",
            require => Exec["generate server cert ${name}"],
            server  => "${name}";
        "dh ${name}":
            key     => "dh",
            value   => "/etc/openvpn/${name}/keys/dh1024.pem",
            require => Exec["generate dh param ${name}"],
            server  => "${name}";
    }

    concat::fragment {
        "openvpn.default.autostart.${name}":
            content => "AUTOSTART=\"\$AUTOSTART ${name}\"\n",
            target  => "/etc/default/openvpn",
            order   => 10;
    }

    concat {
        "/etc/openvpn/${name}.conf":
            owner   => root,
            group   => root,
            mode    => 644,
            warn    => true,
            require => File["/etc/openvpn"],
            notify  => Service["openvpn"];
    }

}
