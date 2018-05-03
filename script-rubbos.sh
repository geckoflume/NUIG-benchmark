#!/bin/bash
#Script made for Ubuntu 14.04 LTS amd64
#Credits to Michael Mior from University of Waterloo (https://github.com/michaelmior/RUBBoS.git)
#Result content will be in rubbosResult.txt

if [[ $# -ne 1 ]] || [[ "$1" != "install" && "$1" != "run" ]]; then
	echo Syntax : $0 install or $0 run
	exit 1
fi

BASEDIR=$(dirname "$0")
echo "$BASEDIR"

case $1 in
	install)
		echo "Installing RUBBoS..."
		#Installing required packages
		sudo apt-get update
		#MySQL Username:root
		#MySQL Password:1a2b3c
		sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password 1a2b3c'
		sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 1a2b3c'
		sudo apt-get -y -qq install git openjdk-7-jdk sysstat apache2 libapache2-mod-php5 php5-cli mysql-server gnuplot
		export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
		mkdir -p ~/RUBBoS
		cd ~/RUBBoS
		#Downloading RUBBoS
		git clone https://github.com/michaelmior/RUBBoS.git
		#Installing RUBBoS
		cd RUBBoS/PHP
		mv config.example.php config.php
		sudo cp -r ../PHP/ /var/www/html/
		echo "Building client..."
		#Building client
		cd ../Client
		make
		yes | cp -rf $BASEDIR/rubbos.properties ~/RUBBoS/RUBBoS/Client/
		zip rubbos_client.jar rubbos.properties
		echo "Database setup..."
		#Configuring MySQL database
		sudo sed -i 's/\[mysqld\]/[mysqld]\nsecure_file_priv = ""/' /etc/mysql/my.cnf
		sudo /etc/init.d/mysql restart
		#Filling database
		cd ../database
		mysql -u root -p1a2b3c < rubbos.sql
		wget http://jmob.ow2.org/rubbos/smallDB.tgz
		tar -zxf smallDB.tgz
		sudo cp *.data /var/lib/mysql/rubbos/
		replace "/home/cecchet/RUBBoS/database/" "" -- load.sql
		mysql -u root -p1a2b3c -D rubbos < load.sql
		exit 0
		echo "Fixing compute_global_stats.awk..."
		yes | cp -rf $BASEDIR/compute_global_stats.awk ~/RUBBoS/RUBBoS/bench/
		;;
	run)
		echo "Running RUBBoS benchmark... "
		#Running Browser Emulator (RUBBoS benchmark) and data analysis
		cd ~/RUBBoS/RUBBoS
		make emulator
		echo "Result located in rubbosResult.txt"
		#TODO:export data from benchmark analysis (bench/xxxx-xx-xx@xx:xx:xx/stat_client0.html) to rubbosResult.txt
		exit 0
esac