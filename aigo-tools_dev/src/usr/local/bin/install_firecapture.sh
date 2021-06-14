#!/bin/bash

# Everything else needs to be run as root
BNAME=`basename $0`
if [[ ${EUID} -ne 0 ]]; then
  TITLE="Error !"
  MSG="Script must be run as root.\n\nTry 'sudo bash ./$BNAME'\n"

  whiptail --clear --title " $TITLE " --msgbox "\n$MSG" 10 70

  exit 1
fi

ARCH=$(uname -m)

# get file from Google Drive
get_firecapture() {
  filename="firecapture_2.7b02-1.deb"
  fileid="1FEgECsDauTJt_oBh28qfewUHVIqOnCm0"

  echo -e "\n\nDownload '${filename}' file from Google Drive."
  echo -e "Waiting ...\n"
  curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${fileid}" > /dev/null
  curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${fileid}" -o ${filename}
  rm ./cookie

  return 0
}

get_firecapture

# check is deb file
file ${filename} | grep 'Debian binary package'
RET=$?
if [ $RET -eq 0 ] ; then
    if [ "$ARCH" = "aarch64" ] ; then
        # check is added armhf architectures
        dpkg --print-foreign-architectures | grep armhf
        RET=$?
        if [ $RET -eq 1 ] ; then
            dpkg --add-architecture armhf
        fi

        apt update

        # FireCapture depends (arhmf)
        #apt install libusb-1.0-0:armhf openjdk-11-jre:armhf -y 2>&1 | tee apt-install_depends.log
        apt install libusb-1.0-0:armhf openjdk-11-jre:armhf -y
    elif [ "$ARCH" = "armv7l" ] ; then
        apt update

        # FireCatpure depends
        #apt install libusb-1.0-0 -y 2>&1 | tee apt-install_depends.log
        apt install libusb-1.0-0 -y
    else
        echo 'Architecture is not arm64 | armhf !'
        exit 1
    fi

    #dpkg -i ${filename} 2>&1 | tee dpkg-i_${filename}.log
    dpkg -i ${filename}
    sleep 1
    rm -f ${filename}
    chown -R aigo /opt/firecapture # fix Permission denied
    chmod 644 /opt/firecapture/icon.png # fix menu display icon
    sed -i 's/read -r.*//' /opt/firecapture/start.sh # fix call firecapture.desktop end , process wait press an key

    # change heap size 1GB : 250 , 2GB : 1250 , >= 4GB : 2500 (armhf) , 3400 (arm64)
    MEM=`free -m | grep Mem | awk '{print $2}'`
    #MEM=`vmstat -SM -s | grep 'total memory' | awk '{print $1}'`
    HEAP=256
    if [ $MEM -le 1024 ] ; then
        HEAP=256
    elif [ $MEM -le 2048 ] ; then
        HEAP=1250
    else
        if [ "$ARCH" = "armv7l" ] ; then
            HEAP=2500
        else
            HEAP=3500
        fi
    fi

    # disable : FireCapture overwrite
    #grep 'heapsize=' /opt/firecapture/FireCapture.ini
    #RET=$?
    #if [ $RET -eq 1 ] ; then
    #  echo "heapsize=${HEAP}" | tee -a /opt/firecapture/FireCapture.ini
    #else
    #  sed -i "s/heapsize=.*/heapsize=${HEAP}/" /opt/firecapture/FireCapture.ini
    #fi

    # change JVM started with 'Xms' amount of memory = will be able to use a maximum of 'Xmx' amount of memory = ${HEAP}
    sed -i "s/ heap=.*/ heap=${HEAP}/" /opt/firecapture/start.sh
else
    echo "file type '${filename}' is not Debian binary package !"
    exit 1
fi

exit 0
