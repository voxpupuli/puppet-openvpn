# client.pp

define openvpn::client(
  $server,
  $compression = 'comp-lzo',
  $dev = 'tun',
  $mute = '20',
  $mute_replay_warnings = true,
  $nobind = true,
  $ns_cert_type = 'server',
  $persist_key = true,
  $persist_tun = true,
  $port = '1194',
  $proto = 'tcp',
  $remote_host = $::fqdn,
  $resolv_retry = 'infinite',
  $verb = '3',
) {
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

        "/etc/openvpn/${server}/download-configs/${name}/${name}.conf":
            owner   => root,
            group   => root,
            mode    => '0444',
            content => template('openvpn/client.erb'),
            notify  => Exec["tar the thing ${server} with ${name}"];                          
    }

    concat {
        "/etc/openvpn/${server}/client-configs/${name}":
            owner   => root,
            group   => root,
            mode    => 644,
            warn    => true,
            force   => true,
            notify  => Exec["tar the thing ${server} with ${name}"],
            require => [ File['/etc/openvpn'], File["/etc/openvpn/${server}/download-configs/${name}"] ];
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
}
