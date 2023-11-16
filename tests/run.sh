#!/bin/bash -ex

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd ${script_dir}/..
  echo "-----> `date`: Upload stemcell"
  bosh -n upload-stemcell "${STEMCELL_PATH}"

  echo "-----> `date`: Delete previous deployment"
  bosh -n -d test delete-deployment --force

  echo "-----> `date`: Deploy"
  bosh -n -d test deploy ./manifests/test.yml -v os="${OS}" -v job-name="${JOB_NAME}" -v ephemeral-disk="${VM_EXTENSIONS}"

  release_version=$(bosh releases --json | jq -r '[.Tables[0].Rows[] | select(.name == "python")][0].version')

  echo "----> `date`: Export to test compilation"
  bosh -n -d test export-release python/${release_version//\*} "${OS}/${STEMCELL_VERSION}" --dir ./releases

  echo "-----> `date`: Run test errand"
  bosh -n -d test run-errand python-3.10-${JOB_NAME}

  echo "-----> `date`: Delete deployments"
  bosh -n -d test delete-deployment

  echo "-----> `date`: Done"
popd
