#!/bin/bash

ACTION=$1
PKGNAME=$2

REPODIR=/STORAGE/repository
PRJNAME=AiGO
TESTDIR=
DISTRIBUTION=ubuntu
CODENAME=xenial
DISTSDIR=$REPODIR/$PRJNAME/$TESTDIR/$DISTRIBUTION/repos/dists
GPGKEYID=50842E4A

#reprepro -b . -C main includedeb xenial /home/hcc/workspace/AiGO/aigo-tools_0.0.91-1_armhf.deb
#reprepro -b . remove xenial libasicamera

usage() {
	BNAME=`basename $0`
	echo "Usage: $BNAME [add | remove] package_path_name_version"
	echo "e.g.   $BNAME add /home/hcc/workspace/AiGO/aigo-tools_0.0.91-1_armhf.deb"
	echo "       $BNAME remove aigo-tools"
}

gpgsign() {

	cd $DISTSDIR/$CODENAME ; apt-ftparchive packages . | gzip -9c > Packages.gz
	cd $DISTSDIR/$CODENAME ; apt-ftparchive release ./ > Release
	cd $DISTSDIR/$CODENAME ; gpg -abs --default-key $GPGKEYID --personal-digest-preferences SHA256 -o Release.gpg Release
	cd $DISTSDIR/$CODENAME ; gpg --clearsign --default-key $GPGKEYID --personal-digest-preferences SHA256 -o InRelease Release
}

if [ x"$ACTION" == x"add" ]; then
	if [ x"$PKGNAME" == x"" ]; then
		usage
	else
#		reprepro --ignore=forbiddenchar --keepunusednewfiles -b $REPODIR/$PRJNAME/$TESTDIR/$DISTRIBUTION includedeb $CODENAME $PKGNAME 2>&1
		reprepro --ignore=forbiddenchar -b $REPODIR/$PRJNAME/$TESTDIR/$DISTRIBUTION includedeb $CODENAME $PKGNAME 2>&1

		gpgsign
	fi
elif [ x"$ACTION" == x"remove" ]; then
	if [ x"$PKGNAME" == x"" ]; then
		usage
	else
		reprepro --ignore=forbiddenchar -b $REPODIR/$PRJNAME/$TESTDIR/$DISTRIBUTION remove $CODENAME $PKGNAME 2>&1

		gpgsign
	fi
else
	usage
fi

