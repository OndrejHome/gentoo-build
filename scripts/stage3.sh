#!/bin/bash
set -x
set -e

if [ -e "${GB_ROOT}/stage3.tar.xz" ] ; then
  echo "skipping stage3"
  exit 0
fi

ARCH='amd64'
if [ $(uname -m) == 'aarch64' ]; then
  ARCH='arm64'
fi

if [ "$GB_INIT" = "systemd" ]; then
  if [ "${GB_STAGE3}" = "latest" ]; then
    wget -O "${GB_ROOT}/stage3.tar.xz" "${GB_STAGE3_MIRROR}/releases/${ARCH}/autobuilds/current-stage3-${ARCH}-systemd/stage3-${ARCH}-systemd-2*.tar.xz"
  else
    wget -O "${GB_ROOT}/stage3.tar.xz" "${GB_STAGE3_MIRROR}/releases/${ARCH}/autobuilds/${GB_STAGE3}/stage3-${ARCH}-systemd-${GB_STAGE3}.tar.xz"
  fi
else
  if [ "${GB_STAGE3}" = "latest" ]; then
    wget -O "${GB_ROOT}/stage3.tar.xz" "${GB_STAGE3_MIRROR}/releases/${ARCH}/autobuilds/current-stage3-${ARCH}-openrc/stage3-${ARCH}-openrc-2*.tar.xz"
  else
    wget -O "${GB_ROOT}/stage3.tar.xz" "${GB_STAGE3_MIRROR}/releases/${ARCH}/autobuilds/${GB_STAGE3}/stage3-${ARCH}-openrc-${GB_STAGE3}.tar.xz"
  fi

fi

tar xpf "${GB_ROOT}/stage3.tar.xz" --xattrs -C "${GB_ROOT}"
