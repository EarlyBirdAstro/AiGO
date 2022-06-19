#!/bin/bash

# Everything else needs to be run as root
BNAME=`basename $0`
if [[ ${EUID} -ne 0 ]]; then
  printf "Script must be run as root. Try 'sudo $BNAME'\n"
  exit 1
fi

ASSIGN_VER=$1

VER=0.1.0
AUTHOR="Contributed by Cheng-Chang Ho."

AIGO_VER=`cat /etc/aigo_version`
BNAME=`basename $0`
AIGO_CONF=/usr/local/etc/aigo.conf

INPUT=/tmp/switch_libasicamera.input
OUTPUT=/tmp/switch_libasicamera.output

LIB_DIR=/usr/lib
LIB1_NAME=libASICamera.so
LIB2_NAME=libASICamera2.so
LIBS_NAME=libASICamera*.so.

source $AIGO_CONF

if [ x"$ASSIGN_VER" != x"" ] ; then
	echo "ASSIGN VER="$ASSIGN_VER

	if [ x"$ASSIGN_VER" = x"DEFAULT" ] ; then
		echo "DEFAULT VER="$LIBASICAMERA_DEFAULT

		_LIB_VER=$LIBASICAMERA_DEFAULT
	else
		_LIB_VER=$ASSIGN_VER

		file -E $LIB_DIR/$LIB1_NAME.$_LIB_VER > /dev/null
		lib1_notexist=$?

		file -E $LIB_DIR/$LIB2_NAME.$_LIB_VER > /dev/null
		lib2_notexist=$?

		if [ $lib1_notexist -ne 0 ] || [ $lib2_notexist -ne 0 ] ; then
			echo "libASICamera library version '"$_LIB_VER"' not found !"
			exit -1
		fi
	fi

	cd $LIB_DIR ; rm -rf $LIB1_NAME
	cd $LIB_DIR ; ln -s $LIB1_NAME.$_LIB_VER $LIB1_NAME

	cd $LIB_DIR ; rm -rf $LIB2_NAME
	cd $LIB_DIR ; ln -s $LIB2_NAME.$_LIB_VER $LIB2_NAME

	/sbin/ldconfig

	exit 0
fi

[ -f $OUTPUT ] && rm -f $OUTPUT
[ -f $INPUT ] && rm -f $INPUT

file -E $LIB_DIR/$LIB1_NAME > /dev/null
lib1_notexist=$?

file -E $LIB_DIR/$LIB2_NAME > /dev/null
lib2_notexist=$?

if [ $lib1_notexist -eq 0 ] ; then
	LIB1_VER=`file $LIB_DIR/$LIB1_NAME | awk '{print $5}' | awk -F "$LIB1_NAME." '{print $2}'`
else
	LIB1_VER=none
fi

if [ $lib2_notexist -eq 0 ] ; then
	LIB2_VER=`file $LIB_DIR/$LIB2_NAME | awk '{print $5}' | awk -F "$LIB2_NAME." '{print $2}'`
else
	LIB2_VER=none
fi

LIBS_VER=`ls -s $LIB_DIR/$LIBS_NAME* | awk '{print $2}' | awk -F "so." '{print $2}' | sort -u`

echo "LIB1 VER="$LIB1_VER
echo "LIB2 VER="$LIB2_VER

INDEX=$((0))
ver=[]
for v in $LIBS_VER
do
	echo "LIBS_VER="$v
	ver[$((INDEX))]=$v
	INDEX=$((INDEX+1))
done

echo "INDEX="$INDEX

MENUS=""
DEF_ITEM=""
for i in $(seq 0 $((INDEX-1)))
do
	echo "ver["$((i))"]="${ver[$((i))]}

	MENUS+=$((i+1))
	MENUS+=" "
	MENUS+="${ver[$i]}"
	MENUS+=" "

	echo "MENUS="$MENUS

	if [ ${ver[$i]} = $LIB1_VER ] ; then
		DEF_ITEM+=$((i+1))

		echo "DEF_ITEM="$DEF_ITEM
	fi
done

if [ x"$DEF_ITEM" = x"" ] ; then
	DEF_ITEM+=$INDEX
	echo "DEF_ITEM(none)="$DEF_ITEM
fi

# Color
# \Z 正常底色,字色 0=深灰, 1=紅, 2=綠, 3=黃, 4=藍, 5=紫, 6=亮藍, 7=黑底, 白字
# \Zr\Z 灰字, 底色 0=灰, 1=紅, 2=綠, 3=黃, 4=藍, 5=紫, 6=亮藍, 7=白底, 黑字

function do_switch-libasicamera() {
	_SELECT=$1
	echo "_SELECT="$_SELECT

	_LIB_VER=${ver[$((_SELECT-1))]}

	if dialog --colors --clear --title " Confirm " --cr-wrap --yesno "
 Switch libASICamera library version to \Z1$_LIB_VER\Zn ?" 7 59; then
		cd $LIB_DIR ; rm -rf $LIB1_NAME
		cd $LIB_DIR ; ln -s $LIB1_NAME.$_LIB_VER $LIB1_NAME


		cd $LIB_DIR ; rm -rf $LIB2_NAME
		cd $LIB_DIR ; ln -s $LIB2_NAME.$_LIB_VER $LIB2_NAME

		/sbin/ldconfig
	fi
}

BackTitle="\Z7AiGO $AIGO_VER\Zn - $BNAME v$VER"

MenuTitle="\Zr\Z7 Switch libASICamera Library Version \Zn"

MenuText="
Current libASICamera version is \Z1$LIB1_VER\Zn

Select libASICamera library version:"

MenuHeight=$((10+$INDEX))
MenuWidth=60
MenuItemHeight=$((1+$INDEX))

dialog --no-shadow --visit-items --colors --clear \
--default-item "$DEF_ITEM" \
--backtitle "$BackTitle" \
--title "$MenuTitle" \
--menu "$MenuText" \
$MenuHeight $MenuWidth $MenuItemHeight \
$MENUS \
2>"${INPUT}"

SELECT=$(<"${INPUT}")

if [ x"$SELECT" = x"" ] ; then
	echo "INDEX(fail)="$INDEX
	echo "SELECT(fail)="$SELECT

	echo "Cancel"
	clear
else
	echo "INDEX="$INDEX
	echo "SELECT="$SELECT

	do_switch-libasicamera $SELECT
	clear
fi

[ -f $OUTPUT ] && rm -f $OUTPUT
[ -f $INPUT ] && rm -f $INPUT

