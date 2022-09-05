#!/bin/bash
set -e
set -x

rm -f ${GB_ROOT}/etc/localtime
echo "${GB_TIMEZONE}" > ${GB_ROOT}/etc/timezone

chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

emerge --config sys-libs/timezone-data
EOF
