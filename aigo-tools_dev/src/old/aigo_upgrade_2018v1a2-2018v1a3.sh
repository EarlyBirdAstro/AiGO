#!/bin/bash

# Everything else needs to be run as root
BNAME=`basename $0`
if [[ ${EUID} -ne 0 ]]; then
  TITLE="Error !"
  MSG="Script must be run as root.\n\nTry 'sudo $BNAME'\n"
  dialog --colors --clear --title " \Z1$TITLE\Zn " --msgbox "\n\Z1$MSG\Zn" 10 70
  exit 1
fi

if ! ping -c 1 aigo.serveftp.org >> /dev/null 2>&1; then
  TITLE="Network Error !"
  MSG="You need to have working Internet connection to run this script."
  dialog --colors --clear --title " \Z1$TITLE\Zn " --msgbox "\n\Z1$MSG\Zn" 10 70
  exit 1
fi

# TODO: check disk space

AIGO_TOOLS_DIR=/opt/aigo
LOCAL_DIR=/usr/local
ROOT_DIR=/
UDEV_RULES_DIR=/lib/udev/rules.d
AIGO_USER=aigo
AIGO_HOME=/home/$AIGO_USER
SUBDIR=`date +%Y%m%d-%H%M%S`
LOG_DIR=/var/log/$AIGO_USER/$SUBDIR

chfile() {
	FNAME=$1
	FDIR=$2
	OWN=$3
	MOD=$4
	
	rm -rf $FDIR/$FNAME
	mkdir -p $FDIR
	cp -f $AIGO_TOOLS_DIR/$FNAME $FDIR
	chown $OWN $FDIR/$FNAME
	chmod $MOD $FDIR/$FNAME
}

rmfile() {
	FNAME=$1
	FDIR=$2
	
	rm -rf $FDIR/$FNAME
}

mkdir -p $LOG_DIR

## upgrade 2018.v1 alpha-2 (2018-03-27) ~ current (2018-05-??)

# disable apt-daily-upgrade & unattended-upgrade
systemctl stop apt-daily-upgrade.timer
systemctl disable apt-daily-upgrade.timer

systemctl stop unattended-upgrades.service
systemctl disable unattended-upgrades.service

# upgrade OS & Apps
apt-get update 2>&1 | tee $LOG_DIR/apt_update.log
apt dist-upgrade -y 2>&1 | tee $LOG_DIR/dist-upgrade.log

# TODO: add libgphoto2 repository & upgrade latest version
## Ref. https://blog.longwin.com.tw/2017/05/debian-package-downgrade-rollback-2017/
sudo add-apt-repository ppa:mutlaqja/libgphoto2 -y 2>&1 | tee $LOG_DIR/add_ppa-mutlaqja-libgphoto2.log
apt-get update 2>&1 | tee $LOG_DIR/apt_update_libgphoto2.log
sudo apt install libgphoto2-6=2.5.17+201804280945~ubuntu16.04.1 libgphoto2-l10n=2.5.17+201804280945~ubuntu16.04.1 libgphoto2-dev=2.5.17+201804280945~ubuntu16.04.1 libgphoto2-port12=2.5.17+201804280945~ubuntu16.04.1 -y 2>&1 | tee $LOG_DIR/upgrade_libqphoto2.log

# Support 4G Dongle
# cdc_ether
apt install usb-modeswitch -y 2>&1 | tee $LOG_DIR/inst_usb-modeswitch.log

grep eth1 /etc/network/interfaces
RET=$?
if [ $RET -ne 1 ] ; then
    cp /etc/network/interfaces /etc/network/interfaces.2018v1a2-2018v1a3
    sed -i 's|iface usb0 inet dhcp|iface usb0 inet dhcp\n\nallow-hotplug eth1\niface eth1 inet dhcp|' /etc/network/interfaces
fi

