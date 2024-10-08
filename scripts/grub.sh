#!/bin/bash
set -x
set -e

chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

if [ -d /sys/firmware/efi ]; then
  mkdir -p /etc/portage/package.use
  echo 'sys-boot/grub grub_platforms_efi-32 grub_platforms_efi-64' > /etc/portage/package.use/grub
fi

emerge --noreplace -vN sys-boot/grub
EOF

if [ "_${GB_GRUB_CONSOLE}" = "_1" ]; then
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
  source /etc/profile
  set -x
  set -e

  if ! grep -q '^# gentoo-build GB_GRUB_CONSOLE' /etc/default/grub; then
    echo '# gentoo-build GB_GRUB_CONSOLE' >> /etc/default/grub
    echo 'GRUB_CMDLINE_LINUX="${GRUB_CMDLINE_LINUX} console=tty1 console=ttyS0"' >> /etc/default/grub
    echo 'GRUB_TERMINAL=console' >> /etc/default/grub
  fi
EOF
fi

if [ "_${GB_GRUB_SERIAL}" = "_1" ]; then
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
  source /etc/profile
  set -x
  set -e

  if ! grep -q '^# gentoo-build GB_GRUB_SERIAL' /etc/default/grub; then
    echo '# gentoo-build GB_GRUB_SERIAL' >> /etc/default/grub
    echo 'GRUB_CMDLINE_LINUX="${GRUB_CMDLINE_LINUX}  console=ttyS0,115200n8"' >> /etc/default/grub
    echo 'GRUB_TERMINAL="serial console"' >> /etc/default/grub
    echo 'GRUB_SERIAL_COMMAND="serial --speed=115200"' >> /etc/default/grub
  fi
EOF
fi

if [ "_${GB_GRUB_NO_TIMEOUT}" = "_1" ]; then
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
  source /etc/profile
  set -x
  set -e

  if ! grep -q '^# gentoo-build GB_GRUB_NO_TIMEOUT$' /etc/default/grub; then
    echo '# gentoo-build GB_GRUB_NO_TIMEOUT' >> /etc/default/grub
    echo 'GRUB_DEFAULT=0' >> /etc/default/grub
    echo 'GRUB_HIDDEN_TIMEOUT=0' >> /etc/default/grub
    echo 'GRUB_HIDDEN_TIMEOUT_QUIET=true' >> /etc/default/grub
  fi
EOF
fi

if [ "$GB_INIT" = "systemd" ]; then
  chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

if ! grep -q '^# gentoo-build systemd' /etc/default/grub; then
  echo '# gentoo-build systemd' >> /etc/default/grub
  echo 'GRUB_CMDLINE_LINUX="${GRUB_CMDLINE_LINUX} init=/usr/lib/systemd/systemd"' >> /etc/default/grub
fi
EOF
fi

chroot ${GB_ROOT} /bin/bash <<-'EOF'
source /etc/profile
set -x
set -e

if grep -q ' /boot ' /proc/mounts; then
  if ! grep ' /boot ' /proc/mounts | grep -q rw; then
    mount -o rw,remount /boot
  fi
fi

if ! grep ' / ' /proc/mounts | grep -q rw; then
  mount -o rw,remount /
fi

if [ -d /sys/firmware/efi ]; then
  grub-install --removable --no-floppy /dev/${GB_ROOTDEVICE}
else
  grub-install --no-floppy /dev/${GB_ROOTDEVICE}
fi
grub-mkconfig -o /boot/grub/grub.cfg
EOF
