#!/bin/bash
set -x
set -e

if [ -z "${GB_ROOT_USER_PASSWORD}" ]; then
  echo 'skipping root user'
  exit 0
fi

chroot ${GB_ROOT} /bin/bash <<-EOF
source /etc/profile
set -x
set -e

if printenv GB_ROOT_USER_PASSWORD | grep -q .; then
  ( echo -n 'root:' && printenv GB_ROOT_USER_PASSWORD ) | chpasswd
fi
EOF
