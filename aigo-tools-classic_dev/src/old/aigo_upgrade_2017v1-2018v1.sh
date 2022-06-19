#!/bin/bash

# Everything else needs to be run as root
BNAME=`basename $0`
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo $BNAME'\n"
  exit 1
fi

AIGO_TOOLS_DIR=/opt/aigo
AIGO_USER=aigo
AIGO_HOME=/home/$AIGO_USER
SUBDIR=`date +%Y%m%d-%H%M%S`
LOG_DIR=/var/log/$AIGO_USER/$SUBDIR
# lock kernel version (2018-03-27 4.14.30-v7+)
#KERNEL_FW_VER=b4d3b40a706b37ead86482f6f629631aa5ea6213

mkdir -p $LOG_DIR

# TODO:
# is upgraded flag

# TODO: Add AiGO Repository Public Key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 50842E4A | tee $LOG_DIR/add-key_50842E4A.log

# TODO: hold < version then unhold
# TODO: Unhold indi*
sudo apt-mark unhold indi-aagcloudwatcher indi-apogee indi-asi indi-bin indi-dsi indi-duino indi-eqmod indi-ffmv indi-fishcamp indi-fli indi-full indi-gphoto indi-gpsd indi-maxdomeii indi-mi indi-qhy indi-qsi indi-sbig indi-sx libindi-data libindi-dev libindi1 | tee $LOG_DIR/unhold.log

# TODO:
# Disable mutlaqja-ubuntu-ppa-xenial.list
# Disable *.list ?
# Add aigo-upgrade.list
# deb file:///tmp/aigo-upgrade/debs
# wget aigo-upgrade.xz
# uncompress to /tmp/aigo-upgrade/debs
# apt-get install -f
sudo apt-get update | tee $LOG_DIR/apt_update.log
sudo apt dist-upgrade -y | tee $LOG_DIR/dist-upgrade.log
#sudo apt install asi-common -y | tee $LOG_DIR/inst_asi-common.log
sudo apt-get install -f -y | tee $LOG_DIR/install-f.log

sudo apt install expect -y | tee $LOG_DIR/inst_expect.log
sudo expect $AIGO_TOOLS_DIR/rpi-update.exp
#sudo expect $AIGO_TOOLS_DIR/rpi-update.exp $KERNEL_FM_VERSION

sudo apt autoremove -y | tee $LOG_DIR/autoremove.log
sudo apt clean

# TODO: hold
#sudo apt-mark hold indi-aagcloudwatcher indi-apogee indi-armadillo-platypus indi-asi indi-bin indi-dsi indi-duino indi-eqmod indi-ffmv indi-fishcamp indi-fli indi-full indi-gphoto indi-gpsd indi-gpsnmea indi-maxdomeii indi-mgen indi-mi indi-nexdome indi-nexstarevo indi-qhy indi-qsi indi-sbig indi-sx libindi-data libindi-dev libindi1 | tee $LOG_DIR/hold.log

# TODO: /lib/firmware/brcm/brcmfmac43455-sdio.txt
sudo cp -f $AIGO_TOOLS_DIR/brcmfmac43455-sdio.txt /lib/firmware/brcm/

# TODO: rm ~/.local/share/applications/phd.desktop , lin_guider.desktop
rm -f $AIGO_HOME/.local/share/applications/lin_guider.desktop
rm -f $AIGO_HOME/.local/share/applications/phd2.desktop

# TODO: remove astrometry.net index files
#rm -f /usr/share/astrometry/*

su $AIGO_USER -c 'rm -f ~/.cache/menus/*'

echo "Press 'Enter' key to reboot"
read

sync
sync
reboot

