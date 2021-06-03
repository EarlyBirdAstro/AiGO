#!/bin/bash

# Everything else needs to be run as root
BNAME=`basename $0`
if [[ ${EUID} -ne 0 ]]; then
  TITLE="Error !"
  MSG="Script must be run as root.\n\nTry 'sudo $BNAME'\n"

  whiptail --clear --title " $TITLE " --msgbox "\n$MSG" 10 70

  exit 1
fi

VERSION=0.21.5.0_pre

do_reboot() {
  if [ x"$ASK_TO_REBOOT" == x"true" ]; then
    whiptail --yesno "Would you like to reboot now?" 20 60
    if [ $? -eq 0 ]; then # yes
      sync ; sync
      shutdown -r now
    fi
  else
    whiptail --msgbox "A reboot is needed" 20 60
    sync ; sync
    shutdown -r now
  fi

  return 0
}

mkd() {
  DIR=$1
  OWN=$2
  MOD=$3

  if [ ! -d $DIR ] ; then
    mkdir -p $DIR
    chown $OWN $DIR
    chmod $MOD $DIR
  fi
}

HOS_DIR=/opt/AiGO
LOG_DIR=/var/log/AiGO
UNAME=aigo
#UNAME=ubuntu
UHOME=/home/$UNAME
#listSystemd='systemctl list-units --type service --state active'
listSystemd='systemctl list-units --state active'

mkd $LOG_DIR root.root 0755


# A start job is running for Wait for Network to be Configured
eval '$listSystemd' | grep 'systemd-networkd-wait-online.service'
RET=$?
if [ $RET -eq 0 ] ; then
  systemctl stop systemd-networkd-wait-online.service
  systemctl disable systemd-networkd-wait-online.service
  systemctl mask systemd-networkd-wait-online.service
fi

# change locale
grep 'LANG="en_US.UTF-8"' /etc/default/locale
RET=$?
if [ $RET -eq 1 ] ; then
  cp -a /etc/default/locale /etc/default/locale.orig
  sed -i 's/LANG=.*/LANG="en_US.UTF-8"/' /etc/default/locale
fi

# locale-gen zh_TW.UTF-8
locale-gen zh_TW.UTF-8
update-locale

# change timezone
timedatectl set-timezone 'Asia/Taipei'

# adjtime LOCAL
timedatectl set-local-rtc 1

# disable or remove unattended-upgrades apt-daily apt-daily-upgrade
eval '$listSystemd' | grep 'unattended-upgrades.service'
RET=$?
if [ $RET -eq 0 ] ; then
  systemctl stop unattended-upgrades
  apt purge unattended-upgrades 2>&1 -y | tee $LOG_DIR/apt-purge_unattended-upgrades.log
fi

eval '$listSystemd' | grep 'apt-daily.timer'
RET=$?
if [ $RET -eq 0 ] ; then
  systemctl stop apt-daily.timer
  systemctl disable apt-daily.timer
  systemctl mask apt-daily.timer
fi

eval '$listSystemd' | grep 'apt-daily-upgrade.timer'
RET=$?
if [ $RET -eq 0 ] ; then
  systemctl stop apt-daily-upgrade.timer
  systemctl disable apt-daily-upgrade.timer
  systemctl mask apt-daily-upgrade.timer
fi

apt-get update 2>&1 | tee $LOG_DIR/apt-update.log

# NTP
dpkg -s ntp
RET=$?
if [ $RET -eq 1 ] ; then
  timedatectl set-ntp no
  apt install ntp -y 2>&1 | tee $LOG_DIR/apt-install_ntp.log

  systemctl start ntp
  systemctl restart ntp
fi

# cpufrequtils (cpufreq-set -r -g powersave)
dpkg -s cpufrequtils
RET=$?
if [ $RET -eq 1 ] ; then
   apt install cpufrequtils -y 2>&1 | tee $LOG_DIR/apt-install_cpufrequtils.log
   
   #cp /usr/share/doc/cpufrequtils/examples/cpufrequtils.loadcpufreq.sample /etc/default/loadcpufreq
   #cp /usr/share/doc/cpufrequtils/examples/cpufrequtils.sample /etc/default/cpufrequtils

   systemctl disable cpufrequtils
   systemctl disable loadcpufreq
