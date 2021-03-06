#!/bin/sh

# Author : M Rahman
# Copyright (c) shadikur.com
# Script follows here:

#All the variables
bold=$(tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2)
now=$(date +%Y-%m-%d)


random=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64 | sed 's/[=\+//]//g')

echo "${bold}${green}Upgrading PHP Version ${normal}\n"
sleep 2

#remove php5
apt remove -y php5 php5-cli php5-fpm php5-pgsql php5-sqlite php5-odbc php5-curl php5-imap php5-gd php5-common

#remove php 7.0
apt remove -y php7.0 php7.0-cli php7.0-fpm php7.0-pgsql php7.0-sqlite3 php7.0-odbc php7.0-curl php7.0-imap php7.0-xml php7.0-gd php7.0-common

#remove php 7.1
apt remove -y php7.1 php7.1-cli php7.1-fpm php7.1-pgsql php7.1-sqlite3 php7.1-odbc php7.1-curl php7.1-imap php7.1-xml php7.1-gd php7.1-common

#remove php 7.2
apt remove -y php7.2 php7.2-cli php7.2-fpm php7.2-pgsql php7.2-sqlite3 php7.2-odbc php7.2-curl php7.2-imap php7.2-xml php7.2-gd php7.2-common

#add a repo for php 7.x
sleep 2
apt-get -y install apt-transport-https lsb-release ca-certificates
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt-get update

#install php
apt-get install -y php7.3 php7.3-cli php7.3-fpm php7.3-pgsql php7.3-sqlite3 php7.3-odbc php7.3-curl php7.3-imap php7.3-xml php7.3-gd php7.3-ldap php7.3-common

#Update PHP Settings
sleep 2
sed 's#post_max_size = .*#post_max_size = 80M#g' -i /etc/php/7.3/fpm/php.ini
sed 's#upload_max_filesize = .*#upload_max_filesize = 80M#g' -i /etc/php/7.3/fpm/php.ini
sed 's#;max_input_vars = .*#max_input_vars = 8000#g' -i /etc/php/7.3/fpm/php.ini

#update the unix socket name
sleep 2
sed -i /etc/nginx/sites-available/fusionpbx -e 's#unix:.*;#unix:/var/run/php/php7.3-fpm.sock;#g'
rm -rf /etc/nginx/sites-enabled/fusionpbx
cp /etc/nginx/sites-available/fusionpbx /etc/nginx/sites-enabled/


#restart nginx
service nginx restart
echo "${bold}${green}PHP version has been upgraded ${normal}\n" 

echo "${bold}${green}Backing up old FusionPBX. ${normal}\n"
sleep 2
rm -rf /var/www/fusionpbx-old
mv /var/www/fusionpbx /var/www/fusionpbx-old
mkdir -p /var/cache/fusionpbx

echo "${bold}${green}Installing dependencies ... ${normal}\n"
sleep 2
apt-get install -y vim git dbus haveged ssl-cert qrencode
apt-get install -y ghostscript libtiff5-dev libtiff-tools at

echo "${bold}${green}Getting latest FusionPBX... ${normal}\n"
sleep 2
chown -R www-data:www-data /var/cache/fusionpbx
cd /var/www && git clone https://github.com/fusionpbx/fusionpbx.git
git clone https://github.com/fusionpbx/fusionpbx-app-edit.git /var/www/fusionpbx/edit
echo "${bold}${green}Changing permission settings...${normal} \n"
sleep 2
chown -R www-data:www-data /var/www/fusionpbx

