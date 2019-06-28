#!/usr/bin/env bash

set -e

python_version=2.7.15
python_sha256=18617d1f15a380a919d517630a9cd85ce17ea602f9bbdc58ddc672df4b0239db

setuptools_version=40.4.3
setuptools_sha256=acbc5740dd63f243f46c2b4b8e2c7fd92259c2ddb55a4115b16418a2ed371b15

pip_version=18.0
pip_sha256=a0e11645ee37c90b40c46d607070c4fd583e2cd46231b1c06e389c5e814eed76


function main() {
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
    release_dir=$(cd "${script_dir}/.." && pwd)

    mkdir -p "${release_dir}/tmp"

    set -x
    download_add_blob \
        "https://www.python.org/ftp/python/${python_version}/Python-${python_version}.tgz" \
        "${python_sha256}" \
        "${release_dir}/tmp/Python-${python_version}.tgz" \
        "Python-${python_version}.tgz"

    download_add_blob \
        "https://files.pythonhosted.org/packages/6e/9c/6a003320b00ef237f94aa74e4ad66c57a7618f6c79d67527136e2544b728/setuptools-${setuptools_version}.zip" \
        "${setuptools_sha256}" \
        "${release_dir}/tmp/setuptools-${setuptools_version}.zip" \
        "setuptools-${setuptools_version}.zip"

    download_add_blob \
        "https://files.pythonhosted.org/packages/69/81/52b68d0a4de760a2f1979b0931ba7889202f302072cc7a0d614211bc7579/pip-${pip_version}.tar.gz" \
        "${pip_sha256}" \
        "${release_dir}/tmp/pip-${pip_version}.tar.gz" \
        "pip-${pip_version}.tar.gz"
}

function download_add_blob() {
    local url=$1
    local sha256=$2
    local file_path=$3
    local blob_path=$4

    if [[ ! -f "${file_path}" ]]; then
        curl -fsSL "${url}" -o "${file_path}"
    fi
    shasum -a 256 --check <<< "${sha256}  ${file_path}"

    bosh add-blob "${file_path}" "${blob_path}"
}

main "$@"
