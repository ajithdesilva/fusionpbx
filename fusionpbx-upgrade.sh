#!/bin/sh

# Author : M Rahman
# Copyright (c) shadikur.com
# Script follows here:

echo "Upgrading PHP Version \n"

#remove php5
apt remove -y php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-gd

#remove php 7.0
apt remove -y php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-xml php7.0-gd

#remove php 7.1
apt remove -y php7.1 php7.1-cli php7.1-fpm php7.1-pgsql php7.1-sqlite3 php7.1-odbc php7.1-curl php7.1-imap php7.1-xml php7.1-gd

#remove php 7.2
apt remove -y php7.2 php7.2-cli php7.2-fpm php7.2-pgsql php7.2-sqlite3 php7.2-odbc php7.2-curl php7.2-imap php7.2-xml php7.2-gd

#add a repo for php 7.x
apt-get -y install apt-transport-https lsb-release ca-certificates
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt-get update

#install php
apt-get install -y php7.3 php7.3-cli php7.3-fpm php7.3-pgsql php7.3-sqlite3 php7.3-odbc php7.3-curl php7.3-imap php7.3-xml php7.3-gd php7.3-ldap

#update the unix socket name
sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.3-fpm.sock;#g'

#restart nginx
service nginx restart
echo "PHP version has been upgraded \n" 

echo "Backing up old FusionPBX. \n"
mv /var/www/fusionpbx /var/www/fusionpbx-4.4
echo "Getting latest FusionPBX. \n"
cd /var/www && git clone https://github.com/fusionpbx/fusionpbx.git
echo "Changing permission settings. \n"
chown -R www-data:www-data /var/www/fusionpbx
echo "Running advance upgrade process. \n"
cd /var/www/fusionpbx
php /var/www/fusionpbx/core/upgrade/upgrade.php
echo "Upgradation complete. \n \n \n"
echo "Your current branch is "
git branch

