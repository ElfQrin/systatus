#!/bin/bash

# SysInfo / Systatus
xver='r2022-08-16 fr2016-10-18';
# by Valerio Capello - http://labs.geody.com/ - License: GPL v3.0


# Config

tshilon="\e[0;33m"; tshilof="\e[0m";
tsalerton="\e[0;31m"; tsalertof="\e[0m";

shwkernimg=false; # Show Linux images present on the system
shwkernimgii=false; # Show Linux images installed on the system
shwrunlevel=true;  # Show Current Runlevel
shwlastinpk=true; # Show Last Installed Packages
shwusrloglast=true; # Show Last logged users
shwusrlognow=true;  # Show Currently logged users

f2benable=true; # Check Fail2Ban
f2bjaillist=1; # If Fail2Ban is enabled, list all Fail2Ban Jails: 0: No, 1: Compact, 2: Detailed.
f2bjailliststatus=false; # If Fail2Ban is enabled, show status for all Fail2Ban Jails

ufwenable=true; # Check UFW (Uncomplicated Firewall)

chkshellshock=true; # Check for Shellshock Security Vulnerability


# Functions

if ( $f2benable ); then

f2blist() {
echo "fail2ban list jails"; echo;
# fail2ban-client --version ; echo;
jails=$(fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g')
jailsnum=0;
for jail in $jails
do
jailsnum=$((jailsnum+1));
jailstatus=$(fail2ban-client status $jail)
filelist=$( echo -n "$jailstatus" | grep -m 1 'File list:' | awk {'print $5'} );
echo "$jail for $filelist";
done
if [ $jailsnum -eq 1 ]; then
echo "$jailsnum Fail2Ban Jail found.";
elif [ $jailsnum -gt 1 ]; then
echo "$jailsnum Fail2Ban Jails found.";
else
echo "No Fail2Ban Jails found.";
fi
}

f2bstatus() {
echo "fail2ban-client status --all"; echo;
# fail2ban-client --version ; echo;
jails=$(fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g')
jailsnum=0;
for jail in $jails
do
jailsnum=$((jailsnum+1));
fail2ban-client status $jail
echo
done
if [ $jailsnum -eq 1 ]; then
echo "$jailsnum Fail2Ban Jail found.";
elif [ $jailsnum -gt 1 ]; then
echo "$jailsnum Fail2Ban Jails found.";
else
echo "No Fail2Ban Jails found.";
fi
}

f2bdatasize() {
# f2bdbsize=$( du -bs '/var/lib/fail2ban/' | awk '{print $1}' | tr -d '\n' );
f2bdbsize=$( du -bsc /var/lib/fail2ban/* | head --lines=1 | awk '{print $1}' | tr -d '\n' );
f2blgsize=$( du -bsc /var/log/fail2ban.* | head --lines=1 | awk '{print $1}' | tr -d '\n' );
f2btotsize=( $f2bdbsize + $f2blgsize );
echo "Fail2Ban Database size is $f2bdbsize bytes.";
echo "Fail2Ban Logs size is $f2blgsize bytes.";
echo "Fail2Ban total data size is $f2btotsize bytes.";
}

fi


# Main

# Get Terminal Window Size
COLUMNS="$(tput cols)"; LINES="$(tput lines)";

# Message
# echo
echo "Systatus (SysInfo) $xver -- https://labs.geody.com/systatus/";
echo
date "+%a %d %b %Y %H:%M:%S %Z (UTC%:z)"
echo -n "Hello "; echo -ne "$tshilon"; echo -n "$(whoami)"; echo -ne "$tshilof";
if [[ "$SSH_CONNECTION" ]]; then
echo -n " ("; echo -ne "$tshilon"; echo -n "`echo $SSH_CLIENT | awk '{print $1}'`"; echo -ne "$tshilof)";
fi
echo -n ", ";
echo -n "this is "; echo -ne "$tshilon"; echo -n "$( hostname )"; echo -ne "$tshilof";
echo -n " ("; echo -ne "$tshilon";
# echo -n "$( hostname -i )";
echo -n "$( ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' )";
echo -ne "$tshilof";
echo -n "; Gateway: ";
echo -ne "$tshilon";
echo -n "$( route -n | grep 'UG[ \t]' | awk '{print $2}' )";
echo -ne "$tshilof";
echo -n ")";
echo ".";
echo -n "Machine ID: "; echo -n "$(cat /etc/machine-id) ";
echo -n "Boot ID: "; echo -n "$(cat /proc/sys/kernel/random/boot_id) ";
echo -n "Session ID: "; echo "$(cat /proc/self/sessionid)";
echo -n "You are ";
if [[ -n "$SSH_CONNECTION" ]]; then
echo -n "connected remotely via SSH";
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
echo -n "connected remotely "; echo -ne "$tsalerton"; echo -n "NOT"; echo -ne "$tsalertof"; echo " via SSH (which is Bad)";
else
echo -n "connected locally";
fi
utty="$(tty)";
if [[ $utty == "/dev/"* ]]; then utty=$(cut -c 6- <<< $utty); fi
echo -n " on $utty";
echo ". Your Terminal Window Size is $COLUMNS x $LINES"
if [[ $EUID -eq 0 ]]; then
echo -ne "$tsalerton"; echo -n "You have ROOT superpowers!"; echo -e "$tsalertof";
fi
echo

# Machine
echo -n "Machine: "; echo "$(cat /sys/class/dmi/id/product_name) ($(cat /sys/class/dmi/id/sys_vendor))";
echo -n "Machine Type: "; echo "$MACHTYPE";
echo -n "Board: "; echo "$(cat /sys/class/dmi/id/board_vendor) $(cat /sys/class/dmi/id/board_name)";
echo -n "BIOS: "; echo "$(cat /sys/class/dmi/id/bios_vendor) $(cat /sys/class/dmi/id/bios_version) $(cat /sys/class/dmi/id/bios_date)";
echo -n "CPU: "; echo -n "$(grep 'model name' /proc/cpuinfo|head -1). ";
echo -n "Cores: "; grep -c 'processor' /proc/cpuinfo
echo

echo -n "CPU average load: "; uptime | awk -F'[a-z]:' '{print $2}' | xargs | awk '{print "1 m: "$1" 5 m: "$2" 15 m: "$3}';
echo

# grep MemTotal /proc/meminfo
# egrep 'Mem|Cache|Swap' /proc/meminfo
free -h
echo -n "Swappiness: "; cat /proc/sys/vm/swappiness | tr -d '\n'; echo '%'; 
echo
# df / -Th
df / -Th | xargs | awk '{print "FS: "$9" Type: "$10" Size: "$11" Used: "$12" ("$14") Avail: "$13" ("(100-$14)"%)"}';

echo
echo "Last Boot / Uptime: `uptime -s` (`uptime -p`)";
echo

# Kernel
if ( $shwkernimg ); then
echo "Linux images present on this system:"; dpkg --list | egrep -i 'linux-image|linux-headers' ; echo ;
fi
if ( $shwkernimgii ); then
echo "Linux images currently installed on this system:"; dpkg --list | grep -i -E 'linux-image|linux-kernel' | grep '^ii' ; echo ;
fi

# Init
if ( $shwrunlevel ); then
echo -n "Current Runlevel: "; who -r | sed 's/^ *//g' ; echo ;
fi

# Software version
lsb_release -ds
uname -a
echo "Bash version: $BASH_VERSION"
echo "Display Server: $XDG_SESSION_TYPE"
# Webserver version
echo -n "$(/usr/sbin/apache2 -v|head --lines=1) "; echo "$(/usr/sbin/apache2 -v|tail --lines=1)";
openssl version -v
php -v|head --lines=1
mysql -V

if ( $f2benable ); then
echo
istheref2b=$( type -t fail2ban-client );
if [ -n "$istheref2b" ]; then
if [ $( fail2ban-client status | wc -l ) -ge 3 ]; then
# isf2bon=true;
fail2ban-client --version | head --lines=1 ;

if [[ $f2bjaillist -eq 1 ]]; then
fail2ban-client status ;
elif [[ $f2bjaillist -eq 2 ]]; then
echo; f2blist;
fi
if ( $f2bjailliststatus ); then
echo; f2bstatus;
fi
else
# isf2bon=false;
echo 'Fail2Ban is present but not active.';
fi
else
echo 'Fail2Ban is not present.';
fi
fi

if ( $ufwenable ); then
echo
isthereufw=$( type -t ufw );
if [ -n "$isthereufw" ]; then
# ufwstatus=$( ufw status | head --lines=1 | tr -d '\n' );
# if [[ "$ufwstatus" == 'Status: active' ]]; then isufwon=true; else isufwon=false; fi
# else
# isufwon=false;
ufw --version ; ufw status ;
else
echo 'UFW (Uncomplicated Firewall) is not present.';
fi
fi

echo
echo -n "Installed Packages: "; dpkg --get-selections | wc -l;
if ( $shwlastinpk ); then
echo "Last installed packages:"; grep install /var/log/dpkg.log | tail -5;
fi
echo

# Users
if ( $shwusrloglast ); then
echo "Last logged users:"; last -n 5 -F | sed '/^$/d'
fi
if ( $shwusrlognow ); then
echo; echo "Currently logged users:"; who
fi
echo; echo -n "Current user: "; id
echo

# Security
if ( $chkshellshock ); then
# Shellshock vulnerability check (reports to root only)
if [[ $EUID -eq 0 ]]; then
env x='() { :;}; echo Bash vulnerable to Shellshock' bash -c 'echo -n'
fi
fi