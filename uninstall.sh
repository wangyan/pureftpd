#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ $(id -u) != "0" ]; then
	printf "Error: You must be root to run this script!"
	exit 1
fi

clear
echo "#############################################################"
echo "# Pureftpd Auto Uninstall Shell Scritp"
echo "# Env: Debian/Ubuntu/Redhat/CentOS"
echo "# See: https://wangyan.org/blog/pureftpd-install-script.html"
echo "# Version: 0.1 build 120805"
echo "#"
echo "# Copyright (c) 2012, WangYan <WangYan@188.com>"
echo "# All rights reserved."
echo "# Distributed under the GNU General Public License, version 3.0."
echo "#"
echo "#############################################################"
echo ""

echo "Are you sure uninstall Pureftpd? (y/n)"
read -p "(Default: n):" UNINSTALL
if [ -z $UNINSTALL ]; then
	UNINSTALL="n"
fi
if [ "$UNINSTALL" != "y" ]; then
	clear
	echo "==========================="
	echo "You canceled the uninstall!"
	echo "==========================="
	exit
else
	echo "---------------------------"
	echo "Yes, I decided to uninstall!"
	echo "---------------------------"
	echo ""
fi

echo "Please enter the root password of MySQL:"
read -p "(Default password: 123456):" MYSQL_ROOT_PWD
if [ -z $MYSQL_ROOT_PWD ]; then
	MYSQL_ROOT_PWD="123456"
fi
echo "---------------------------"
echo "MySQL root password = $MYSQL_ROOT_PWD"
echo "---------------------------"
echo ""

get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
echo "Press any key to start uninstall..."
echo "Or Ctrl+C cancel and exit ?"
char=`get_char`
echo ""

if [ "$UNINSTALL" = 'y' ]; then

	echo "---------- Pureftpd ----------"

	if cat /proc/version | grep -Eqi '(redhat|centos)';then
		chkconfig pureftpd off
	elif cat /proc/version | grep -Eqi '(debian|ubuntu)';then
		update-rc.d -f pureftpd remove
	fi

	rm -rf /usr/local/pureftpd
	rm -rf /var/www/ftp
	rm -rf /etc/init.d/pureftpd

	echo "---------- MySQL ----------"

	mysql -uroot -p$MYSQL_ROOT_PWD -e"drop database pureftpd;Drop USER pureftpd@localhost;"

	clear
	echo "==========================="
	echo "Uninstall completed!"
	echo "==========================="
fi