# add ccdciel , eqmodgui
# ~/Desktop/xx.desktop
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys AA716FC2 2>&1 | tee $LOG_DIR/add-key_AA716FC2.log
echo 'deb http://www.ap-i.net/apt unstable main' > /etc/apt/sources.list.d/skychart-unstable.list
apt-get update 2>&1 | tee $LOG_DIR/apt-update_skychart.log

apt install ccdciel -y 2>&1 | tee $LOG_DIR/inst_ccdciel.log
cp -f /usr/share/applications/ccdciel.desktop $AIGO_HOME/Desktop

apt install eqmodgui -y 2>&1 | tee $LOG_DIR/inst_eqmodgui.log
cp -f /usr/share/applications/eqmodgui.desktop $AIGO_HOME/Desktop

# apt install iw wireless-tools
apt install iw wireless-tools -y 2>&1 | tee $LOG_DIR/inst_iw_wireless-tools.log

# add eog
apt install eog -y 2>&1 | tee $LOG_DIR/inst_eog.log

# add noVNC
git clone --progress https://github.com/novnc/noVNC.git /opt/noVNC 2>&1 | tee $LOG_DIR/git-clone_noVNC.log
ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# TODO: No installed websockify
git clone --progress https://github.com/novnc/websockify /opt/noVNCi/utils/websockify 2>&1 | tee $LOG_DIR/git-clone_websockify.log

# https
mkdir /opt/noVNC/ssl
cp $AIGO_TOOLS_DIR/aigo_noVNC.pem /opt/noVNC/ssl
chmod 640 /opt/noVNC/ssl/aigo_noVNC.pem

chown -R $AIGO_USER.$AIGO_USER /opt/noVNC

cat <<EOF > $AIGO_HOME/.local/share/applications/aigo_novnc.desktop &&
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=noVNC Server
Comment=Share this desktop by noVNC
Exec=/opt/noVNC/utils/launch.sh --vnc localhost:5900 --cert /opt/noVNC/ssl/aigo_noVNC.pem --ssl-only
Icon=/opt/noVNC/images/icons/novnc-192x192.png
Terminal=false
Type=Application
StartupNotify=false
Categories=Network;RemoteAccess;
EOF

chown $AIGO_USER.$AIGO_USER $AIGO_HOME/.local/share/applications/aigo_novnc.desktop
chmod 644 $AIGO_HOME/.local/share/applications/aigo_novnc.desktop

ln -s $AIGO_HOME/.local/share/applications/aigo_novnc.desktop $AIGO_HOME/.config/autostart

chown $AIGO_USER.$AIGO_USER $AIGO_HOME/.config/autostart/aigo_novnc.desktop

# add PhotoPolarAlign
apt install python-tk -y 2>&1 | tee $LOG_DIR/inst_python-tk.log

git clone --progress https://github.com/ThemosTsikas/PhotoPolarAlign.git /opt/PhotoPolarAlign 2>&1 | tee $LOG_DIR/git-clone_PPA.log
chown -R $AIGO_USER.$AIGO_USER /opt/PhotoPolarAlign

cat <<EOF > $AIGO_HOME/.local/share/applications/photopolaralign.desktop &&
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=PhotoPolarAlign
Comment=A python utility to help align equatorial telescopes by imaging the Celestial Pole region.
Exec=bash -c 'cd /opt/PhotoPolarAlign ; /usr/bin/python ./PPA.py'
Icon=/opt/PhotoPolarAlign/PPALogo.bmp
Terminal=false
Type=Application
Categories=Education;Science;Astronomy;
EOF

chown $AIGO_USER.$AIGO_USER $AIGO_HOME/.local/share/applications/photopolaralign.desktop
chmod 644 $AIGO_HOME/.local/share/applications/photopolaralign.desktop

cp -f $AIGO_HOME/.local/share/applications/photopolaralign.desktop $AIGO_HOME/Desktop

# nginx default patch
apt install nginx-common -y 2>&1 | tee $LOG_DIR/inst_nginx-common.log

