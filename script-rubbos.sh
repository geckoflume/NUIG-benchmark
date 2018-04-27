#!/bin/bash
#Script made for Ubuntu 14.04 LTS amd64
#Credits to Michael Mior from University of Waterloo (https://github.com/michaelmior/RUBBoS.git)
#Result content will be in rubbosResult.txt

if [[ $# -ne 1 ]] || [[ "$1" != "install" && "$1" != "run" ]]; then
	echo Syntax : $0 install or $0 run
	exit 1
fi
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
		cat > rubbos.properties << EOF
# HTTP server information
httpd_hostname = localhost
httpd_port = 80

# Precise which version to use. Only valid option is PHP.
httpd_use_version = PHP

# PHP information
php_html_path = /PHP
php_script_path = /PHP

#Database information
database_server = localhost

# Workload: precise which transition table to use
workload_remote_client_nodes =
workload_remote_client_command = /usr/lib/jvm/java-7-openjdk-amd64/java -classpath RUBBoS edu.rice.rubbos.client.ClientEmulator
workload_number_of_clients_per_node = 100

workload_user_transition_table = /home/stack/RUBBoS/workload/user_default_transitions.txt
workload_author_transition_table = /home/stack/RUBBoS/workload/author_default_transitions.txt
workload_number_of_columns = 24
workload_number_of_rows = 26
workload_maximum_number_of_transitions = 1000
workload_use_tpcw_think_time = yes
workload_number_of_stories_per_page = 20
workload_up_ramp_time_in_ms = 150000
workload_up_ramp_slowdown_factor = 2
workload_session_run_time_in_ms = 900000
workload_down_ramp_time_in_ms = 150000
workload_down_ramp_slowdown_factor = 3
workload_percentage_of_author = 10

# home policy
database_number_of_authors = 50
database_number_of_users = 500000

# Stories policy
database_story_dictionnary = /home/stack/RUBBoS/database/dictionary
database_story_maximum_length = 1024
database_oldest_story_year = 1998
database_oldest_story_month = 1

# Comments policy
database_comment_max_length = 1024

# Monitoring Information
monitoring_debug_level = 0
monitoring_program = /usr/bin/sar
monitoring_options = -n DEV -n SOCK -rubcw
monitoring_sampling_in_seconds = 1
monitoring_rsh = /usr/bin/rsh
monitoring_scp = /usr/bin/scp
monitoring_gnuplot_terminal = gif
EOF
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