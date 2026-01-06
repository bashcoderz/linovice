#!/bin/bash

echo -e "



	 /|	    _    _ _     /|    _ _ _ _   _ _      /|   _    _ _ _ _ _  _ _ _ _ _
	/ |        |_/  |   \   | |   /	_ _ _ \  \  \    / |  |_/  /  _ _ _ /  | _ _ _ /
	| |         /|  | |\ \  | |  | /     \ |  \  \   | |   /|  | |         | |_ _ _
	| |        | |  | | \ \ | |  | |     | |   \  \  / |  | |  | |         |  _ _ _|
	| |_ _ _   | |  | |  \ \| |  | \_ _ _/ |    \  \/ /   | |  | \_ _ _    | |_ _ _
	|_ _ _ _\  |_|  |/    \_ _|   \_ _ _ _/      \_ _/    |_|   \_ _ _ _\  |_ _ _ _\ \


									 	version 1.3				"

echo -e "\n\n \e[1;32mLinovice\e[0m is a project aimed at creating a command-line–based tool that\n makes Linux less intimidating for new users while preserving the classic terminal vibe\n"

master(){
while true; do
    echo -e "\n\n Choose what you want to do:\n-----------------------------------------\n| 1.Install package			|\n| 2.Update system			|\n| 3.Disk usage				|\n| 4.Auto-configure network file 	|\n| 5.Search files and folders		|\n| 6.Find My Ip				|\n| 7.Process Manager			|\n| 8.System cleanup			|\n| 9.file differentiator			|\n| e.Press 'e' then Enter to exit	|\n-----------------------------------------"
    echo -e ""
    read -p "Enter your choice: " option

	case $option in
		1)Installpackage
		;;
		2)update
		;;
		3)diskusage
		sleep 1
		;;
		4)detect_network_system
		echo -e "\nPerforming network detection:"
		sleep 1
		;;
		5)search
		;;
		6)myip
		;;
		7)processmanager
		;;
		8)cleanup
		;;
		9)filediff
		;;
		e)echo -e "Closing ..."
			sleep 1
			exit
		;;
		*)
			errorhandler
			echo -e "\nOption not found! "
			sleep 1
		;;
	esac

done
}

Installpackage(){
	echo -e ""
	read -p "Enter the linux package name you want to install: " package
	echo -e "\nInstalling $package ..."
	sleep 2
	sudo apt install $package -y
	sudo apt-get update --fix-missing
}

diskusage(){
echo -e "\nChecking disk usage..."
sleep 2
df 
}

detect_network_system() {
	declare interface
	echo -e "\nScanning Linux network configuration system..."
	sleep 1

	if grep -qi "alpine" /etc/os-release 2>/dev/null; then
		echo "  Network System: Alpine Networking"
		#echo "  Config: /etc/network/interfaces"
		echo -e "Detecting network system..."
		sleep 2
		configfile=$(find /etc/network -type f \( -name interfaces -o -path "/etc/network/interfaces.d/*" \) 2>/dev/null)
		echo -e $configfile

<<"end"
	elif systemctl is-active NetworkManager >/dev/null 2>&1; then
		echo -e "Detecting network system..."
		sleep 2
		echo "  Network System: NetworkManager"
		echo "  Config:"
		#echo " - /etc/NetworkManager/NetworkManager.conf"
		#echo " - /etc/NetworkManager/system-connections/*"
		configfile=$(find /etc/ -type f \( -name /etc/NetworkManager/NetworkManager.conf -o -path "/etc/NetworkManager/system-connections/*" \) 2>/dev/null)
		echo -e $configfile
end

	elif systemctl is-active systemd-networkd >/dev/null 2>&1; then
		echo -e "Detecting network system..."
                sleep 2
		echo "  Network System: systemd-networkd"
		echo "  Config:"
		#echo " - /etc/systemd/network/*.network"
		#echo " - /etc/systemd/network/*.netdev"
		#echo " - /etc/systemd/network/*.link"
		configfile=$(find /etc /etc/network /etc/sysconfig/network /etc/systemd/network \
			-maxdepth 3 -type f \
    			\( -o -name "*.network" \
       			-o -name "*.netdev" \
       			-o -name "*.link" \
    			\) 2>/dev/null)
		echo -e $configfile
	elif [ -d /etc/netplan ]; then
		echo -e "Detecting network system..."
                sleep 2
		echo -e "\nYour system is using Netplan"
		sleep 2
		echo " Network System: Netplan (Ubuntu)"
		#echo "  Config: /etc/netplan/*.yaml"
		#configfile=$(find -o -name "/etc/netplan/ " -type f 2>/dev/null)
		#echo -e $configfile
		configfile=$(find /etc/netplan -type f -name "*.yaml" 2>/dev/null)
		echo "$configfile"

	elif [ -f /etc/network/interfaces ]; then
		echo -e "Detecting network system..."
                sleep 2
		echo -e "\nYour system is using ifupdown (/etc/network/interfaces)"
		sleep 2
		echo "  Network System: ifupdown (Debian/Ubuntu Classic)"
		echo "  Config:"
		#echo " - /etc/network/interfaces"
		#echo " - /etc/network/interfaces.d/*"
		configfile=$(find /etc/network -type f \( -name interfaces -o -path "/etc/network/interfaces.d/*" \) 2>/dev/null)
		echo -e $configfile
	elif systemctl is-active wicked >/dev/null 2>&1; then
		echo -e "Detecting network system..."
                sleep 2
		echo -e "\nYour system is using wicked "
		sleep 2
		echo "  Network System: wicked (openSUSE)"
		#echo "  Config: /etc/sysconfig/network/ifcfg-*"
		configfile=$(find "/etc/sysconfig/network/ifcfg-*" -type f 2>/dev/null)
		echo -e $configfile
	else
		echo "  Unable to identify a known network management system."
		echo "Try checking manually:"
		echo " - systemctl list-unit-files | grep -i network"
		echo " - ls /etc | grep -i network"
	fi

	#Detect DHCP clients
	if command -v dhclient >/dev/null 2>&1; then
		echo -e "\nDHCP Client detected: dhclient"
	elif command -v dhcpcd >/dev/null 2>&1; then
		echo -e "\nDHCP Client detected: dhcpcd"
	else
		errorhandler
		echo -e "\nNo standard DHCP client detected"
	fi
	echo -e "\nLoading Loopback and DHCP configurations..."
	sleep 2
	networkconf $configfile $interface

}