if [ ! -f /etc/nginx/sites-available/default.orig ] ; then
        cp -f /etc/nginx/sites-available/default /etc/nginx/sites-available/default.orig
fi

# disable nginx listen ipv6
# nginx support php
# TODO: nginx 504 Gateway Time-out
cd /etc/nginx/sites-available ; patch < /opt/aigo/default.diff

# add nginx
apt install nginx -y 2>&1 | tee $LOG_DIR/inst_nginx.log

# add php
apt install php -y 2>&1 | tee $LOG_DIR/inst_php.log

# add DSLR web control (Alpha4 Coming Soon)
apt install p7zip-full -y 2>&1 | tee $LOG_DIR/inst_p7zip-full.log

# boot test > picture
apt install plymouth-themes -y 2>&1 | tee $LOG_DIR/inst_plymouth-themes.log
chfile background-tile.png /usr/share/plymouth/themes/spinner root.root 644
update-alternatives --config default.plymouth $LOG_DIR/inst_update-default.plymouth.log

# TODO:
# 5GHz (generic is 2.4GHz)
# PlanetaryImager
# wxAstroCapture
# DSLR web control (Author By QK Sampson)

# chown , chmod ~/Desktop/*.desktop
chown $AIGO_USER.$AIGO_USER $AIGO_HOME/Desktop/*.desktop
chmod 644 $AIGO_HOME/*.desktop

# autoremove & clean apt files
apt autoremove -y 2>&1 | tee $LOG_DIR/autoremove.log
apt clean

# lock kernel version (2018-03-27 4.14.30-v7+) 2018.v1 alpha-2
## KERNEL_FW_VER=b4d3b40a706b37ead86482f6f629631aa5ea6213

## 2018-05-01
## 4.14.37-v7+ 4.14.37+
## 461ee53cef85d14b8511e9f6d5dce8c0ac1d595a

## 2018-05-19
## 4.14.39-v7+ 4.14.39+

# Upgrade kernel
apt install expect -y 2>&1 | tee $LOG_DIR/inst_expect.log
expect $AIGO_TOOLS_DIR/rpi-update.exp
#expect $AIGO_TOOLS_DIR/rpi-update.exp $KERNEL_FM_VERSION

# change /boot/config.txt & cmdline.txt
chfile cmdline.txt /boot root.root 755
chfile config.txt  /boot root.root 755

# add /lib/firmware/brcm/brcmfmac43455-sdio.txt & BCM4345C0.hcd & brcmfmac43455-sdio.bin & brcmfmac43455-sdio.clm_blob
chfile BCM4345C0.hcd               /lib/firmware/brcm root.root 644
chfile brcmfmac43455-sdio.bin      /lib/firmware/brcm root.root 644
chfile brcmfmac43455-sdio.clm_blob /lib/firmware/brcm root.root 644
chfile brcmfmac43455-sdio.txt      /lib/firmware/brcm root.root 644

# system.conf DefaultTimeoutStopSec=10s
sed -i 's|#DefaultTimeoutStopSec=90s|DefaultTimeoutStopSec=10s|' /etc/systemd/system.conf

# TODO: change pcmanfm wallpaper
cp $AIGO_HOME/.config/pcmanfm/LXDE/desktop-items-0.conf $AIGO_HOME/.config/pcmanfm/LXDE/desktop-items-0.conf.2018v1a2-2018v1a3
sed -i 's|/usr/share/images/desktop-base/SFPI.png|/usr/local/share/pixmaps/aigo_background-1920x1080.png|' $AIGO_HOME/.config/pcmanfm/LXDE/desktop-items-0.conf
sed -i 's|wallpaper_mode=.*|wallpaper_mode=center|' $AIGO_HOME/.config/pcmanfm/LXDE/desktop-items-0.conf

# TODO: rm lxde-rc.xml
rm -f $AIGO_HOME/.config/openbox/lxde-rc.xml

dialog --msgbox "A reboot is needed" 20 60
sync
sync
reboot

exit 0
