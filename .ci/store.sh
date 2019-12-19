#!/usr/bin/env bash

csource="${BASH_SOURCE[0]}"
while [ -h "$csource" ] ; do csource="$(readlink "$csource")"; done
root="$( cd -P "$( dirname "$csource" )/../" && pwd )"

pushd "${root}" > /dev/null
. ./.ci/common.sh

aws s3 cp "${asset_cache}/vagrant.gem" ./vagrant.gem > .output 2>&1
if [ $? -ne 0 ]; then
    fail "Failed to retrieve gem asset from cache"
fi
rm .output

gem="vagrant.gem"

if [ "${tag}" = "" ]; then
    remote_gem_name="vagrant-${ident_ref}.gem"
else
    remote_gem_name="vagrant.gem"
fi

if [[ "${ident_ref}" = "build-"* ]]; then
    s3_dst="${ASSETS_PRIVATE_LONGTERM}/${repository}/${ident_ref##build-}/"
else
    s3_dst="${ASSETS_PRIVATE_BUCKET}/${repository}/"
fi

echo -n "Storing Vagrant RubyGem to asset store... "
aws s3 cp "${gem}" "${s3_dst}${remote_gem_name}" > .output 2>&1

if [ $? -ne 0 ]; then
    echo "error"
    fail "Failed to upload Vagrant RubyGem to remote asset storage"
fi
rm .output
echo "done"