networkconf(){
	declare configfile
	configfile=$1
	interface=$2
sudo tee $configfile >/dev/null <<EOF
auto lo
iface lo inet loopback

auto $interface
iface $interface inet dhcp
EOF

<<"end"
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
end

echo -e "\nConfigured loopback + DHCP on $interface"

}

update(){
	echo -e "Detecting distro name..."
    	sleep 2
	distro=$(awk -F= '/^ID=/ {gsub(/"/,""); print $2}' /etc/os-release)
     	echo "Detected: $distro"
    	sleep 1

    	if [ "$distro" = "debian" ] || [ "$distro" = "ubuntu" ]; then
        	echo -e "\nInstalling package updates...\n"
        	sleep 1
        	sudo apt update && sudo apt upgrade -y
    	elif [ "$distro" = "fedora" ] || [ "$distro" = "rhel" ] || [ "$distro" = "centos" ]; then
        	echo -e "\nInstalling package updates...\n"
        	sleep 1
        	sudo dnf upgrade --refresh -y
    	elif [ "$distro" = "arch" ] || [ "$distro" = "manjaro" ]; then
        	echo -e "\nInstalling package updates...\n"
        	sleep 1
        	sudo pacman -Syu
    	elif [ "$distro" = "opensuse" ] || [ "$distro" = "opensuse-leap" ]; then
        	echo -e "\nInstalling package updates...\n"
        	sleep 1
        	sudo zypper refresh && sudo zypper update -y
    	elif [ "$distro" = "alpine" ]; then
        	echo -e "\nInstalling package updates...\n"
        	sleep 1
        	sudo apk update && sudo apk upgrade
    	elif [ "$distro" = "solus" ]; then
        	echo -e "\nInstalling package updates...\n"
        	sleep 1
        	sudo eopkg upgrade
    	else
		errorhandler
        	echo -e "\nUnsupported distro: $distro"
    	fi
}

search(){
echo -e ""
read -p "Enter Filename or Foldername to search: " filename

if [ -z "$filename" ]; then
    echo "Error: No filename entered!"
    exit 1
fi

echo
echo "Searching for: $filename"
echo "Searching....."
echo

find / -name "$filename" -o -name "$filename.*" 2>/dev/null

echo
echo -e "Search completed!"
}

myip(){
	echo -e "\nYour network infomation:\n------------------------"
	sleep 3
	#interface=$(ip -o link show |grep "BROADCAST"|awk -F': ' '{print $2}')
	interface=$(ip -o route get 1.1.1.1 | awk '{print $5}')
	ip=$(ip -o route get 1.1.1.1 | awk '/via/ {print $3}')
	macadd=$(ifconfig | grep "ether" |awk '{print $2}')
	gateway=$(ip -o route get 1.1.1.1 | awk '/via/ {print $3}')
	echo "The device network interface is: "$interface
	echo "The device ip address is: "$ip
	echo "The device MAC address is: "$macadd
	echo "The device default gateway is: "$gateway 
	sleep 3
}

