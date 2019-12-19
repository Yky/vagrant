#!/usr/bin/env bash

if [ "${DEBUG}" = "1" ]; then
    set -x
    output="/dev/stdout"
else
    output="/dev/null"
fi

function fail() {
    (>&2 echo "ERROR: ${1}")
    if [ -f ".output" ]; then
        slack -s error -m "ERROR: ${1}" -f .output -T 5
    else
        slack -s error -m "ERROR: ${1}"
    fi
    exit 1
}

function warn() {
    (>&2 echo "WARN:  ${1}")
    if [ -f ".output" ]; then
        slack -s warn -m "WARNING: ${1}" -f .output
    else
        slack -s warn -m "WARNING: ${1}"
    fi
}

function cleanup() {
}

trap cleanup EXIT

full_sha="${GITHUB_SHA}"
short_sha="${full_sha:0:8}"
ident_ref="${GITHUB_REF#*/*/}"
if [[ "${GITHUB_REF}" == *"refs/tags/"* ]]; then
    tag="${GITHUB_REF##*tags/}"
    if [[ "${tag}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        release=1
    fi
fi
repository="${GITHUB_REPOSITORY}"
repo_owner="${repository%/*}"
repo_name="${repository#*/}"
asset_cache="${ASSETS_PRIVATE_SHORTTERM}/${repository}/${GITHUB_ACTION}"
