#!/usr/bin/env bash
set -e


function makePattern
{
  pattern=$1

  # Convert spaces to \s
  pattern=$(echo $pattern | sed -r 's/\s+/\\s/g')

  # Convert / to \/
  pattern=$(echo $pattern | sed -r 's/\/+/\\\//g')

  echo $pattern
}

function uncomment
{
  echo uncomment $1 line in $2
  pattern=$(makePattern "$1")
  sed -i '/'$pattern'/s/^#//g' $2
}

function comment
{
  echo comment $1 line in $2
  pattern=$(makePattern "$1")
  echo '/'$pattern'/s/^/#/g'
  sed -i '/'$pattern'/s/^/#/g' $2
}

######################################
echo "Deploy files to rootfs..."
install -m 755 files/updatercd_once	"${ROOTFS_DIR}/etc/init.d/"
install -m 755 files/etc/init.d/owfs	"${ROOTFS_DIR}/etc/init.d/"
install -m 755 files/etc/init.d/yadoms	"${ROOTFS_DIR}/etc/init.d/"
install -d				"${ROOTFS_DIR}/etc/dhcp/dhclient-exit-hooks.d"
install -m 644 files/etc/dhcp/dhclient-exit-hooks.d/yadoms	"${ROOTFS_DIR}/etc/dhcp/dhclient-exit-hooks.d/"

######################################
echo "Enable SSH..."
touch ${ROOTFS_DIR}/boot/ssh


######################################
echo "Enable UART..."
echo 'enable_uart=1' >> ${ROOTFS_DIR}/boot/config.txt


######################################
echo "Disable system logging to GPIO serial port to free the serial port..."
sed -i 's/ console=\S*,115200//g' ${ROOTFS_DIR}/boot/cmdline.txt


######################################
echo "Add serial port access to 'yadoms' user..."
sed -i 's/^dialout:x:.*:$/&yadoms/' ${ROOTFS_DIR}/etc/group


######################################
echo "Set-up for PiFace2..."
uncomment 'dtparam=spi=on' ${ROOTFS_DIR}/boot/config.txt


######################################
echo "Set-up for OWFS (supported by DS9490 USB dongle)..."
comment 'server: FAKE = DS18S20,DS2405' ${ROOTFS_DIR}/etc/owfs.conf
uncomment 'server: usb = all' ${ROOTFS_DIR}/etc/owfs.conf
uncomment 'mountpoint = /mnt/1wire' ${ROOTFS_DIR}/etc/owfs.conf
uncomment 'allow_other' ${ROOTFS_DIR}/etc/owfs.conf
uncomment 'user_allow_other' ${ROOTFS_DIR}/etc/fuse.conf
echo "Create /mnt/1wire dir..."
mkdir ${ROOTFS_DIR}/mnt/1wire


######################################
echo "Configure DHCP retry delay..."
uncomment 'retry 60;' ${ROOTFS_DIR}/etc/dhcp/dhclient.conf

######################################
echo "Authorize user to shutdown..."
sudo echo '[Allow all users to shutdown and reboot]' >> ${ROOTFS_DIR}/etc/polkit-1/localauthority/50-local.d/all_all_users_to_shutdown_reboot.pkla
sudo echo 'Identity=unix-user:*' >> ${ROOTFS_DIR}/etc/polkit-1/localauthority/50-local.d/all_all_users_to_shutdown_reboot.pkla
sudo echo 'Action=org.freedesktop.login1.power-off;org.freedesktop.login1.power-off-multiple-sessions;org.freedesktop.login1.reboot;org.freedesktop.login1.reboot-multiple-sessions' >> ${ROOTFS_DIR}/etc/polkit-1/localauthority/50-local.d/all_all_users_to_shutdown_reboot.pkla
sudo echo 'ResultAny=yes' >> ${ROOTFS_DIR}/etc/polkit-1/localauthority/50-local.d/all_all_users_to_shutdown_reboot.pkla


