# option.pp

define openvpn::option($key, $server, $value = '', $client = '', $csc = false) {
    $content = $value ? {
        ''      => $key,
        default => "${key} ${value}"
    }

    if $client == '' {
        $path = "/etc/openvpn/${server}.conf"
    } else {
        if $csc {
            $path = "/etc/openvpn/${server}/client-configs/${client}"
        } else {
            $path = "/etc/openvpn/${server}/download-configs/${client}/${client}.conf"
        }
    }

    concat::fragment {
        "openvpn.${server}.${client}.${name}":
            target  => $path,
            content => "${content}\n";
    }
}
