#!/usr/bin/env bash

dir=$(dirname $0)

fly -t ${CONCOURSE_TARGET:-bosh-ecosystem} \
  sp -p python-release \
  -c $dir/pipeline.yml
