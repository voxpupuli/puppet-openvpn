# option.pp

define openvpn::option($ensure = present, $key, $value = "", $server, $client = "", $csc = false) {
    $content = $value ? {
        ""      => "${key}",
        default => "${key} ${value}"
    }
    
    if $client == "" {
        $path = "/etc/openvpn/${server}.conf"
        $req = File["/etc/openvpn"]
        $notify  = Service["openvpn"]
    } else {
        if $scs {
            $path = "/etc/openvpn/${server}/client-configs/${client}"
        } else {
            $path = "/etc/openvpn/${server}/download-configs/${client}/${client}.conf"
        }
        $req = [ File["/etc/openvpn"], File["/etc/openvpn/${server}/download-configs/${client}"] ]
        $notify = undef
    }
    
    common::concatfilepart {
        "${name}":
            ensure  => $ensure,
            file    => $path,
            content => "${content}\n",
            notify  => $notify,
            require => $req;
    }
}
