#!/usr/bin/env bash
set -e

echo "Deploy Yadoms archive to /opt/yadoms"
mkdir -p "${ROOTFS_DIR}/opt/yadoms"
tar zxf yadoms.tar.gz -C "${ROOTFS_DIR}/opt/yadoms" --strip 2

echo "Yadoms installed to /opt/yadoms"
ls -al "${ROOTFS_DIR}/opt/yadoms"
