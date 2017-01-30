#!/bin/bash

# BASH Systatus
# r2017-01-30 fr2016-10-18
# by Valerio Capello - http://labs.geody.com/ - License: GPL v3.0

# Get Terminal Window Size
COLUMNS="$(tput cols)"; LINES="$(tput lines)";

# Message
echo
date "+%a %d %b %Y %H:%M:%S %Z (UTC%:z)"
echo -n "Hello "; echo -ne "\033[0;33m"; echo -n "$(whoami)"; echo -ne "\033[0m";
echo -n " ("; echo -ne "\033[0;33m"; echo -n "`echo $SSH_CLIENT | awk '{print $1}'`"; echo -ne "\033[0m)";
echo -n ", ";
echo -n "this is "; echo -ne "\033[0;33m"; echo -n "$(hostname)"; echo -ne "\033[0m";
echo -n " ("; echo -ne "\033[0;33m"; echo -n "$(hostname -i)"; echo -ne "\033[0m)";
echo ".";
echo -n "Machine ID: "; echo -n "$(cat /etc/machine-id) ";
echo -n "Boot ID: "; echo -n "$(cat /proc/sys/kernel/random/boot_id) ";
echo -n "Session ID: "; echo "$(cat /proc/self/sessionid)";
echo -n "You are ";
if [ -n "${SSH_CONNECTION}" ]; then
echo -n "connected remotely via SSH";
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
echo -n "connected remotely "; echo -ne "\033[0;31m"; echo -n "NOT"; echo -ne "\033[0m"; echo " via SSH (which is Bad)";
else
echo -n "connected locally";
fi
echo ". Your Terminal Window Size is $COLUMNS x $LINES"
if [ $EUID -eq 0 ]; then
echo -ne "\033[0;31m"; echo -n "You have ROOT superpowers!"; echo -e "\033[0m";
fi
echo

# Software version
uname -a
echo "Bash version: $BASH_VERSION"
# Webserver version
echo -n "$(/usr/sbin/apache2 -v|head --lines=1) "; echo "$(/usr/sbin/apache2 -v|tail --lines=1)";
php -v|head --lines=1
mysql -V
echo

# System status
echo -n "Vendor: "; echo "$(cat /sys/class/dmi/id/sys_vendor)";
echo -n "Machine: "; echo "$(cat /sys/class/dmi/id/product_name)";
echo -n "Board: "; echo "$(cat /sys/class/dmi/id/board_vendor) $(cat /sys/class/dmi/id/board_name)";
echo -n "BIOS: "; echo "$(cat /sys/class/dmi/id/bios_vendor) $(cat /sys/class/dmi/id/bios_vendor) $(cat /sys/class/dmi/id/bios_version) $(cat /sys/class/dmi/id/bios_date)";
echo -n "CPU: "; echo -n "$(grep 'model name' /proc/cpuinfo). ";
echo -n "Cores: "; grep -c 'processor' /proc/cpuinfo
echo
# grep MemTotal /proc/meminfo
# egrep 'Mem|Cache|Swap' /proc/meminfo
free -h
echo
df -Th
# df -P -h | nawk '0+$5 >= 90 {print "FS: "$1" ("$6") Size: "$2" Used: "$3" (\033[1;31m"$5"\033[0m) Free: "$4" (\033[1;31m"(100-$5)"%\033[0m)";}'
echo; echo -n "Uptime: "; uptime
echo

# Users
echo "Last logged users:"; last -n 5 -F
echo; echo "Currently logged users:"; who
echo; echo -n "Current user: "; id
echo

# Security
# Shellshock vulnerability check (reports to root only)
if [ $EUID -eq 0 ]; then
env x='() { :;}; echo Bash vulnerable to Shellshock' bash -c 'echo -n'
fi