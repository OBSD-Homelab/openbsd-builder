#!/bin/bash

set -xeuo pipefail

snap_line="$(curl https://cdn.openbsd.org/pub/OpenBSD/snapshots/amd64/SHA256.sig 2>/dev/null | grep miniroot)"
snap_sum="$(echo $snap_line | awk '{ print $NF; }')"
snap_num="$(echo $snap_line | grep -Po 'miniroot\K(\d{2})')"

echo "${snap_sum}" > checksum

sed -e "s/^os_number.*$/os_number = \"${snap_num}\"/" \
    -e "s/^checksum.*$/checksum = \"${snap_sum}\"/" \
    openbsd.pkrvars.hcl.in > openbsd.pkrvars.hcl
