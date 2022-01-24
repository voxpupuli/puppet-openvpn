#!/bin/bash

set -e

if [ ! -f /module-installed ]; then
  wget https://apt.puppet.com/puppet7-release-focal.deb
  dpkg -i puppet7-release-focal.deb

  apt-get update
  apt-get install -y ruby-dev git puppet-agent

  export PATH=$PATH:/opt/puppetlabs/puppet/bin:/opt/puppetlabs/bin

  gem install librarian-puppet --no-document

  cp /vagrant/vagrant/Puppetfile /tmp
  cd /tmp && librarian-puppet install --verbose

  touch /module-installed
fi
