#!/bin/bash
set -x
set -e

if [ "$GB_INIT" = "systemd" ]; then
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

ln -sfv /usr/lib64/systemd/system/sshd.service /etc/systemd/system/multi-user.target.wants/sshd.service
EOF
else
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

ln -sfv /etc/init.d/sshd /etc/runlevels/default
EOF
fi
