#!/bin/bash

set -euxo pipefail

OS_VERSION="$1"; shift
ARCHITECTURE="$1"; shift

# rm -rf packer_cache

packer build \
  -var-file "var_files/common.pkrvars.hcl" \
  -var-file "var_files/$ARCHITECTURE.pkrvars.hcl" \
  -var-file "var_files/$OS_VERSION/common.pkrvars.hcl" \
  -var-file "var_files/$OS_VERSION/$ARCHITECTURE.pkrvars.hcl" \
  "$@" \
  openbsd.pkr.hcl
