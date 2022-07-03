#!/bin/bash
set -x
set -e

chroot "${GB_ROOT}" /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

# Bump to 236
if eselect profile show | grep -q systemd; then
  if [ -x /usr/bin/systemctl -a "_${GB_SYSTEMD_232}" = "_1" ]; then
    if /usr/bin/systemctl --version | grep 226; then
      echo '=sys-apps/systemd-232 ~amd64' >> /etc/portage/package.accept_keywords
      echo '=sys-libs/libseccomp-2.3.1 ~amd64' >> /etc/portage/package.accept_keywords
      emerge -v '=sys-apps/systemd-232'
    fi
    exit
  fi
fi

if [ -z "${GB_ESELECT_PROFILE}" ]; then
  # try to guess the profile which we wanna use if not specified
  profile="$(find /usr/portage/profiles/default/linux/amd64 -maxdepth 2 -name 'systemd' -type d|head -n1|sed -e's|^/usr/portage/profiles/||')"
else
  profile="${GB_ESELECT_PROFILE}"
fi
eselect profile set "${profile}"

if [ -e /usr/lib/systemd/systemd ]; then
  echo 'skipping systemd'
  exit 0
fi

emerge --unmerge sys-fs/udev || :
emerge --deselect sys-fs/udev || :
emerge --unmerge sys-fs/eudev || :
emerge --deselect sys-fs/eudev || :

ln -sf /proc/self/mounts /etc/mtab
emerge -v sys-apps/systemd
emerge -vDN @world
EOF