processmanager(){
echo -e "\nChecking Process with high CPU and Memory usage...\n"
sleep 2

cpu_usage=$(ps -eo %cpu --sort=-%cpu | head -n 2 | tail -1)
memory_usage=$(ps -eo %mem --sort=-%mem | head -n 2 | tail -1)
declare process

if (( $(echo "$cpu_usage > $memory_usage" | bc -l) )); then
    	echo "High CPU usage: $cpu_usage% "
	echo -e "$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 2| awk '{print $1}')"
	echo -e "\nProcess:\n$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head -n 2| awk '{print $3}')"
	process=$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head -n 2| awk '{print $1}')
	echo -e -n "\nDo you want to kill process $process ? \nEnter 'y' for YES or 'n' for NO: "
	read -r option
	if [ "$option" = "y" ] || [ "$option" = "Y" ]; then
		kill -9 $process
	elif [ "$option" = "n" ] || [ "$option" = "N" ]; then
		sleep 1
		master
	else
		errorhandler
	fi
elif (( $(echo "$memory_usage > $cpu_usage" | bc -l) )); then
    	echo "High Memory(RAM) usage: $memory_usage%"
	echo -e "$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head -n 2| awk '{print $1}')"
	echo -e "\nProcess:\n$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head -n 2| awk '{print $3}')"
	process=$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%mem | head -n 2| awk '{print $1}'| grep -iv "PID")
  	echo -e -n "\nDo you want to kill process $process ? \nEnter 'y' for YES or 'n' for NO: "
        read -r option
        if [ "$option" = "y" ] || [ "$option" = "Y" ]; then
                kill -9 $process
	elif [ "$option" = "n" ] || [ "$option" = "N" ]; then
		sleep 1
                master
	else
		errorhandler
        fi

elif (( $(echo "$cpu_usage == $memory_usage" | bc -l) )); then
    	echo "Equal CPU and Memory usage: $cpu_usage%"
	echo -e "$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 2| awk '{print $1}')"
	echo -e "\nProcess:\n$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 2| awk '{print $3}')"
	process=$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 2| awk '{print $1}'|grep -iv "PID")
   	echo -e -n "\nDo you want to kill process $process ? \n Enter 'y' for YES or 'n' for NO: "
        read -r option
        if [ "$option" = "y" ] || [ "$option" = "Y" ]; then
                kill -9 $process
        elif [ "$option" = "n" ] || [ "$option" = "N" ]; then
		sleep 1
                master
	else
		errorhandler
        fi

else
    	errorhandler
fi

}

filediff(){
echo -e -n "\nEnter first file path/name: "
IFS= read -r file1

echo -e -n "\nEnter second file path/name: "
IFS= read -r file2

file1=$(eval echo "$file1")
file2=$(eval echo "$file2")

echo -e "\nChanges made from $file1 into file $file2:\n"
sleep 2
diff -u --color=always "$file1" "$file2" | nl -ba
err=$(diff -u --color=always "$file1" "$file2" 2>&1 >/dev/null)

if echo "$err" | grep -q "No such file or directory"; then
    errorhandler
    master
fi

echo -e "\n-> Lines removed are in red, lines added are in green\n"
echo -e -n "\nDo you want to see side by side difference? [ choose 'y' for yes or 'n' for No ]: "
read -r option

if [ "$option" = "y" ] || [ "$option" = "Y" ]; then
        echo -e "\nSide-by-side difference of $file1 Vs $file2:" 
        echo -e "--------------------------------------------------"
        sleep 1
        sdiff "$file1" "$file2"
        echo -e "\n"
elif [ "$option" = "n" ] || [ "$option" = "N" ];then
        echo -e "\nTerminating..\n"
        sleep 2
else
        echo -e "\ninvalid option! "
	filediff
fi

}

errorhandler(){
	echo -e "\nError occurred! :( "
	sleep 2
}


cleanup(){
echo -e "\n Choose 1 to Show files older than 7 days\n \
Choose 2 to Show folders older than 7 days\n \
Choose 3 to Show files and folders older than 7 days\n \
Choose 4 to Remove files older than 7 days\n \
Choose 5 to Remove folders older than 7 days\n \
Choose 6 to Remove unused packages to free some space\n \
Choose 7 to Remove a specific package\n \
Press CTRL+Z to Suspend or Exit
"

read -p "Choose what to clean: " choice
case $choice in
	1)
	echo -e "\nFiles older than 7 days\n"
	sudo find /var/tmp -type f -mtime +7
	;;
	2)
	echo -e "\nFolders older than 7 days\n"
	find /var/tmp -type d -mtime +7
	;;
	3)
	echo -e "\nFiles and folders older than 7 days\n"
	find /var/tmp -mtime +7
	;;
	4)
	echo -e "\nRemove files older than 7 days\n"
	sudo find /var/tmp -type f -mtime +7 -exec rm -f {} \;
	;;
	5)
	echo -e "\nRemove folders older than 7 days\n"
	sudo find /var/tmp -type d -mtime +7 -exec rm -rf {} \;
	;;
	6)echo -e "Removing unused packages..."
	sleep 2 
	sudo apt autoremove;;
	7)read -p "Enter the package name: " package
	echo -e "Removing $package package..."
        sleep 2 
        sudo apt purge $package;;
	*)
	echo -e "\n\nNo such command\n\n"
	;;
esac

}

master
