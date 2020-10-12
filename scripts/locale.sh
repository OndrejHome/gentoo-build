#!/bin/bash
set -x
set -e

chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
eselect locale set en_US.UTF-8
env-update
EOF
