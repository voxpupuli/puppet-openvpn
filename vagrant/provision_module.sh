#!/bin/bash

set -e

if [ ! -f /module-installed ]; then
  apt-get update
  apt-get install -y ruby-dev git

  gem install librarian-puppet --no-rdoc --no-ri

  cp /vagrant/vagrant/Puppetfile /tmp
  cd /tmp && librarian-puppet install --verbose

  touch /module-installed
fi
