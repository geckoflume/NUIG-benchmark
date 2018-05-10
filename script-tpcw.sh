#!/bin/bash
#Script made for Ubuntu 14.04 LTS amd64
#Credits to José Pereira from University of Minho (https://github.com/jopereira/java-tpcw.git)
#Result content will be in tpcwResult.txt

if [[ $# -ne 1 ]] || [[ "$1" != "install" && "$1" != "run" && "$1" != "plot" ]]; then
	echo Syntax : $0 install or $0 run or $0 plot
	exit 1
fi
case $1 in
	install)
		echo "Installing TCP-W..."
		#Installing required packages
		sudo apt-get update
		sudo apt-get -y -qq install git openjdk-7-jdk ant perl tomcat7 tomcat7-admin python-matplotlib python-scipy
		mkdir -p ~/TPCW
		cd ~/TPCW
		#Downloading and installing Mckoi SQL Database
		wget http://mckoi.com/database/ver/mckoi1.0.6.zip
		unzip mckoi1.0.6.zip
		cd mckoi1.0.6
		sudo cp mkjdbc.jar /usr/share/java/
		#Creating new database, with user=admin and password=admin
		java -jar mckoidb.jar -create "admin" "admin"
		#Launching mckoidb server
		java -jar mckoidb.jar & PID=$!
		cd ~/TPCW
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
		echo "Database setup..."
		#Filling database
		sudo ant gendb
		#Downloading result analysis script
		wget https://gist.githubusercontent.com/jopereira/4086237/raw/9b279cab3c8565b707808e299fe1811f1540d625/showtpc.py
		chmod u+x showtpc.py
		kill -2 $PID
		exit 0
		;;
	run)
		echo "Running TCP-W benchmark... "
		#Launching mckoidb server
		java -jar ~/TPCW/mckoi1.0.6/mckoidb.jar & PID=$!
		cd ~/TPCW/java-tpcw
		#Running Remote Browser Emulator (TPC-W benchmark)
		./rbe.sh
		#Running result analysis script
		./showtpc.py --bench=w $(ls run1_* | tail -1) > tpcwResult.txt
		echo "Result located in tpcwResult.txt"
		exit 0
		;;
	plot)
		echo "Plotting result... "
		#Running result analysis script
		./showtpc.py --bench=w -p $(ls run1_* | tail -1)
		exit 0
esac