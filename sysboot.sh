#!/bin/bash

# SysBoot
xappname="SysBoot";
xver='r2023-08-30 fr2023-08-30'; # BETA
# by Valerio Capello - http://labs.geody.com/ - License: GPL v3.0
# System Boot.
# Requires sendmail (for e-mail alerts)
# 
# To run this script at every system boot:
# Add @reboot /PATH/sysboot.sh>/dev/null to CronTab ( crontab -e )
# Or call /PATH/sysboot.sh>/dev/null from /etc/rc.local


# Config

mailsender="server@example.com"; # Mail sender
mailreceiv="sysadmin@example.com"; # Mail recipient
mailcommand="/usr/lib/sendmail"; # Mail command ( /usr/lib/sendmail normally, and it shouldn't be modified)

mailsubjhead=""; # Mail subject head (normally empty)
mailsubjtail=""; # Mail subject tail (normally empty)

alertoutcon=true; # Send Alerts to Console
alertouteml=true; # Send Alerts via E-mail
tlogen=true; # Enable logs
tlogfn="/var/log/sysboot.log"; # Log path and file name
logsep=" "; # Separator between log elements


# Main

# currdate=$( date "+%a %Y-%m-%d %H:%M:%S %Z (UTC%:z)" | tr -d '\n' );

sysname=$( cat /proc/sys/kernel/hostname | tr -d '\n' );
# machid=$( cat /etc/machine-id | tr -d '\n' );
bootid=$( cat /proc/sys/kernel/random/boot_id | tr -d '\n' );
lastboot=$( uptime -s | tr -d '\n' );

# Output

# Output: Console
if ( $alertoutcon ); then
echo -e "${xappname} ${xver}\n\nSystem: ${sysname}\nBoot: ${lastboot}\nBoot ID: ${bootid}";
fi

# Output: E-Mail
if ( $alertouteml ); then
echo -e "Subject: ${mailsubjhead}${xappname} Alert - System: ${sysname} - Boot: ${lastboot}${mailsubjtail}\n\n${xappname} Alert\nSystem: ${sysname}\nBoot: ${lastboot}\nBoot ID: ${bootid}" | $mailcommand -F "$mailsender" -t "$mailreceiv";
fi

# Output: Log
if ( $tlogen ); then
oulog="${lastboot}${logsep}${bootid}";
if [ -f $tlogfn ]; then
loglastentry="$( tail --lines=1 $tlogfn | tr -d '\n' )";
else
loglastentry="";
fi
if [[ "$oulog" != "$loglastentry" ]]; then
echo -e "$oulog" >> $tlogfn ;
fi
fi
