# server.pp

define openvpn::server($country, $province, $city, $organization, $email) {
    include openvpn

    file {
        "/etc/openvpn/${name}":
            ensure => directory,
            require => Package["openvpn"];
    }
    file {
        "/etc/openvpn/${name}/client-configs":
            ensure => directory,
            require => File["/etc/openvpn/${name}"];
        "/etc/openvpn/${name}/download-configs":
            ensure => directory,
            require => File["/etc/openvpn/${name}"];
    }

    exec {
        "copy easy-rsa to openvpn config folder ${name}":
            command => "cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/${name}/easy-rsa",
            creates => "/etc/openvpn/${name}/easy-rsa",
            require => File["/etc/openvpn/${name}"];
    }
    file {
        "/etc/openvpn/${name}/easy-rsa/vars":
            ensure  => present,
            content => template("openvpn/vars.erb"),
            require => Exec["copy easy-rsa to openvpn config folder ${name}"];
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
            require  => Exec["generate dh param ${name}"];
        
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
    
    common::concatfilepart {
        "etc-default-openvpn autostart for ${name}":
            ensure  => present,
            content => "AUTOSTART=\"\$AUTOSTART ${name}\"\n",
            file    => "/etc/default/openvpn";
    }
}
