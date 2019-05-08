#!/bin/bash
set -x
set -e

if [ "$GB_INIT" = "systemd" ]; then
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

emerge --noreplace -v sys-process/vixie-cron
ln -sfv /usr/lib64/systemd/system/vixie-cron.service /etc/systemd/system/multi-user.target.wants/vixie-cron.service
EOF
else
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

emerge --noreplace -v sys-process/vixie-cron
ln -s /etc/init.d/vixie-cron /etc/runlevels/default/vixie-cron
EOF
fi
