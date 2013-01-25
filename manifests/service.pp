# == Class: openvpn::config
#
# This class maintains the openvpn service
#
#
# === Examples
#
# This class should not be directly invoked
#
# === Authors
#
# * Raffael Schmid <mailto:raffael@yux.ch>
# * John Kinsella <mailto:jlkinsel@gmail.com>
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
# === License
#
# Copyright 2013 Raffael Schmid, <raffael@yux.ch>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# lied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class openvpn::service {
  service {
    'openvpn':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      hasstatus  => true;
  }
}