fi

# rc.local
if [ ! -f /etc/rc.local ] ; then
  echo '#!/bin/sh -e

exit 0' > /etc/rc.local
  chmod 755 /etc/rc.local
fi

# LXQt
dpkg -s lxqt-panel
RET=$?
if [ $RET -eq 1 ] ; then
  #apt install --no-install-recommends lxqt-session lxqt-panel lxterminal xserver-xorg-video-fbdev -y 2>&1 | tee $LOG_DIR/apt-install_lxqt.log
  
  #apt install lxqt-session lxqt-panel lxterminal mutter xserver-xorg-video-fbdev xserver-xorg-input-evdev -y 2>&1 | tee $LOG_DIR/apt-install_lxqt.log
  
  apt install lxqt-session lxqt-panel qterminal openbox obconf-qt network-manager-gnome xserver-xorg-video-fbdev xserver-xorg-input-evdev -y 2>&1 | tee $LOG_DIR/apt-install_lxqt.log
  #apt install lxqt-session lxqt-panel qterminal openbox obconf-qt xserver-xorg-video-vesa xserver-xorg-input-evdev -y 2>&1 | tee $LOG_DIR/apt-install_lxqt.log
fi

# remove gdm3
apt purge gdm3 -y 2>&1 | tee $LOG_DIR/apt-purge_gdm3.log

# lightdm & autologin
dpkg -s lightdm
RET=$?
if [ $RET -eq 1 ] ; then
  #apt install --no-install-recommends lightdm -y 2>&1 | tee $LOG_DIR/apt-install_lightdm.log
  apt install lightdm -y 2>&1 | tee $LOG_DIR/apt-install_lightdm.log

  LCONF=/etc/lightdm/lightdm.conf.d/01_$UNAME.conf
  echo "[SeatDefaults]
autologin-user=$UNAME
autologin-user-timeout=0
user-session=lxqt" > $LCONF
fi

# chinese font
dpkg -s fonts-wqy-zenhei
RET=$?
if [ $RET -eq 1 ] ; then
  apt install fonts-wqy-zenhei -y 2>&1 | tee $LOG_DIR/apt-install_fonts-wqy-zenhei.log
fi

# TODO: fcitx / ibus / scim
dpkg -s fcitx-chewing
RET=$?
RET=0
if [ $RET -eq 1 ] ; then
  apt install fcitx-chewing fcitx-ui-qimpanel -y 2>&1 | tee $LOG_DIR/apt-install_fcitx-chewing.log

  mkd $UHOME/.config $UNAME.$UNAME 0700
  mkd $UHOME/.config/fcitx $UNAME.$UNAME 0700

  cp dot.config+fcitx+profile $UHOME/.config/fcitx/profile
  chown $UNAME.$UNAME $UHOME/.config/fcitx/profile
  chmod 600 $UHOME/.config/fcitx/profile
fi

# install packages
U2004_ADD_PKGS='net-tools traceroute nmap build-essential ncdu usb-modeswitch mlocate p7zip-full firefox firefox-locale-zh-hant'
apt install $U2004_ADD_PKGS -y 2>&1 | tee $LOG_DIR/apt-install_packages.log

# x11vnc
dpkg -s x11vnc
RET=$?
if [ $RET -eq 1 ] ; then
  apt install x11vnc -y 2>&1 | tee $LOG_DIR/apt-install_x11vnc.log

  mkd $UHOME/.config $UNAME.$UNAME 0700
  mkd $UHOME/.config/autostart $UNAME.$UNAME 0700
  cp -a /usr/share/applications/x11vnc.desktop $UHOME/.config/autostart
  chmod $UNAME.$UNAME $UHOME/.config/autostart/x11vnc.desktop

  sed -i 's/Exec=.*/Exec=x11vnc -xkb -nopw -shared -forever -repeat -geometry 1280x720/' $UHOME/.config/autostart/x11vnc.desktop
