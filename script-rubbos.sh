#!/bin/bash
#Script made for Ubuntu 14.04 LTS amd64
#Credits to Michael Mior from University of Waterloo (https://github.com/michaelmior/RUBBoS.git)
#Result content will be in rubbosResult.txt

if [[ $# -ne 1 ]] || [[ "$1" != "install" && "$1" != "run" ]]; then
	echo "Syntax : $0 install or $0 run"
	exit 1
fi

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

BASEDIR=$(pwd)

case $1 in
	install)
		echo -e "\033[0;32mInstalling RUBBoS...\033[0m"
		#Installing required packages
		sudo apt-get update
		#MySQL Username:root
		#MySQL Password:1a2b3c
		sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password 1a2b3c'
		sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password 1a2b3c'
		sudo apt-get -y -qq install git openjdk-7-jdk sysstat apache2 libapache2-mod-php5 php5-cli mysql-server gnuplot
		export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
		#Downloading RUBBoS
		git clone https://github.com/michaelmior/RUBBoS.git
		#Installing RUBBoS
		cd RUBBoS/PHP
		mv config.example.php config.php
		sudo cp -r ../PHP/ /var/www/html/
		echo -e "\033[0;32mBuilding client...\033[0m"
		#Building client
		cd ../Client
		make
		yes | cp -rf $BASEDIR/files/rubbos.properties $BASEDIR/RUBBoS/Client/
		replace "BASEDIR" "$BASEDIR" -- rubbos.properties
		zip rubbos_client.jar rubbos.properties
		echo -e "\033[0;32mDatabase setup...\033[0m"
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
		echo -e "\033[0;32mFixing compute_global_stats.awk...\033[0m"
		yes | cp -rf $BASEDIR/files/compute_global_stats.awk $BASEDIR/RUBBoS/bench/
		;;
	run)
		if [ ! -d "$BASEDIR/RUBBoS/" ]; then
			echo -e "\033[0;31mRUBBoS benchmark not installed, please run $0 install first...\033[0m"
			exit 1
		fi
		echo -e "\033[0;32mRunning RUBBoS benchmark...\033[0m"
		#Running Browser Emulator (RUBBoS benchmark) and data analysis
		cd $BASEDIR/RUBBoS
		make emulator
		echo -e "\033[0;32mResult located in rubbosResult.txt\033[0m"
		#TODO:export data from benchmark analysis (bench/xxxx-xx-xx@xx:xx:xx/stat_client0.html) to rubbosResult.txt
		exit 0
esac