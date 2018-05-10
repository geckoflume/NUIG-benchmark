#!/bin/bash
#Script made for Ubuntu 14.04 LTS amd64
#Credits to José Pereira from University of Minho (https://github.com/jopereira/java-tpcw.git)
#Result content will be in tpcwResult.txt

if [[ $# -ne 1 ]] || [[ "$1" != "install" && "$1" != "run" && "$1" != "plot" ]]; then
	echo "Syntax : $0 install or $0 run or $0 plot"
	exit 1
fi

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

BASEDIR=$(pwd)

case $1 in
	install)
		echo -e "\033[0;32mInstalling TCP-W...\033[0m"
		#Installing required packages
		sudo apt-get -q update
		sudo apt-get -y -q install git openjdk-7-jdk ant perl tomcat7 tomcat7-admin python-matplotlib python-scipy
		mkdir -p $BASEDIR/TPCW
		cd $BASEDIR/TPCW
		#Downloading and installing Mckoi SQL Database
		wget http://mckoi.com/database/ver/mckoi1.0.6.zip
		unzip mckoi1.0.6.zip
		cd mckoi1.0.6
		sudo cp mkjdbc.jar /usr/share/java/
		#Creating new database, with user=admin and password=admin
		java -jar mckoidb.jar -create "admin" "admin"
		#Launching mckoidb server
		java -jar mckoidb.jar & PID=$!
		cd $BASEDIR/TPCW
		#Downloading java-tpcw
		git clone https://github.com/jopereira/java-tpcw.git
		cd java-tpcw
		git checkout uminho
		#Changing ant settings for java-tpcw
		echo "cpServ=/usr/share/java/servlet-api-3.0.jar" >> main.properties
		echo "webappDir=/var/lib/tomcat7/webapps/" >> main.properties
		#Installing java-tpcw
		sudo ant inst
		sleep 10
		sudo ant genimg
		echo -e "\033[0;32mDatabase setup...\033[0m"
		#Filling database
		sudo ant gendb
		#Downloading result analysis script
		wget https://gist.githubusercontent.com/jopereira/4086237/raw/9b279cab3c8565b707808e299fe1811f1540d625/showtpc.py
		chmod u+x showtpc.py
		kill -2 $PID
		echo -e "\033[0;32mInstallation completed successfully!\033[0m"
		exit 0
		;;
	run)
		if [ ! -d "$BASEDIR/TPCW/java-tpcw/" ]; then
			echo -e "\033[0;31mTCP-W benchmark not installed, please run $0 install first...\033[0m"
			exit 1
		fi
		echo -e "\033[0;32mRunning TCP-W benchmark...\033[0m"
		#Launching mckoidb server
		java -jar $BASEDIR/TPCW/mckoi1.0.6/mckoidb.jar & PID=$!
		cd $BASEDIR/TPCW/java-tpcw
		#Running Remote Browser Emulator (TPC-W benchmark)
		./rbe.sh
		#Running result analysis script
		./showtpc.py --bench=w $(ls run1_* | tail -1) > tpcwResult.txt
		echo -e "\033[0;32mResult located in tpcwResult.txt\033[0m"
		kill -2 $PID
		exit 0
		;;
	plot)
		latestrun=$(ls run1_* | tail -1)
		if [ -z "$latestrun" ]; then
			echo -e "\033[0;31mTCP-W benchmark was never executed, please run $0 run first...\033[0m"
			exit 1
		fi
		echo -e "\033[0;32mPlotting result...\033[0m"
		#Running result analysis script
		./showtpc.py --bench=w -p $latestrun
		exit 0
esac