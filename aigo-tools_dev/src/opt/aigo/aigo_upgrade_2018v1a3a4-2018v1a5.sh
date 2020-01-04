#!/bin/sh

# Everything else needs to be run as root
BNAME=`basename $0`
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo $BNAME'\n"
  exit 1
fi

if ! ping -c 1 aigo.serveftp.org >> /dev/null 2>&1; then
   echo "You need to have working Internet connection to run this script."
   exit 1
fi

AIGO_TOOLS_DIR=/opt/aigo
AIGO_USER=aigo
AIGO_HOME=/home/$AIGO_USER
SUBDIR=`date +%Y%m%d-%H%M%S`
LOG_DIR=/var/log/$AIGO_USER/$SUBDIR
# lock kernel version (2018-12-26 4.14.90-v7+)
##KERNEL_FW_VER=da5948d8ef8354557732d9c8f5ad5e7e24374a69

mkdir -p $LOG_DIR

### upgrade 2018.v1 alpha-3 (2018-05-22) ~ current (2018-12-xx)

# Upgrade kernel
apt install expect -y | tee $LOG_DIR/inst_expect.log
expect $AIGO_TOOLS_DIR/rpi-update.exp
##expect $AIGO_TOOLS_DIR/rpi-update.exp $KERNEL_FM_VERSION

# rm old modules (aigo_sysprep.sh)
#rm -rf /lib/modules/4.14.30*
#rm -rf /lib/modules/4.14.41*
#rm -rf /lib/modules/4.14.86*

# Upgrade linux-firmware
apt-get update | tee $LOG_DIR/apt_update.log
apt install --only-upgrade linux-firmware -y | tee $LOG_DIR/linux-firmware_upgrade.log

# Install PoleMaster
#dpkg -i PoleMaster_Qt-for_RPI-Ubuntu-1.3.5.0.deb | tee $LOG_DIR/polemaster_install.log
apt install polemaster -y | tee $LOG_DIR/polemaster_install.log
echo '/usr/bin/PoleMaster' > /etc/ld.so.conf.d/polemaster.conf
ldconfig
cp /usr/share/applications/PoleMaster.desktop $AIGO_HOME/Desktop

apt autoremove -y | tee $LOG_DIR/autoremove.log
apt clean

dialog --msgbox "A reboot is needed" 20 60
sync
sync
reboot

exit 0
