#!/bin/bash
set -x
set -e

chroot "${GB_ROOT}" /bin/bash -x -e <<-'EOF'
eselect profile set "${GB_ESELECT_PROFILE}"
emerge --noreplace app-admin/sysklogd
ln -s /etc/init.d/sysklogd /etc/runlevels/default
EOF
