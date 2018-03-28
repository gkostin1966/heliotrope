#!/bin/bash

# NOTE: We're running as root so we don't need to sudo.

# Replace original rc.local script else we'll get called on every reboot!!!
cp -f ~ubuntu/aws/rc.local /etc/rc.local

# Create root.log file
ROOT_LOG=~ubuntu/aws/root.log
su ubuntu -c "cat /dev/null > ${ROOT_LOG}"

##############################################################################
#
# Root provisioning ...
#
##############################################################################

apt-get -y autoremove >> ${ROOT_LOG} 2>&1

# GNU g++ and libs for native extensions
apt-get -y install openssh-server >> ${ROOT_LOG} 2>&1
apt-get -y install build-essential >> ${ROOT_LOG} 2>&1
apt-get -y install vim >> ${ROOT_LOG} 2>&1
apt-get -y install wget curl unzip >> ${ROOT_LOG} 2>&1
apt-get -y install libmysqlclient-dev >> ${ROOT_LOG} 2>&1
apt-get -y install libclamav-dev >> ${ROOT_LOG} 2>&1

# Java
apt-get -y install default-jdk >> ${ROOT_LOG} 2>&1

# Hyrax pre-requisites
PACKAGES="imagemagick libreadline-dev libyaml-dev libsqlite3-dev nodejs zlib1g-dev libsqlite3-dev nodejs redis-server"
apt-get -y install $PACKAGES >> ${ROOT_LOG} 2>&1

# Ruby and the development libraries (so we can compile nokogiri, kgio, etc)
apt-get -y install ruby ruby-dev >> ${ROOT_LOG} 2>&1

# https://github.com/ffi/ffi/issues/608
apt-get -y install libffi-dev

apt-get -y autoremove >> ${ROOT_LOG} 2>&1

# Bundler and Rails gems
GEMS="bundler rails"
gem install $GEMS --no-ri --no-rdoc >> ${ROOT_LOG} 2>&1

# MySQL as of 5.7 it's difficult to get installed unattended with a blank root password
# first, use debconf-utils to set up the entry of an actual root password (also root)
# echo 'mysql-server-5.7 mysql-server/root_password password root' | debconf-set-selections
# echo 'mysql-server-5.7 mysql-server/root_password_again password root' | debconf-set-selections

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
# could preface the command with this instead to allow critical output:
# DEBIAN_PRIORITY=critical
DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server >> ${ROOT_LOG} 2>&1

# debconf-set-selections <<< 'mysql-server mysql-server/root_password password your_password'
# debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password your_password'
# apt-get --assume-yes install mysql-server
# sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/root-pass password your_password'
# sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/re-root-pass password your_password'
# sudo apt-get --assume-yes install mysql-community-server
# apt-get --assume-yes install mysql-server
# mysql_secure_installation

apt-get -y autoremove >> ${ROOT_LOG} 2>&1

##############################################################################
#
# Ubuntu setting up ...
#
##############################################################################

# switch user ubuntu
su ubuntu << 'EOF'

# Create ubuntu.log file
UBUNTU_LOG=~ubuntu/aws/ubuntu.log
cat /dev/null > ${UBUNTU_LOG}

# MySQL create non-localhost root user (blank password)
mysql -h127.0.0.1 -P3306 -uroot -proot -e "create user 'root'@'10.0.2.2' identified by ''; grant all privileges on *.* to 'root'@'10.0.2.2' with grant option; flush privileges;"
# set default root user's password to blank
mysql -h127.0.0.1 -P3306 -uroot -proot -e"ALTER USER 'root'@'localhost' IDENTIFIED BY ''"
sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
# service mysql restart >> ${UBUNTU_LOG} 2>&1

echo "---------------------------------------------------"
echo "                 Setup Heliotrope                  "
echo "---------------------------------------------------"
cd ~
bundle install >> ${UBUNTU_LOG} 2>&1
./bin/bundle exec ./bin/setup >> ${UBUNTU_LOG} 2>&1
echo "---------------------------------------------------"
echo "                 Configure Heliotrope              "
echo "---------------------------------------------------"
# ./bin/bundle exec ./bin/rails admin
# vi ./config/role_map.yml
echo "---------------------------------------------------"
echo "                 Startup Dev Servers               "
echo "---------------------------------------------------"
# fcrepo_wrapper --config .wrap_conf/fcrepo_dev &
# solr_wrapper --config .wrap_conf/solr_dev &
echo "---------------------------------------------------"
echo "                 Initialize Heliotrope             "
echo "---------------------------------------------------"
# ./bin/bundle exec ./bin/rails hyrax:default_admin_set:create
echo "---------------------------------------------------"
echo "                 Startup Test Servers              "
echo "---------------------------------------------------"
# fcrepo_wrapper --config .wrap_conf/fcrepo_test &
# solr_wrapper --config .wrap_conf/solr_test &
echo "---------------------------------------------------"
echo "                 Run Test Suite                    "
echo "---------------------------------------------------"
# ./bin/bundle exec ./bin/rails rubocop
# ./bin/bundle exec ./bin/rails ruumba
# ./bin/bundle exec ./bin/rails lib_spec
# ./bin/bundle exec rspec

EOF
