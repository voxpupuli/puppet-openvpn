#
# @summary Installs the Openvpn profile
#
class openvpn::deploy::install {

  ensure_packages(['openvpn'])

}
