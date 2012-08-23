#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

clear
CUR_DIR=$(pwd)

if [ $(id -u) != "0" ]; then
	printf "Error: You must be root to run this script!"
	exit 1
fi

echo "#############################################################"
echo "# PureFTPD Auto Install Script"
echo "# Env: Red Hat/CentOS"
echo "# See: https://wangyan.org/blog/pureftpd-install-script.html"
echo "# Version: 0.1 build 120823"
echo "#"
echo "# Copyright (c) 2012, WangYan <WangYan@188.com>"
echo "# All rights reserved."
echo "# Distributed under the GNU General Public License, version 3.0."
echo "#"
echo "#############################################################"
echo ""

echo "Please enter the IP address of ftp server:"
TEMP_IP=`ifconfig |grep 'inet' | grep -Evi '(inet6|127.0.0.1)' | awk '{print $2}' | cut -d: -f2 | tail -1`
read -p "(e.g: $TEMP_IP):" IP_ADDRESS
if [ -z $IP_ADDRESS ]; then
	IP_ADDRESS="$TEMP_IP"
fi
echo "---------------------------"
echo "IP address = $IP_ADDRESS"
echo "---------------------------"
echo ""

echo "Please enter the webroot path of website:"
read -p "(Default webroot dir: /var/www):" WEBROOT
if [ -z $WEBROOT ]; then
	WEBROOT="/var/www"
fi
echo "---------------------------"
echo "Webroot dir=$WEBROOT"
echo "---------------------------"
echo ""

echo "Please enter the root password of MySQL:"
read -p "(Default password: 123456):" MYSQL_ROOT_PWD
if [ -z $MYSQL_ROOT_PWD ]; then
	MYSQL_ROOT_PWD="123456"
fi
echo "---------------------------"
echo "MySQL root password = $MYSQL_ROOT_PWD"
echo "---------------------------"
echo ""

echo "Please enter the ftpuser password of MySQL:"
read -p "(Default password: 123456):" FTP_USER_PWD
if [ -z "$FTP_USER_PWD" ]; then
	FTP_USER_PWD="123456"
fi
echo "---------------------------"
echo "FTP_USER_PWD = $FTP_USER_PWD"
echo "---------------------------"
echo ""

echo "Please enter the admin password of PureFTPD:"
read -p "(Default password: 123456):" FTP_ADMIN_PWD
if [ -z "$FTP_ADMIN_PWD" ]; then
	FTP_ADMIN_PWD="123456"
fi
echo "---------------------------"
echo "FTP_ADMIN_PWD = $FTP_ADMIN_PWD"
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
echo "Press any key to start install..."
echo "Or Ctrl+C cancel and exit ?"
echo ""
char=`get_char`

echo "================Pureftpd Install==============="

echo "/usr/local/mysql/lib/" >> /etc/ld.so.conf
ldconfig

if [ ! -s pure-ftpd-*.tar.gz ]; then
#	wget -c http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz
	wget -c http://wangyan.org/download/lanmp/pure-ftpd-latest.tar.gz
fi
tar -zxf pure-ftpd-*.tar.gz
cd pure-ftpd-*/

./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 \
--with-mysql=/usr/local/mysql \
--with-altlog \
--with-cookie \
--with-diraliases \
--with-ftpwho \
--with-language=simplified-chinese \
--with-paranoidmsg \
--with-peruserlimits \
--with-quotas \
--with-ratios \
--with-sysquotas \
--with-throttling \
--with-virtualchroot \
--with-virtualhosts \
--with-welcomemsg
make && make install

cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin/pure-config.pl
chmod 755 /usr/local/pureftpd/sbin/pure-config.pl
mkdir /usr/local/pureftpd/etc/
cp $CUR_DIR/conf/pureftpd.conf /usr/local/pureftpd/etc/pureftpd.conf
cp $CUR_DIR/conf/pureftpd-mysql.conf /usr/local/pureftpd/etc/pureftpd-mysql.conf
sed -i 's/FTP_USER_PWD/'$FTP_USER_PWD'/g' /usr/local/pureftpd/etc/pureftpd-mysql.conf

cp $CUR_DIR/conf/pureftpd.mysql /tmp/pureftpd.mysql
sed -i 's/FTP_USER_PWD/'$FTP_USER_PWD'/g' /tmp/pureftpd.mysql
sed -i 's/FTP_ADMIN_PWD/'$FTP_ADMIN_PWD'/g' /tmp/pureftpd.mysql
/usr/local/mysql/bin/mysql -u root -p$MYSQL_ROOT_PWD < /tmp/pureftpd.mysql

echo "================User manager for PureFTPd==============="

cd $CUR_DIR

if [ ! -s ftp_*.tar.gz ]; then
#	wget -c http://machiel.generaal.net/files/pureftpd/ftp_v2.1.tar.gz
	wget -c http://wangyan.org/download/lanmp/ftp_latest.tar.gz
fi

tar -zxf ftp_*.tar.gz
mv $CUR_DIR/ftp $WEBROOT
chown -R root:root $WEBROOT/ftp

cp $CUR_DIR/conf/config.php $WEBROOT/ftp/config.php
sed -i 's/FTP_USER_PWD/'$FTP_USER_PWD'/g' $WEBROOT/ftp/config.php
sed -i 's/IP_ADDRESS/'$IP_ADDRESS'/g' $WEBROOT/ftp/config.php

if [ -s ftp_*.tar.gz ]; then
	sed -i 's/php_admin_value/#php_admin_value/g' /usr/local/apache/conf/extra/httpd-vhosts.conf
	/etc/init.d/httpd restart
fi

UNUM=`awk -F: '$1=="www"{print $3}' /etc/passwd`
GNUM=`awk -F: '$1=="www"{print $4}' /etc/passwd`
sed -i 's/65534/'$UNUM'/' $WEBROOT/ftp/config.php
sed -i 's/65534/'$GNUM'/' $WEBROOT/ftp/config.php

cp $CUR_DIR/conf/init.d.pureftpd /etc/init.d/pureftpd
chmod 755 /etc/init.d/pureftpd
chkconfig pureftpd on

/etc/init.d/pureftpd start

clear
echo ""
echo "===================== Install completed ====================="
echo ""
echo "Install PureFTPD completed!"
echo "For more information please visit https://wangyan.org/blog/pureftpd-install-script.html"
echo ""
echo "Ftp web dir: $WEBROOT/ftp"
echo "Ftpuser password of mysql: $FTP_USER_PWD"
echo "Admin password of pureftpd: $FTP_ADMIN_PWD"
echo "Pureftpd log dir: /var/log/pureftpd.log"
echo "Pureftpd config dir: /usr/local/pureftpd/conf/pureftpd.conf"
echo ""
echo "Usage: /etc/init.d/pureftpd {start|stop|restart|status}"
echo ""
echo "============================================================="
echo ""
