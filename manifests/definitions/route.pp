## route.pp
#
#define openvpn::route($network, $netmask, $server, $gateway) {
#    common::concatfilepart {
#        "route ${name}":
#            ensure  => $ensure,
#            file    => "/etc/openvpn/${server}.conf",
#            content => "route ${network} ${netmask} ${gateway}\n",
#            notify  => Service["openvpn"],
#            require => Package["openvpn"];
#    }
#}
