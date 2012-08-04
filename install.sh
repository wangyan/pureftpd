#! /bin/bash
#====================================================================
# install.sh
#
# Pureftpd Auto Install Script
#
# Copyright (c) 2012, WangYan <WangYan@188.com>
# All rights reserved.
# Distributed under the GNU General Public License, version 3.0.
#
# Ver: 0.1 build 20120804"
# Intro: https://wangyan.org/blog/pureftpd-install-script.html
#
#====================================================================

if [ $(id -u) != "0" ]; then
	printf "Error: You must be root to run this script!"
	exit 1
fi

mkfifo fifo
cat fifo | tee log.txt &
exec 1>fifo
exec 2>&1

/bin/bash ./pureftpd.sh

if cat /proc/version | grep -Eqi '(redhat|centos)';then
	chkconfig pureftpd on
elif cat /proc/version | grep -Eqi '(debian|ubuntu)';then
	update-rc.d pure-ftpd defaults
else
	exit 0
fi

sed -i '/password/d' log.txt
rm -rf fifo
