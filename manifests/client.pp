# client.pp

define openvpn::client($server, $remote_host = $::fqdn) {
    exec {
        "generate certificate for ${name} in context of ${server}":
            command  => ". ./vars && ./pkitool ${name}",
            cwd      => "/etc/openvpn/${server}/easy-rsa",
            creates  => "/etc/openvpn/${server}/easy-rsa/keys/${name}.crt",
            provider => 'shell',
            require  => Exec["generate server cert ${server}"];
    }

    file {
        "/etc/openvpn/${server}/download-configs/${name}":
            ensure  => directory,
            require => File["/etc/openvpn/${server}/download-configs"];

        "/etc/openvpn/${server}/download-configs/${name}/keys":
            ensure  => directory,
            require => File["/etc/openvpn/${server}/download-configs/${name}"];

        "/etc/openvpn/${server}/download-configs/${name}/keys/${name}.crt":
            ensure  => link,
            target  => "/etc/openvpn/${server}/easy-rsa/keys/${name}.crt",
            require => [  Exec["generate certificate for ${name} in context of ${server}"],
                          File["/etc/openvpn/${server}/download-configs/${name}/keys"] ];

        "/etc/openvpn/${server}/download-configs/${name}/keys/${name}.key":
            ensure  => link,
            target  => "/etc/openvpn/${server}/easy-rsa/keys/${name}.key",
            require => [  Exec["generate certificate for ${name} in context of ${server}"],
                          File["/etc/openvpn/${server}/download-configs/${name}/keys"] ];

        "/etc/openvpn/${server}/download-configs/${name}/keys/ca.crt":
            ensure  => link,
            target  => "/etc/openvpn/${server}/easy-rsa/keys/ca.crt",
            require => [  Exec["generate certificate for ${name} in context of ${server}"],
                          File["/etc/openvpn/${server}/download-configs/${name}/keys"] ];
    }


    openvpn::option {
        "ca ${server} with ${name}":
            key    => 'ca',
            value  => 'keys/ca.crt',
            client => $name,
            server => $server;
        "cert ${server} with ${name}":
            key    => 'cert',
            value  => "keys/${name}.crt",
            client => $name,
            server => $server;
        "key ${server} with ${name}":
            key    => 'key',
            value  => "keys/${name}.key",
            client => $name,
            server => $server;
        "client ${server} with ${name}":
            key    => 'client',
            client => $name,
            server => $server;
        "dev ${server} with ${name}":
            key    => 'dev',
            value  => 'tun',
            client => $name,
            server => $server;
        "proto ${server} with ${name}":
            key    => 'proto',
            value  => 'tcp',
            client => $name,
            server => $server;
        "remote ${server} with ${name}":
            key    => 'remote',
            value  => "${remote_host} 1194",
            client => $name,
            server => $server;
        "resolv-retry ${server} with ${name}":
            key    => 'resolv-retry',
            value  => 'infinite',
            client => $name,
            server => $server;
        "nobind ${server} with ${name}":
            key    => 'nobind',
            client => $name,
            server => $server;
        "persist-key ${server} with ${name}":
            key    => 'persist-key',
            client => $name,
            server => $server;
        "persist-tun ${server} with ${name}":
            key    => 'persist-tun',
            client => $name,
            server => $server;
        "mute-replay-warnings ${server} with ${name}":
            key    => 'mute-replay-warnings',
            client => $name,
            server => $server;
        "ns-cert-type ${server} with ${name}":
            key    => 'ns-cert-type',
            value  => 'server',
            client => $name,
            server => $server;
        "comp-lzo ${server} with ${name}":
            key    => 'comp-lzo',
            client => $name,
            server => $server;
        "verb ${server} with ${name}":
            key    => 'verb',
            value  => '3',
            client => $name,
            server => $server;
        "mute ${server} with ${name}":
            key    => 'mute',
            value  => '20',
            client => $name,
            server => $server;
    }

    exec {
        "tar the thing ${server} with ${name}":
            cwd         => "/etc/openvpn/${server}/download-configs/",
            command     => "/bin/rm ${name}.tar.gz; tar --exclude=\\*.conf.d -chzvf ${name}.tar.gz ${name}",
            refreshonly => true,
            require     => [  File["/etc/openvpn/${server}/download-configs/${name}/${name}.conf"],
                              File["/etc/openvpn/${server}/download-configs/${name}/keys/ca.crt"],
                              File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}.key"],
                              File["/etc/openvpn/${server}/download-configs/${name}/keys/${name}.crt"] ];
    }


    concat {
        [ "/etc/openvpn/${server}/client-configs/${name}", "/etc/openvpn/${server}/download-configs/${name}/${name}.conf" ]:
            owner   => root,
            group   => root,
            mode    => 644,
            warn    => true,
            force   => true,
            notify  => Exec["tar the thing ${server} with ${name}"],
            require => [ File['/etc/openvpn'], File["/etc/openvpn/${server}/download-configs/${name}"] ];
    }

}
