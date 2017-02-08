# systatus

Systatus is a shell script to show basic information about your server which can be useful to have a quick glance of your system and rule out obvious issues if anything is going wrong.

There are two versions of this script, one to run at the shell startup ( ~/.bash_profile ) which also sets the prompt and useful aliases, and the other one to invoke whenever you want ( systatus.sh (which you may alias as systatus or sysinfo ), which can be piped to more as it shows more verbose information.

The software section is normally configured to provide information about a LAMP webserver but you can edit it to include or exclude more software you want to be sure is running.

http://labs.geody.com/systatus/

Screenshot:
<img src="http://imgur.com/UKWT6YL" />
