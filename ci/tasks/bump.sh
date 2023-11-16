#!/usr/bin/env bash

set -eux

function replace_if_necessary() {
  version=$1
  blobname=$(basename $(ls ../python-${version}/*))

  cp ../python-${version}/.resource/version ./packages/python-${version}/

  if ! bosh blobs | grep -q ${blobname}; then
    existing_blob=$(bosh blobs | awk '{print $1}' | grep "Python-${version}" || true)
    if [ -n "${existing_blob}" ]; then
      bosh remove-blob ${existing_blob}
    fi
    bosh add-blob --sha2 ../python-${version}/${blobname} python-${version}/${blobname}
    bosh upload-blobs
  fi
}

cd bumped-python-release

git clone ../python-release .

set +x
echo "${PRIVATE_YML}" > config/private.yml
set -x

git config user.name "CI Bot"
git config user.email "cf-bosh-eng@pivotal.io"
versions=("3.10" "3.11" "3.12")

for version in ${versions[*]}; do
  replace_if_necessary $version 

  if [[ "$( git status --porcelain )" != "" ]]; then
    git commit -am "Bump to python $(cat ../python-$version/.resource/version)" -m "$(cd ../python-$version && ls)"
  fi
done