echo "${bold}${green}Upgrading Switch ...${normal} \n"
rm -rf /etc/apt/sources.list.d/freeswitch.list
apt-get update && apt-get install -y curl memcached haveged
#curl https://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub | apt-key add -
#echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main" > /etc/apt/sources.list.d/freeswitch.list
#echo "deb http://files.freeswitch.org/repo/deb/debian-unstable/ jessie main" >> /etc/apt/sources.list.d/freeswitch.list
apt-get update
apt-get install -y gnupg gnupg2
apt-get install -y wget lsb-release
apt-get install -y ntp gdb
apt-get install -y freeswitch-meta-bare freeswitch-conf-vanilla freeswitch-mod-commands freeswitch-meta-codecs freeswitch-mod-console freeswitch-mod-logfile freeswitch-mod-distributor
apt-get install -y freeswitch-lang-en freeswitch-mod-say-en freeswitch-sounds-en-us-callie
apt-get install -y freeswitch-mod-enum freeswitch-mod-cdr-csv freeswitch-mod-event-socket freeswitch-mod-sofia freeswitch-mod-sofia-dbg freeswitch-mod-loopback
apt-get install -y freeswitch-mod-conference freeswitch-mod-db freeswitch-mod-dptools freeswitch-mod-expr freeswitch-mod-fifo libyuv-dev freeswitch-mod-httapi
apt-get install -y freeswitch-mod-hash freeswitch-mod-esl freeswitch-mod-esf freeswitch-mod-fsv freeswitch-mod-valet-parking freeswitch-mod-dialplan-xml freeswitch-dbg
apt-get install -y freeswitch-mod-sndfile freeswitch-mod-native-file freeswitch-mod-local-stream freeswitch-mod-tone-stream freeswitch-mod-lua freeswitch-meta-mod-say
apt-get install -y freeswitch-mod-xml-cdr freeswitch-mod-verto freeswitch-mod-callcenter freeswitch-mod-rtc freeswitch-mod-png freeswitch-mod-json-cdr freeswitch-mod-shout
apt-get install -y freeswitch-mod-sms freeswitch-mod-sms-dbg freeswitch-mod-cidlookup freeswitch-mod-memcache
apt-get install -y freeswitch-mod-imagick freeswitch-mod-tts-commandline freeswitch-mod-directory freeswitch-mod-flite
apt-get install -y freeswitch-mod-pgsql
apt-get install -y freeswitch-music-default

#make sure that postgresql is started before starting freeswitch
sed -i /lib/systemd/system/freeswitch.service -e s:'local-fs.target:local-fs.target postgresql.service:'

#remove the music package to protect music on hold from package updates
mkdir -p /usr/share/freeswitch/sounds/temp
mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/temp
apt-get remove -y freeswitch-music-default
mkdir -p /usr/share/freeswitch/sounds/music/default
mv /usr/share/freeswitch/sounds/temp/* /usr/share/freeswitch/sounds/music/default
rm -R /usr/share/freeswitch/sounds/temp

echo "${bold}${green}Setting permission for Freeswitch ${normal} \n"
sleep 2
rm -rf /etc/freeswitch.orig
mv /etc/freeswitch /etc/freeswitch.orig
mkdir -p /etc/freeswitch
cp -R /var/www/fusionpbx/resources/templates/conf/* /etc/freeswitch
chown -R www-data:www-data /etc/freeswitch
chown -R www-data:www-data /var/lib/freeswitch
chown -R www-data:www-data /usr/share/freeswitch
chown -R www-data:www-data /var/log/freeswitch
chown -R www-data:www-data /var/run/freeswitch
chown -R www-data:www-data /var/cache/fusionpbx

#update xml_cdr url, user and password
xml_cdr_username=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64 | sed 's/[=\+//]//g')
xml_cdr_password=$(dd if=/dev/urandom bs=1 count=20 2>/dev/null | base64 | sed 's/[=\+//]//g')
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_http_protocol}:http:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{domain_name}:127.0.0.1:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_project_path}::"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_user}:$xml_cdr_username:"
sed -i /etc/freeswitch/autoload_configs/xml_cdr.conf.xml -e s:"{v_pass}:$xml_cdr_password:"

echo "${bold}${green}Switch process complete ${normal}\n\n"

echo "${bold}${green}Restarting Freeswitch ${normal}\n"
sleep 2
/bin/systemctl daemon-reload
/bin/systemctl restart freeswitch
echo "Refreshing Mod Sofia \n"
fs_cli -x 'reload mod_sofia'


echo "${bold}${green}Running advance upgrade process. ${normal}\n"
sleep 2
cd /var/www/fusionpbx
php /var/www/fusionpbx/core/upgrade/upgrade.php

echo "${bold}${green}Voicemail Transcription Script Updating ... ${normal} \n"
sleep 2
cd /usr/share/freeswitch/scripts/app/voicemail/resources/functions
rm -rf record_message.lua
wget https://raw.githubusercontent.com/shadikur/fusionpbx/master/voicemail_transcription/record_message.lua
chown www-data:www-data record_message.lua
service nginx restart
service php7.3-fpm restart

echo "${bold}${green}Upgradation complete. ${normal}\n \n \n"
