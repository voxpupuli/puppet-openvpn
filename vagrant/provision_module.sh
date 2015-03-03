#!/bin/bash

set -e

if [ ! -f /module-installed ]; then
  gem install librarian-puppet --no-rdoc --no-ri
  cp /vagrant/vagrant/Puppetfile /tmp
  cd /tmp && librarian-puppet install --verbose
  touch /module-installed
fi
