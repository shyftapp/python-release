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
    bosh add-blob --sha2 ../python-${version}/${blobname} ${blobname}
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

declared_versions=("3.10")
IFS=$'\n' versions=($(sort <<< "${declared_versions[*]}"))
unset IFS

latest_version="${versions[-1]}"


for version in ${versions[*]}; do
  replace_if_necessary $version 
  if [[ "$version" == "$latest_version" ]]; then
    cp "../python-${version}/.resource/version" "./packages/python-${version}/"
  fi

  if [[ "$( git status --porcelain )" != "" ]]; then
    git commit -am "Bump to python $(cat ../python-$version/.resource/version)" -m "$(cd ../python-$version && ls)"
  fi
done
