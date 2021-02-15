#!/usr/bin/env bash
set -e

echo "Deploy Yadoms archive to /opt/yadoms"
mkdir -p "${ROOTFS_DIR}/opt/yadoms"
tar zxf yadoms.tar.gz -C "${ROOTFS_DIR}/opt/yadoms" --strip 2

echo "Yadoms installed to /opt/yadoms"
ls -al "${ROOTFS_DIR}/opt/yadoms"

#change yadoms hhtp port
sed -i 's/port = 8080/port = 80/g' ${ROOTFS_DIR}/opt/yadoms/yadoms.ini

#Change files authz
on_chroot <<EOF
chown -R yadoms:yadoms /opt/yadoms
chmod -R 777 /opt/yadoms
#allow 'yadoms' to open port 80 (for port <1024 it is forbidden by default. With this line, it is allowed for yadoms)
#sudo setcap 'cap_net_bind_service=+ep' /opt/yadoms/yadoms
EOF

#Install init rc script to manage Yadoms
install -m 755 files/yadoms	"${ROOTFS_DIR}/etc/init.d/"

#Enable yadoms (autostart)
on_chroot << EOF
systemctl enable yadoms
update-rc.d yadoms defaults
EOF