fi

# ssh security
grep '^AllowUsers' /etc/ssh/sshd_config | grep $UNAME
RET=$?
if [ $RET -eq 1 ] ; then
  cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
  sed -i "s/AllowUsers/AllowUsers $UNAME/" /etc/ssh/sshd_config
  cat << EOF >> /etc/ssh/sshd_config
# The below setting was add by StarfruitPi.
GSSAPIAuthentication no
GSSAPICleanupCredentials no
UseDNS no
EOF

  service ssh reload
fi

# vim bg=dark
echo 'set bg=dark' > /root/.vimrc
echo 'set bg=dark' > $UHOME/.vimrc
chown $UNAME.$UNAME $UHOME/.vimrc

# systemd Star/Stop Timeout
grep '^#DefaultTimeoutStartSec' /etc/systemd/system.conf
RET=$?
if [ $RET -eq 0 ] ; then
  cp -a /etc/systemd/system.conf /etc/systemd/system.conf.orig
  sed -i 's/^#DefaultTimeoutStartSec=.*/DefaultTimeoutStartSec=10s/' /etc/systemd/system.conf
  sed -i 's/^#DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=10s/' /etc/systemd/system.conf
fi

# change hosts
sed -i 's/127.0.1.1.*/127.0.1.1\tAiGO/' /etc/hosts

# AiGO repository
echo 'deb https://aigo.serveftp.org/test/ubuntu ./focal main' > /etc/apt/sources.list.d/aigo-ubuntu-focal.list
apt-key adv --keyserver keyserver.ubuntu.com --recv 50842E4A

# install add-apt-repository cli
dpkg -s software-properties-common
RET=$?
if [ $RET -eq 1 ] ; then
  apt install software-properties-common -y 2>&1 | tee $LOG_DIR/apt-install_software-properties-common.log
fi

# PHD2 repository
add-apt-repository ppa:pch/phd2 -y 2>&1 | tee $LOG_DIR/add-apt-repository_pch-phd2.log

# KStars Bleeding repository
apt-add-repository ppa:mutlaqja/ppa -y 2>&1 | tee $LOG_DIR/add-apt-repository_mutlaqja.log

apt-get update 2>&1 | tee $LOG_DIR/apt-update_aigo.log

# lin_guider
dpkg -s lin-guider
RET=$?
if [ $RET -eq 1 ] ; then
  apt install lin-guider -y 2>&1 | tee $LOG_DIR/apt-install_lin-guider.log
fi

# TODO: StarsPi

# PHD2
dpkg -s phd2
RET=$?
if [ $RET -eq 1 ] ; then
 
  apt install phd2 -y 2>&1 | tee $LOG_DIR/apt-install_phd2.log
fi

# INDI
dpkg -s indi-full
RET=$?
if [ $RET -eq 1 ] ; then
  apt install indi-full -y 2>&1 | tee $LOG_DIR/apt-install_indi.log
fi

# TODO: IndiStarter

# KStars
dpkg -s kstars-bleeding
RET=$?
if [ $RET -eq 1 ] ; then
  apt install kstars-bleeding -y 2>&1 | tee $LOG_DIR/apt-install_kstars-bleeding.log
fi

# INDIGO & autostart indigo.service
dpkg -s indigo
RET=$?
if [ $RET -eq 1 ] ; then
  echo "deb [trusted=yes] https://indigo-astronomy.github.io/indigo_ppa/ppa indigo main" > /etc/apt/sources.list.d/indigo.list
  apt update
  apt install indigo indigo-control-panel ain-imager -y 2>&1 | tee $LOG_DIR/apt-install_indogo.log

  IF=/lib/systemd/system/indigo.service
  echo "[Unit]
Description=Indigo server

