#!/usr/bin/env bash

csource="${BASH_SOURCE[0]}"
while [ -h "$csource" ] ; do csource="$(readlink "$csource")"; done
root="$( cd -P "$( dirname "$csource" )/../" && pwd )"

pushd "${root}" > /dev/null
. ./.ci/common.sh

mkdir -p assets/

echo -n "Building Vagrant RubyGem... "

gem build vagrant.gemspec > .output 2>&1
if [ $? -ne 0 ]; then
    echo "error"
    fail "Failed to build Vagrant RubyGem"
fi
rm .output
echo "done"

# Store gem to cache
gem=(vagrant-*.gem)
aws s3 cp "${gem}" "${asset_cache}/vagrant.gem" > .output 2>&1

if [ $? -ne 0 ]; then
    fail "Failed to store asset to remove cache"
fi
rm .output
