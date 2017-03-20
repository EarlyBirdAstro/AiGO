#!/bin/sh

# Everything else needs to be run as root
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo aigo_config'\n"
  exit 1
fi

AUTHOR="Contributed by Cheng-Chang Ho."
VER=0.0.93

do_change_ssid() {
OF=/etc/init.d/change_ssid_once
HF=/etc/hostapd/hostapd.conf

# now set up an init.d script
echo "#!/bin/sh
### BEGIN INIT INFO
# Provides:          change_ssid_once
# Required-Start:
# Required-Stop:
# Default-Start: 3
# Default-Stop:
# Short-Description: Change SSID to AiGO_{HWaddr}
# Description:
### END INIT INFO

. /lib/lsb/init-functions

case "\$1" in
  start)
    log_daemon_msg "Starting change_ssid_once" &&
    cp $HF $HF.once &&
    MAC=\`ifconfig eth0 | grep 'HWaddr' | awk '{print \$5}' | awk -F ':' '{print \$4\$5\$6}'\`
    sed -i \"s/^ssid=.*/ssid=AiGO_\${MAC}/\" $HF &&
    update-rc.d change_ssid_once remove &&
    rm /etc/init.d/change_ssid_once &&
    log_end_msg \$?
    ;;
  *)
    echo "Usage: \$0 start" >&2
    exit 3
    ;;
esac
" > $OF

chmod +x /etc/init.d/change_ssid_once &&
update-rc.d change_ssid_once defaults &&

return 0
}

do_change_ssid