[Service]
User=$UNAME
PAMName=login
ExecStart=/usr/bin/indigo_server --enable-rpi-management
StandardOutput=file:/var/log/indigo.log
StandardError=file:/var/log/indigo.log

[Install]
WantedBy=multi-user.target
" > $IF

  systemctl enable indigo.service
fi

# gPhoto2
dpkg -s gphoto2
RET=$?
if [ $RET -eq 1 ] ; then
   apt install gphoto2 -y 2>&1 | tee $LOG_DIR/apt-install_gphoto2.log
fi

# Memo: Lin-guide devel
# sudo apt install qtbase5-dev libusb-1.0-0-dev libgphoto2-dev libwiringpi-dev

# remove not need packages
U2004_PURGE_PKGS=' acl alsa-topology-conf alsa-ucm-conf'
#U2004_PURGE_PKGS+=' adwaita-icon-theme-full' phd2 depend
U2004_PURGE_PKGS+=' bind9-dnsutils bind9-host bind9-libs btrfs-progs byobu'
U2004_PURGE_PKGS+=' cloud-init cloud-guest-utils cloud-initramfs-copymods cloud-initramfs-dyn-netconf colord-data cpus* libcupsfilters1
'
#U2004_PURGE_PKGS+=' crda' linux-linux-modules-x.y.z-n-raspi depend
U2004_PURGE_PKGS+=' dmeventd'
U2004_PURGE_PKGS+=' eatmydata'
U2004_PURGE_PKGS+=' ffmpegthumbnailer friendly-recovery ftp'
U2004_PURGE_PKGS+=' gcr gnome-keyring gnome-keyring-pkcs11 gstreamer1.0-gl gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-pulseaudio gstreamer1.0-x'
U2004_PURGE_PKGS+=' '`dpkg -l | grep gir | awk '{print $2" "}' | tr -d '\n'`
U2004_PURGE_PKGS+=' humanity-icon-theme'
U2004_PURGE_PKGS+=' info'
U2004_PURGE_PKGS+=' lvm2 lxqt-powermanagement'
U2004_PURGE_PKGS+=' mdadm mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers mobile-broadband-provider-info mtr-tiny mysql-common'
U2004_PURGE_PKGS+=' mutter mutter-common'
#U2004_PURGE_PKGS+=' netplan.io network-manager-pptp'
U2004_PURGE_PKGS+=' netplan.io'
U2004_PURGE_PKGS+=' open-iscsi'
#U2004_PURGE_PKGS+=' ocl-icd-libopencl1' kstars-bleeding depend
U2004_PURGE_PKGS+=' p11-kit p11-kit-modules perl-openssl-defaults'
U2004_PURGE_PKGS+=' qlipper qps qtwayland5'
U2004_PURGE_PKGS+=' sg3-utils sg3-utils-udev snapd'
U2004_PURGE_PKGS+=' telnet'
U2004_PURGE_PKGS+=' ubuntu-advantage-tools update-manager-core update-notifier-common ubuntu-release-upgrader-core'
U2004_PURGE_PKGS+=' wamerican'
U2004_PURGE_PKGS+=' xfsprogs xscreensaver xscreensaver-data xserver-xorg-video-all xserver-xorg-video-amdgpu xserver-xorg-video-ati xserver-xorg-video-nouveau xserver-xorg-video-radeon xserver-xorg-video-vesa xserver-xorg-legacy'

apt purge $U2004_PURGE_PKGS -y 2>&1 | tee $LOG_DIR/apt-purge_packages.log

# ain-imager depend avahi-daemon
dpkg -s avahi-daemon
RET=$?
if [ $RET -eq 1 ] ; then
   apt install avahi-daemon -y 2>&1 | tee $LOG_DIR/apt-install_avahi-daemon.log
fi

# dist-upgrade
## 避免 dpkg-preconfigure 出現 keyboard-configuration 互動畫面
RET=0
if [ $RET -eq 1 ] ; then
  DEBIAN_FRONTEND=noninteractive apt -o Dpkg::Options::="--force-confnew" dist-upgrade -y 2>&1 | tee $LOG_DIR/apt-dist-upgrade.log
