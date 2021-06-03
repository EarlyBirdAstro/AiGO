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

AIGO_TOOLS_DIR=/opt/aigo
LOCAL_DIR=/usr/local
ROOT_DIR=/
UDEV_RULES_DIR=/lib/udev/rules.d
AIGO_USER=aigo
AIGO_HOME=/home/$AIGO_USER
SUBDIR=`date +%Y%m%d-%H%M%S`
KERVER=5.4.3
BOOT_PART=/boot/firmware

# TODO: first boot expand filesystem
sed -i 's|rootwait fixrtc$|rootwait fixrtc init=/opt/aigo/aigo_init-resize.sh|' $BOOT_PART/cmdline.txt
chown root.root $BOOT_PART/cmdline.txt
chmod 755       $BOOT_PART/cmdline.txt
chmod 755	    /opt/aigo/aigo_init-resize.sh

cat <<EOF > /etc/init.d/resize2fs_once &&
#!/bin/sh
### BEGIN INIT INFO
# Provides: resize2fs_once
# Required-Start:
# Required-Stop:
# Default-Start: 3
# Default-Stop:
# Short-Description: Resize the root filesystem to fill partition
# Description:
### END INIT INFO

. /lib/lsb/init-functions

ROOT_DEV=\`findmnt / -o source -n\`

case "\$1" in
	start)
		log_daemon_msg "Starting resize2fs_once"
		resize2fs \$ROOT_DEV &&
		update-rc.d resize2fs_once remove &&
		rm /etc/init.d/resize2fs_once &&
		log_end_msg \$?
		;;
	*)
		echo "Usage: \$0 start" >&2
		exit 3
	;;
esac
EOF

chmod +x /etc/init.d/resize2fs_once &&
update-rc.d resize2fs_once defaults &&

# TODO: do_change_ssid once
bash /opt/aigo/do_change_ssid.sh

# TODO: clean apt cache file
apt autoremove
apt clean

# TODO: rm bash history
history -c
rm -rf /root/.bash_history
rm -rf $AIGO_HOME/.bash_history

# TODO: rm .cache
rm -rf /root/.cache/*
rm -rf $AIGO_HOME/.cache/*

# TODO: autostart aigo_config.desktop
cp /usr/local/share/applications/aigo_config.desktop $AIGO_HOME/.config/autostart
chown $AIGO_USER.$AIGO_USER $AIGO_HOME/.config/autostart/aigo_config.desktop
chmod 644 $AIGO_HOME/.config/autostart/aigo_config.desktop

# TODO: clean $HOME
cd $AIGO_HOME
rm -rf PHD2 .phd2 .PHDGuidingV2 phd2*
rm -rf .gphoto
rm -rf .ssh/known_hosts
rm -rf .indi
rm -rf .config/indistarter/*
rm -rf .config/GM_software/*
rm -rf .config/kstarsrc
rm -rf gps.txt
rm -rf /opt/noVNC/.git
rm -rf /opt/PhotoPolarAlign/.git
rm -rf /opt/PhotoPolarAlign/Testing
cd

# TODO: clean /var/log files
find /var/log -type f -exec rm -rf {} \;
rm -rf /var/log/aigo/*

# TODO: aigo repository
echo "deb http://aigo.serveftp.org/ubuntu ./focal main" > /etc/apt/sources.list.d/aigo-ubuntu-focal.list

dialog --msgbox "A shutdown is needed" 20 60
sync
sync
shutdown -h now

exit 0
