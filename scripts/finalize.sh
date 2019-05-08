#!/bin/bash
set -x
set -e

chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e
rm -f /etc/resolv.conf
true > /etc/machine-id
emerge -c gentoo-sources
EOF

if [ "$GB_INIT" = "systemd" ]; then
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e
ln -snf /run/systemd/resolve/resolv.conf /etc/resolv.conf
EOF
fi

if [ "_$GB_REMOVE_PORTAGE" = "_1" ]; then
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e
# cleanup /usr/portage so new one needs to be downloaded when system is used
rm -rf /usr/portage
# add the CHOST into /etc/portage/make.conf as it normally comes set from profile in /usr/portage/profiles
echo 'CHOST="x86_64-pc-linux-gnu"' >> /etc/portage/make.conf
rm -fv /stage3.tar.bz2
EOF

## Trim empty space - useful for thinly provision storage
fstrim -v /mnt/gentoo
fstrim -v /mnt/gentoo/boot
fi
