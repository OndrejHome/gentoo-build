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
rm -fv /stage3.tar.xz
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
# cleanup repositories and package related caches
PORTDIR=$(portageq get_repo_path / gentoo)
DISTDIR=$(portageq distdir)
PKGDIR=$(portageq pkgdir)
rm -rf $PORTDIR
rm -rf $DISTDIR
rm -rf $PKGDIR
# add the CHOST into /etc/portage/make.conf as it normally comes set from profile in /usr/portage/profiles
echo 'CHOST="x86_64-pc-linux-gnu"' >> /etc/portage/make.conf
EOF
fi

## Trim empty space - useful for thinly provision storage
fstrim -v --quiet-unsupported /mnt/gentoo
fstrim -v --quiet-unsupported /mnt/gentoo/boot
