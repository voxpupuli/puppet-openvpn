## push.pp
#
#define openvpn::push($network, $netmask, $server, $gateway = "undefined") {
#    
#    $gw = $gateway ? {
#        "undefined" => "",
#        default     => " ${gateway}"
#    }
#
#    common::concatfilepart {
#        "push ${name}":
#            ensure  => $ensure,
#            file    => "/etc/openvpn/${server}.conf",
#            content => "push \"route ${network} ${netmask}${gw}\"\n",
#            notify  => Service["openvpn"],
#            require => Package["openvpn"];
#    }
#}
