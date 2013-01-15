# == Define: openvpn::server
#
# This define creates the openvpn server instance and ssl certificates
#
#
# === Parameters
#
# [*country*]
#   String.  Country to be used for the SSL certificate
#
# [*province*]
#   String.  Province to be used for the SSL certificate
#
# [*city*]
#   String.  City to be used for the SSL certificate
#
# [*organization*]
#   String.  Organization to be used for the SSL certificate
#
# [*email*]
#   String.  Email address to be used for the SSL certificate
#
# [*compression*]
#   String.  Which compression algorithim to use
#   Default: comp-lzo
#   Options: comp-lzo or '' (disable compression)
#
# [*dev*]
#   String.  Device method
#   Default: tun
#   Options: tun (routed connections), tap (bridged connections)
#
# [*group*]
#   String.  User to drop privileges to after startup
#   Default: nobody
#
# [*ipp*]
#   Boolean.  Persist ifconfig information to a file to retain client IP
#     addresses between sessions
#   Default: true
#
# [*local*]
#   String.  Interface for openvpn to bind to.
#   Default: $::ipaddress_eth0
#   Options: An IP address or '' to bind to all ip addresses
#
# [*logfile*]
#   String.  Logfile for this openvpn server
#   Default: ''
#   Options:  '' (syslog) or log file name
#
# [*port*]
#   Integer.  The port the openvpn server service is running on
#   Default: 1194
#
# [*proto*]
#   String.  What IP protocol is being used.
#   Default: tcp
#   Options: tcp or udp
#
# [*status_log*]
#   String.  Logfile for periodic dumps of the vpn service status
#   Default: "${name}/openvpn-status.log"
#
# [*user*]
#   String.  Group to drop privileges to after startup
#   Default: nobody
#
# [*server*]
#   String.  Network to assign client addresses out of
#   Default: None.  Required in tun mode, not in tap mode
#
# [*push*]
#   Array.  Options to push out to the client.  This can include routes, DNS
#     servers, DNS search domains, and many other options.
#   Default: []
#
#
# === Examples
#
#   openvpn::client {
#     'my_user':
#       server      => 'contractors',
#       remote_host => 'vpn.mycompany.com'
#    }
#
# * Removal:
#     Manual process right now, todo for the future
#
#
# === Authors
#
# * Raffael Schmid <mailto:raffael@yux.ch>
# * John Kinsella <mailto:jlkinsel@gmail.com>
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
define openvpn::server(
  $country, 
  $province, 
  $city, 
  $organization, 
  $email,
  $compression = 'comp-lzo',
  $dev = 'tun0',
  $group = 'nobody',
  $ipp = true,
  $local = $::ipaddress_eth0,
  $logfile = "${name}/openvpn.log",
  $port = '1194',
  $proto = 'tcp',
  $status_log = "${name}/openvpn-status.log",
  $user = 'nobody',
  $server = '',
  $push = []
) {
  
  include openvpn
    Class['openvpn::install'] ->
    Openvpn::Server[$name] ~>
    Class['openvpn::service']

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
            ensure  => directory;
    }

    exec {
        "copy easy-rsa to openvpn config folder ${name}":
            command => "/bin/cp -r ${easyrsa_source} /etc/openvpn/${name}/easy-rsa",
            creates => "/etc/openvpn/${name}/easy-rsa",
            notify  => Exec["fix_easyrsa_file_permissions_${name}"],
            require => File["/etc/openvpn/${name}"];
    }
    
    exec {
        "fix_easyrsa_file_permissions_${name}":
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

    if $::osfamily == 'Debian' {
      concat::fragment {
        "openvpn.default.autostart.${name}":
          content => "AUTOSTART=\"\$AUTOSTART ${name}\"\n",
          target  => '/etc/default/openvpn',
          order   => 10;
      }
    }
    
    file {
      "/etc/openvpn/${name}.conf":
        owner   => root,
        group   => root,
        mode    => '0444',
        content => template('openvpn/server.erb');
    }
}