fi

# TODO: first boot init lxqt/*
mkd $UHOME/.config/lxqt $UNAME.$UNAME 0775
cp -a /usr/share/lxqt/*.conf $UHOME/.config/lxqt
chown -R $UNAME:$UNAME $UHOME/.config/lxqt

# lxqt quicklaunch
#sed -i 's/type=quicklaunch/type=quicklaunch\napps\\1\\desktop=\/usr\/local\/share\/applications\/aigo_config.desktop\napps\\2\\desktop=\/usr\/share\/applications\/phd2.desktop\napps\\3\\desktop=\/usr\/share\/applications\/lin_guider.desktop\napps\\4\\desktop=\/usr\/share\/applications\/org.kde.kstars.desktop\napps\\size=4/' $UHOME/.config/lxqt/panel.conf
sed -i 's/type=quicklaunch/type=quicklaunch\napps\\1\\desktop=\/usr\/local\/share\/applications\/aigo_config.desktop\napps\\2\\desktop=\/usr\/share\/applications\/phd2.desktop\napps\\3\\desktop=\/usr\/share\/applications\/lin_guider.desktop\napps\\4\\desktop=\/usr\/share\/applications\/org.kde.kstars.desktop\napps\\5\\desktop=\/usr\/share\/applications\/indigo-control-panel.desktop\napps\\6\\desktop=\/usr\/share\/applications\/ain-imager.desktop\napps\\size=6/' $UHOME/.config/lxqt/panel.conf
# TODO: apt-mark hold

dpkg -s ifupdown
RET=$?
if [ $RET -eq 1 ] ; then
  apt install ifupdown -y 2>&1 | tee $LOG_DIR/apt-install_ifupdown.log
fi

# RaspAP , libmain0 , php7.4-cgi
systemctl disable systemd-resolved.service

apt install php-cgi -y 2>&1 | tee $LOG_DIR/apt-install_php-cgi.log
apt install gamin -y 2>&1 | tee $LOG_DIR/apt-install_gamin.log
curl -sL https://install.raspap.com | tee raspap_install.sh
bash -x ./raspap_install.sh -o 0 -a 0 -y | tee $LOG_DIR/raspap_install.log
rm -f raspap_install.sh

# fix /tmp/dnsmasq.log permission start dnsmasq fail
sed -i 's/log-facility=.*/log-facility=\/var\/log\/dnsmasq.log/' /etc/dnsmasq.d/090_raspap.conf

# fix systemd-resolved mark hold dnsmasq
systemctl enable dnsmasq

# lighttpd ssl
LD=/etc/lighttpd
if [ ! -f $LD/server.pem ] ; then
  cd $LD ; openssl req -new -x509 -subj "/C=TW/L=Kaohsiung/O=AiGO/emailAddress=earlybird.astro@gmail.com" -keyout server.pem -days 1825 -nodes -out server.pem
  lighttpd-enable-mod ssl
fi

## lighttpd rewrite exclude /vaw/www/html/aigo
#sed -i 's/dist|app|ajax|config/dist|app|ajax|config|aigo/' /etc/lighttpd/conf-available/50-raspap-router.conf

# lighttpd rewrite /vaw/www/html to /var/www/html/raspap
WD=/var/www
HD=html
RD=raspap
if [ ! -d $WD/$HD/$RD ] ; then
  mv $WD/$HD $WD/$RD

  mkdir $WD/$HD
  chown www-data.www-data $WD/$HD
  mv $WD/$RD $WD/$HD

  RF=$LD/conf-available/50-raspap-router.conf
  sed -i 's/(?!(dist/raspap\/(?!(dist/' $RF
  sed -i 's/\/(.*?)/\/raspap\/(.*?)/' $RF
  sed -i 's/\/index.php/\/raspap\/index.php/' $RF
fi

