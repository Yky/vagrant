#!/usr/bin/env bash

# NOTE: This release will generate a new release on the installers
# repository which in turn triggers a full package build
target_owner="hashicorp"
target_repository="vagrant-installers"

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
vagrant_version="$(gem specification ./vagrant.gem version)"
vagrant_version="${vagrant_version##*version: }"

export GITHUB_TOKEN="${HASHIBOT_TOKEN}"

if [ "${tag}" = "" ]; then
    echo -n "Generating Vagrant RubyGem pre-release... "
    version="v${vagrant_version}+${short_sha}"
    ghr -u "${target_owner}" -r "${target_repository}" -c "${full_sha}" -prerelease \
        -delete -replace "${version}" "${gem}" > .output 2>&1
else
    echo -n "Generating Vagrant RubyGem release... "
    version="v${vagrant_version}"
    ghr -u "${target_owner}" -r "${target_repository}" -c "${full_sha}" \
        -delete -replace "${version}" "${gem}" > .output 2>&1
fi

if [ $? -ne 0 ]; then
    echo "error"
    fail "Failed to create Vagrant Release for version ${vagrant_version}"
fi
rm .output
echo "done"

slack -m "New Vagrant installers release triggered: *${version}*"
