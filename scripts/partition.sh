#!/bin/bash
set -x
set -e

if [ -e /dev/${GB_ROOTDEVICE}1 -a -e /dev/${GB_ROOTDEVICE}2 -a -e /dev/${GB_ROOTDEVICE}3 -a -e /dev/${GB_ROOTDEVICE}4 ]; then
  echo "skipping partition"
  exit 0
fi

if [ -d /sys/firmware/efi ]; then
  sgdisk \
    -n 1:0:+256M -t 1:ef00 -c 1:"efi-system" \
    -n 2:0:+${GB_BOOT_PARTITION_SIZE:-256M} -t 2:8300 -c 2:"linux-boot" \
    -n 3:0:+1 \
    -n 4:0:+${GB_SWAP_PARTITION_SIZE:-256M}  -t 4:8200 -c 4:"swap"  \
    -d 3 \
    -n 3:0:0     -t 3:8300 -c 3:"linux-root" \
    -p /dev/${GB_ROOTDEVICE}

  mkfs.vfat /dev/${GB_ROOTDEVICE}1
else
  sgdisk \
    -n 1:0:+${GB_BOOT_PARTITION_SIZE:-128M} -t 1:8300 -c 1:"linux-boot" \
    -n 2:0:+32M  -t 2:ef02 -c 2:"bios-boot"  \
    -n 3:0:+1 \
    -n 4:0:+${GB_SWAP_PARTITION_SIZE:-256M}  -t 4:8200 -c 4:"swap"  \
    -d 3 \
    -n 3:0:0     -t 3:8300 -c 3:"linux-root" \
    -p /dev/${GB_ROOTDEVICE}
fi
# note: we create a dummy partition 3 and delete it after creating swap partition to get behaviour where we can have partition 3 filling all available space

case "${GB_BOOT_FSTYPE}" in
ext4)
  mkfs.ext4 /dev/${GB_ROOTDEVICE}${GB_BOOT_PARTITION}
  ;;
xfs)
  mkfs.xfs /dev/${GB_ROOTDEVICE}${GB_BOOT_PARTITION}
  ;;
btrfs)
  mkfs.btrfs /dev/${GB_ROOTDEVICE}${GB_BOOT_PARTITION}
  ;;
*)
  echo "unknown fs type ${GB_BOOT_FSTYPE}" >/dev/stderr
  exit 1
  ;;
esac

mkswap /dev/${GB_ROOTDEVICE}${GB_SWAP_PARTITION}

case "${GB_ROOT_FSTYPE}" in
ext4)
  mkfs.ext4 /dev/${GB_ROOTDEVICE}3
  ;;
xfs)
  mkfs.xfs /dev/${GB_ROOTDEVICE}3
  ;;
btrfs)
  mkfs.btrfs /dev/${GB_ROOTDEVICE}3
  ;;
*)
  echo "unknown fs type ${GB_ROOT_FSTYPE}" >/dev/stderr
  exit 1
  ;;
esac

