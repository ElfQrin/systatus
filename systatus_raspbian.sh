#!/bin/bash

# BASH Systatus for Rasbpian
# r2018-08-03 fr2016-10-18
# by Valerio Capello - http://labs.geody.com/ - License: GPL v3.0

# Config
tshilon="\e[0;33m"; tshilof="\e[0m";
tsalerton="\e[0;31m"; tsalertof="\e[0m";

# Get Terminal Window Size
COLUMNS="$(tput cols)"; LINES="$(tput lines)";

# Message
echo
date "+%a %d %b %Y %H:%M:%S %Z (UTC%:z)"
echo -n "Hello "; echo -ne "$tshilon"; echo -n "$(whoami)"; echo -ne "$tshilof";
if [ "$SSH_CONNECTION" ]; then
echo -n " ("; echo -ne "$tshilon"; echo -n "`echo $SSH_CLIENT | awk '{print $1}'`"; echo -ne "$tshilof)";
fi
echo -n ", ";
echo -n "this is "; echo -ne "$tshilon"; echo -n "$(hostname)"; echo -ne "$tshilof";
echo -n " ("; echo -ne "$tshilon"; echo -n "$(hostname -i)"; echo -ne "$tshilof)";
echo ".";
echo -n "Machine ID: "; echo -n "$(cat /etc/machine-id) ";
echo -n "Boot ID: "; echo "$(cat /proc/sys/kernel/random/boot_id) ";
echo -n "You are ";
if [ -n "$SSH_CONNECTION" ]; then
echo -n "connected remotely via SSH";
elif [[ "${DISPLAY%%:0*}" != "" ]]; then
echo -n "connected remotely "; echo -ne "$tsalerton"; echo -n "NOT"; echo -ne "$tsalertof"; echo " via SSH (which is Bad)";
else
echo -n "connected locally";
fi
echo ". Your Terminal Window Size is $COLUMNS x $LINES"
if [ $EUID -eq 0 ]; then
echo -ne "$tsalerton"; echo -n "You have ROOT superpowers!"; echo -e "$tsalertof";
fi
echo

# Software version
uname -a
echo "Bash version: $BASH_VERSION"
# Webserver version
# echo -n "$(/usr/sbin/apache2 -v|head --lines=1) "; echo "$(/usr/sbin/apache2 -v|tail --lines=1)";
# php -v|head --lines=1
# mysql -V
echo
echo -n "Installed Packages: "; dpkg --get-selections | wc -l;
echo "Last installed packages:"; grep install /var/log/dpkg.log | tail -5;
echo

# System status
echo -n "CPU: "; echo -n "$(grep 'model name' /proc/cpuinfo|head -1). ";
echo -n "Cores: "; grep -c 'processor' /proc/cpuinfo
echo
# grep MemTotal /proc/meminfo
# egrep 'Mem|Cache|Swap' /proc/meminfo
free -h
echo
# df -Th
df -P -h | awk '(0+$5 < 90 && 0+$5 > 0) {print "FS: "$1" ("$6") Size: "$2" Used: "$3" ("$5") Free: "$4" ("(100-$5)"%)";}';
echo -ne "$tsalerton"; df -P -h | awk '0+$5 >= 90 {print "FS: "$1" ("$6") Size: "$2" Used: "$3" ("$5") Free: "$4" ("(100-$5)"%)";}'; echo -ne "$tsalertof";
echo; echo -n "Uptime: "; uptime
echo

# Users
echo "Last logged users:"; last -n 5 -F
echo; echo "Currently logged users:"; who
# echo; echo -n "Current user: "; id
echo

# Security
# Shellshock vulnerability check (reports to root only)
if [ $EUID -eq 0 ]; then
env x='() { :;}; echo Bash vulnerable to Shellshock' bash -c 'echo -n'
fi