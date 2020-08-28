#! /usr/bin/env bash

set -e -x -u

apt-get update
apt-get install -y cmake

pushd mini-portile

  gem install bundler
  bundle install
  bundle exec rake test

popd