# change ssid & wpa_passphrase
HF=/etc/hostapd/hostapd.conf
if [ -f $HF ] ; then
  MAC=`ifconfig eth0 |grep 'ether' | awk '{print $2}' | awk -F ':' '{print $4$5$6}'`
  sed -i "s/^ssid=.*/ssid=AiGO_${MAC}/" $HF
  sed -i 's/^wpa_passphrase=.*/wpa_passphrase=1234567890/' $HF
fi

# noVNC
ND=/opt/noVNC
if [ ! -d $ND ] ; then
  cd /opt ; git clone https://github.com/novnc/noVNC.git
  
  # depend websockify
  cd $ND/utils ; git clone https://github.com/novnc/websockify
  
  chown -R $UNAME:$UNAME $ND
fi

# websocket.py depend numpy
dpkg -s numpy-stl
RET=$?
if [ $RET -eq 1 ] ; then
  apt install numpy-stl -y 2>&1 | tee $LOG_DIR/apt-install_numpy-stl.log
fi

# aigo-tools
dpkg -s aigo-tools
RET=$?
if [ $RET -eq 1 ] ; then
  apt install aigo-tools -y 2>&1 | tee $LOG_DIR/apt-install_aigo-tools.log

  mkd $UHOME/.config/pcmanfm-qt $UNAME.$UNAME 0775
  mkd $UHOME/.config/pcmanfm-qt/lxqt $UNAME.$UNAME 0775
  cp -a /usr/share/pcmanfm-qt/lxqt/settings.conf $UHOME/.config/pcmanfm-qt/lxqt
  chown -R $UNAME:$UNAME $UHOME/.config/pcmanfm-qt/lxqt

  # change to AiGO wallpaper
  sed -i 's/WallpaperMode=.*/WallpaperMode=center/' $UHOME/.config/pcmanfm-qt/lxqt/settings.conf
  sed -i 's/Wallpaper=.*/Wallpaper=\/usr\/local\/share\/pixmaps\/aigo_background-1920x1080.png\nWallpaperDirectory=\nWallpaperRandomize=false\n/' $UHOME/.config/pcmanfm-qt/lxqt/settings.conf

  # noVNC ssl & autostart
  if [ -d $ND ] ; then
    mkdir $ND/ssl
    cp -a /opt/aigo/aigo_noVNC.pem $ND/ssl
    chown -R $UNAME.$UNAME $ND/ssl

    cp -a /opt/aigo/aigo_novnc.desktop $UHOME/.config/autostart
    chown $UNAME.$UNAME $UHOME/.config/autostart/aigo_novnc.desktop
  fi
fi

# setup networking
grep 'allow-hotplug usb0' /etc/network/interfaces
RET=$?
if [ $RET -eq 1 ] ; then
  echo 'allow-hotplug eth0
iface eth0 inet dhcp

allow-hotplug eth1
iface eth1 inet dhcp

allow-hotplug wlan0
iface wlan0 inet dhcp

allow-hotplug usb0
iface usb0 inet dhcp

allow-hotplug enp0s3
iface enp0s3 inet dhcp' >> /etc/network/interfaces

  systemctl restart networking
fi

# My IP
grep 'My IP address' /etc/issue
RET=$?
if [ $RET -eq 1 ] ; then
  echo '
My IP address: \4' >> /etc/issue
fi

# change hostname
echo 'AiGO' > /etc/hostname
sed -i 's/127.0.0.1 localhost/127.0.0.1 localhost\n127.0.1.1 AiGO/' /etc/hosts

# clean autoclean autoremove
apt clean -y 2>&1 | tee $LOG_DIR/apt-clean.log
apt autoclean -y 2>&1 | tee $LOG_DIR/apt-autoclean.log
apt autoremove -y 2>&1 | tee $LOG_DIR/apt-autoremove.log

rm -rf /etc/cloud
rm -rf /etc/netplan
find /boot -type f -iname *bak -exec rm -f {} \;

ASK_TO_REBOOT=true
do_reboot
