#!/bin/bash -

#Start both Apache and Lucee as one...

#Method 1: Use systemctl
#systemctl start lupache && systemctl start myst

#Method 2: Just use regular shell (will not work on OSX)
while [ $# -gt 0 ]
do
	printf '' # handle --start, --stop, --restart, etc
	shift
done

# lucee service (should start after lupache)
[Unit]
Description="Lucee CFML server"
After=network.target

[Service]
ExecStart=@@LUCEE_DIR@@/lucee_ctl start
ExecStop=@@LUCEE_DIR@@/lucee_ctl stop
ExecReload=@@LUCEE_DIR@@/lucee_ctl restart 
Type=forking
#User=@@USER@@
#Group=@@GROUP@@

[Install]
WantedBy=multi-user.target
# Localized HTTPD service
[Unit]
Description="Lucee's own Apache server."
After=network.target

[Service]
Type=forking
KillMode=mixed
ExecStart=@@HTTPD_DIR@@/httpd -k start
ExecStop=@@HTTPD_DIR@@/httpd -k graceful-stop 
ExecReload=@@HTTPD_DIR@@/httpd -k graceful
#User=@@USER@@
#Group=@@GROUP@@

[Install]
WantedBy=multi-user.target
