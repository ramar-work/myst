# myst - Makefile last updated: 
NAME=myst
#PREFIX=/opt/$(NAME)
PREFIX=/home/ramar/myst
LP=./tmp/myst
SHAREDIR=$(PREFIX)/share
MANDIR=${PREFIX}/share/man
BINDIR=$(PREFIX)/bin
CONFIG=/etc
WILDCARD=*
FORCE_INSTALL=0

#PREFIX=/usr/local
#LUCEE_PREFIX=$(PREFIX)/$(NAME)2

#Unix centric things here
USER=ramar
GROUP=ramar
PASS=myst
SYSTEMD_LIBDIR=/usr/lib/systemd/system

#Dependency and library list
HTTPDV=httpd-2.4.37
APRV=apr-1.7.0
APRUTILV=apr-util-1.6.1
VERSION=v0.3
CHECK=sed grep wget systemctl

#Lucee specific things
LUCEE_WWW_DOWNLOAD_HOME=https://download.lucee.org
LUCEE_WWW_CHECKSTRING=cdn.lucee.org
LUCEE_PREFIX=/tmp/myst

#Tomcat mess is here
TOMCAT_SHUTDOWN_PORT=8005
TOMCAT_PORT=8888
TOMCAT_AJP_PORT=8009
TOMCAT_MIN_HEAP=64
TOMCAT_MAX_HEAP=2048
TOMCAT_CONFIG=$(LP)/tomcat.key

#All the Apache stuff is here
TEST_PROJECT=taggart.local
FILE_BASE=./share/mystinstall
HTTPD_PREFIX=$(PREFIX)/httpd
HTTPD_LIBDIR=$(HTTPD_PREFIX)/modules
HTTPD_SRVDIR=$(HTTPD_PREFIX)/htdocs
HTTPD_CONFDIR=$(HTTPD_PREFIX)/conf
CONF_FILE=/etc/myst.conf

#Service related items here
HTTP_PORT=80
HTTPS_PORT=443
SERVER_ROOT=$(HTTPD_PREFIX)


# top: Check for depdencies, build local version of httpd & grab the newest Lucee 
top:
	make dependency-check
	make build
	test -f $(LP)/lucee.run || make retrieve-lucee 


# dump: Dump the current configuration
dump:
	@echo USER $(USER)
	@echo GROUP $(GROUP)
	@echo PREFIX $(PREFIX)
	@echo SYSTEMD_LIBDIR $(SYSTEMD_LIBDIR)
	@echo HTTP_PORT $(HTTP_PORT)
	@echo HTTPS_PORT $(HTTPS_PORT)
	@echo TOMCAT_PORT $(TOMCAT_PORT)
	@echo TOMCAT_MIN_HEAP $(TOMCAT_MIN_HEAP)
	@echo TOMCAT_MAX_HEAP $(TOMCAT_MAX_HEAP)


# clean: Clean up everything
clean:
	-rm -rf $(LP) vendor/$(HTTPDV)/ vendor/$(APRV)/ vendor/$(APRUTILV)/
	-rmdir `dirname $(LP)`


# dependency-check: Check for dependencies
dependency-check:
	@for c in $(CHECK); do \
		$$c 2>/dev/null 1>/dev/null; \
		test $$? -lt 127 || echo Dependency $$c not present on system.  Stopping...; \
	done


# TODO: Statically compile in SSL support and a bunch of other stuff...
# TODO: Do not build docs
# TODO: Use --with-suexec-caller <user> to keep things more secure...
#
# TODO:
# *Compiling with all the libraries at this location could fail when deleting $LP
# *Notice that there is no SSL library now...  You're trusting the system...
# 1. Recompiling Apache may be fine after installing APR & APR util
# 2. Does --enable-static-support solve the problem?
# 3. Build in this directory and simply move ./tmp/myst to $(PREFIX)/myst
#
# build: Build localized Apache and supporting libraries
build:
	test -d $(LP) || mkdir -p $(LP)/
	cd vendor/ && \
		tar xzf $(HTTPDV).tar.gz && \
		tar xzf $(APRV).tar.gz && \
		tar xzf $(APRUTILV).tar.gz
	FULL_LP=`realpath $(LP)` && \
		cd vendor/$(APRV)/ && \
			./configure --prefix=$$FULL_LP && \
			make && \
			make install
	FULL_LP=`realpath $(LP)` && \
		cd vendor/$(APRUTILV)/ && \
			./configure --prefix=$$FULL_LP --with-apr=$$FULL_LP && \
			make && \
			make install
	FULL_LP=`realpath $(LP)` && \
		cd vendor/$(HTTPDV)/ && \
			./configure \
				--enable-static-support \
				--with-apr=$$FULL_LP \
				--with-apr-util=$$FULL_LP \
				--prefix=$(PREFIX)/httpd && \
			make


# retrieve-lucee: Get a working stable version of Lucee
# https://cdn.lucee.org/lucee-5.3.4.080-pl0-linux-x64-installer.run
retrieve-lucee:
	FULL_LP=`realpath $(LP)` && \
	wget -O "/$$FULL_LP/lucee.run" https://cdn.lucee.org/lucee-5.3.4.080-pl0-linux-x64-installer.run && \
	chmod +x "/$$FULL_LP/lucee.run"


# retrieve-lucee: Get the most current version of Lucee from the web.
# Script seems to be broken on the latest changes to the website.
retrieve-lucee-deprecated:
	FULL_LP=`realpath $(LP)` && \
	DLOUT=$$( wget -O - $(LUCEE_WWW_DOWNLOAD_HOME) 2>/dev/null | \
		grep $(LUCEE_WWW_CHECKSTRING) | \
		sed '{ \
			s/\t//g; \
			s/<span.*>//; \
			s/<\/span>//; \
			s/<br>//; \
			s/<div.*><//; \
			s/^<//; \
			s/^a href=//; \
			s/"\(.*[^\"]\)*>\([A-Z,a-z,0-9].*\)<\/a>/\1 \2/; s/^"//; \
		}' | \
		awk '{ printf "%-10s\t%s\n", $$2, $$1 }' | \
		grep linux-x64 | \
		awk '{ print $$2 }' \
	) && \
	DLEXT=$$(basename $$DLOUT) && \
	wget -O "/$$FULL_LP/lucee.run" $$DLOUT && \
	chmod +x "/$$FULL_LP/lucee.run"


# install: Install the myst package on a new system
#	ln -s $(HTTPD_SRVDIR)
# test -d $(PREFIX) && printf "WARNING: You have already installed myst.\n" > /dev/stderr
install:
	test -d $(PREFIX) || mkdir -p $(PREFIX)/{share,share/man,bin}/
	mkdir -pv $(PREFIX)/share/$(NAME)/
	@head -c 32 /dev/urandom | xxd -ps -c 64 > $(TOMCAT_CONFIG)
	@echo Installing localized Apache...
	make httpd-install
	@echo Installing Lucee...
	make lucee-install
	@rm -f $(TOMCAT_CONFIG)
	@echo Installing Myst scripts...
	make bin-install
	@echo Installing Myst configuration...
	make config-install
	@echo Installing test project...
	make http-test-install
	@echo Updating Myst permissions...
	chown -R $(USER):$(GROUP) $(HTTPD_SRVDIR)/


# config-install: install all the configuration and files
config-install:
	cp -rf ./share/$(WILDCARD) $(PREFIX)/share/$(NAME)/
	cp -f ./$(NAME).cfc $(PREFIX)/share/$(NAME)/
	sed -e "{ \
		s;@@PREFIX@@;$(PREFIX);; \
		s/@@USER@@/$(USER)/; \
		s/@@GROUP@@/$(GROUP)/; \
		s/@@HTTP_PORT@@/$(HTTP_PORT)/; \
		s/@@HTTPS_PORT@@/$(HTTPS_PORT)/; \
	}" ./etc/$(NAME).conf > $(CONF_FILE)


# bin-install: Move all the scripts to the right place
bin-install:
	test -d $(PREFIX)/bin/ || mkdir $(PREFIX)/bin/
	cp -rf ./bin/$(WILDCARD) $(PREFIX)/bin/


# http-test-install: install an HTTP test project
http-test-install:
	sed -e "{ \
		s/@@SITEDOMAIN@@/$(TEST_PROJECT)/; \
		s/@@SITENAME@@/$(TEST_PROJECT)/; \
		s/@@ALIASDOMAIN@@/$(TEST_PROJECT)/; \
		s;@@WWWROOT@@;$(HTTPD_SRVDIR);; \
	}" $(FILE_BASE)/../default.vhost > $(HTTPD_CONFDIR)/extra/vhosts/$(TEST_PROJECT).conf
	cp -r $(FILE_BASE)/$(TEST_PROJECT) $(HTTPD_SRVDIR)/


# https-test-install: install an HTTPS test project
https-test-install:
	cp -r $(FILE_BASE)/taggart-https.local $(HTTPD_SRVDIR)/

# Need to add a lot to the Apache config file...
#
# TODO:
# x mod_cfml support for one
# x ssl support for two (although, if embedding Apache, it should be compiled in)
# x virtual hosts: Include conf/extra/vhosts-enabled/* 
#
# TODO:
# Modify the SSL support and CFML support here
#
# TODO: SSL is not working yet...
# /#Include conf\/extra\/httpd-ssl.conf/ s/^#//;
#
# httpd-install: Install the localized HTTPD to a real system folder, delete its documentation as well.
httpd-install:
	test -d $(PREFIX)/httpd || mkdir -p $(PREFIX)/httpd/
	test -d $(PREFIX)/www || mkdir -p $(PREFIX)/www/
	cd vendor/$(HTTPDV)/ && make install
	mv $(PREFIX)/httpd/htdocs/* $(PREFIX)/www/
	chown -R $(USER):$(GROUP) $(PREFIX)/www/
	rmdir $(PREFIX)/httpd/htdocs/ 
	ln -s $(PREFIX)/www/ $(PREFIX)/httpd/htdocs
	chown $(USER):$(GROUP) $(PREFIX)/httpd/htdocs
	test -d $(PREFIX)/httpd/man && rm -rf $(PREFIX)/httpd/man/ 
	test -d $(PREFIX)/httpd/manual && rm -rf $(PREFIX)/httpd/manual/ 
	test -d $(PREFIX)/virt-hosts-available || mkdir -p $(PREFIX)/virt-hosts-available/
	test -d $(PREFIX)/virt-hosts-enabled || mkdir -p $(PREFIX)/virt-hosts-enabled/
	ln -s $(PREFIX)/virt-hosts-enabled $(PREFIX)/httpd/conf/extra/vhosts
	cp $(FILE_BASE)/mod_cfml.so $(HTTPD_LIBDIR)/
	TOMCAT_KEY=`cat $(TOMCAT_CONFIG)` && \
	sed -e "{ \
		s/@@PROXYPORT@@/$(TOMCAT_PORT)/; \
		s/@@SECRETKEY@@/$$TOMCAT_KEY/ \
	}" $(FILE_BASE)/httpd-cfml.conf > $(HTTPD_CONFDIR)/extra/httpd-cfml.conf
	sed -i -e '$$ a # Include CFML settings in one file' $(HTTPD_CONFDIR)/httpd.conf
	sed -i -e '$$ a Include conf/extra/httpd-cfml.conf' $(HTTPD_CONFDIR)/httpd.conf
	sed -i -e "{ \
		s/User http/User $(USER)/; \
		s/Group http/Group $(GROUP)/; \
		s;#Include conf/extra/httpd-vhosts.conf;Include conf/extra/vhosts/$(WILDCARD);; \
		/#LoadModule proxy_module modules\/mod_proxy.so/ s/^#//; \
		/#LoadModule proxy_connect_module modules\/mod_proxy_connect.so/ s/^#//; \
		/#LoadModule proxy_http_module modules\/mod_proxy_http.so/ s/^#//; \
		/#LoadModule proxy_ajp_module modules\/mod_proxy_ajp.so/ s/^#//; \
		/#LoadModule rewrite_module modules\/mod_rewrite.so/ s/^#//; \
	}" $(HTTPD_CONFDIR)/httpd.conf


# lucee-install: Install Lucee to $(PREFIX)
#
# TODO: 
# Try a few of these. May prevent having to use two daemons
# --apachecontrolloc <apachecontrolloc>       Apache Control Script Location
# --apachemodulesloc <apachemodulesloc>       Apache Modules Directory
# --apacheconfigloc <apacheconfigloc>         Apache Configuration File
# --apachelogloc <apachelogloc>               Apache Logs Directory
lucee-install:
	-FULL_LP=`realpath $(LP)` && \
	"/$$FULL_LP/lucee.run" \
		--mode unattended \
		--unattendedmodeui none \
		--prefix "$(PREFIX)" \
		--luceepass "$(PASS)" \
		--systemuser "$(USER)" \
		--bittype 64
	mkdir -p $(PREFIX)/jdk/
	test -h $(PREFIX)/jdk/jre || ln -s $(PREFIX)/jre64-lin/jre $(PREFIX)/jdk/
	touch $(TOMCAT_CONFIG) && \
	TOMCAT_KEY=`cat $(TOMCAT_CONFIG)` && \
	sed -i -e "{ \
		s/@@tomcatshutdownport@@/$(TOMCAT_SHUTDOWN_PORT)/; \
		s/@@tomcatport@@/$(TOMCAT_PORT)/; \
		s/@@tomcatajpport@@/$(TOMCAT_AJP_PORT)/; \
		s/@@secretkey@@/$$TOMCAT_KEY/; \
	}" $(PREFIX)/tomcat/conf/server.xml
	sed -i -e "{ \
		s/@@minheap@@/$(TOMCAT_MIN_HEAP)/; \
		s/@@maxheap@@/$(TOMCAT_MAX_HEAP)/; \
	}" $(PREFIX)/tomcat/bin/setenv.sh


# systemd-init: Prepare systemd files
systemd-init:
	@echo Installing lupache.service to $(SYSTEMD_LIBDIR)
	@sed "{ \
		s;@@HTTPD_DIR@@;$(PREFIX)/httpd/bin;; \
		s/@@USER@@/$(USER)/; \
		s/@@GROUP@@/$(GROUP)/; \
	}" $(FILE_BASE)/lupache.service > $(SYSTEMD_LIBDIR)/lupache.service
	@echo Installing myst.service to $(SYSTEMD_LIBDIR)
	@sed "{ \
		s;@@LUCEE_DIR@@;$(PREFIX);; \
		s/@@USER@@/$(USER)/; \
		s/@@GROUP@@/$(GROUP)/; \
	}" $(FILE_BASE)/myst.service > $(SYSTEMD_LIBDIR)/myst.service
	systemctl daemon-reload


# systemd-deinit: Remove and disable any running systemd units having to do with Myst
systemd-deinit:
	@echo Uninstalling myst.service... 
	-@systemctl stop myst
	-@systemctl disable myst
	-rm -f /usr/lib/systemd/system/myst.service
	@echo Uninstalling lupache.service... 
	-@systemctl stop lupache
	-@systemctl disable lupache
	-rm -f /usr/lib/systemd/system/lupache.service
	systemctl daemon-reload


# systemd-start:
systemd-start:
	echo Starting systemd services
	systemctl start lupache
	systemctl start myst 


# systemd-start:
systemd-stop:
	echo Starting systemd services
	systemctl stop lupache
	systemctl stop myst 

# update - Update a local install of Myst
update:
	make bin-install
	make config-install

# uninstall - Uninstall the myst package on a new system
# TODO: Add a check for any sites in virt-hosts-{ available, enabled }
uninstall:
	-systemctl disable myst 
	-rm -f /usr/lib/systemd/system/myst.service
	-systemctl disable lupache 
	-rm -f /usr/lib/systemd/system/lupache.service
	-rm -rf $(PREFIX)/{bin,httpd,jdk,jre,lib,share,sys,tomcat}/
	-rm -f $(PREFIX)/* 2>/dev/null


# total-uninstall - Get rid of sites directory too (not a good idea)
total-uninstall:
	-@make uninstall
	-rm -rf $(PREFIX)/


# list - List all the targets and what they do
list:
	@printf 'Available options are:\n'
	@sed -n '/^#/ { s/# //; 1d; p; }' Makefile | awk -F '-' '{ printf "  %-20s - %s\n", $$1, $$2 }'


#if 0 
# usermake - Create a modified Makefile for regular users
pkgMakefile:
	@sed '/^# /d' Makefile | cpp - | sed '/^# /d'

# pkg - Create new packages for distribution
pkg:
	git archive --format=tar --prefix=myst/ `git tag | tail -n 1` | \
		gzip > /tmp/$(NAME)-`git tag | tail -n 1`.tar.gz

# pkg - Create a package of the latest dev branch for distribution
pkgtop:
	git archive --format=tar --prefix=myst/ dev | \
		gzip > /tmp/$(NAME)-dev.tar.gz


# otn - Switches sites that were previously running coldmvc.cfc as their
# engine to myst.cfc
otn: DIR=
otn:
	@test ! -z "$(DIR)" || printf "No directory specified for engine update.  (Try make -e DIR=/path/to/dir)\n" > /dev/stderr
	test ! -z "$(DIR)"
	@test -d "$(DIR)" || printf "The directory '$(DIR)' doesn't exist or isn't accessible.\n" > /dev/stderr 
	test -d "$(DIR)"
	mv $(DIR)/data.cfm $(DIR)/data_.cfm
	mv $(DIR)/index.cfm $(DIR)/index_.cfm
	mv $(DIR)/coldmvc.cfc $(DIR)/coldmvc_.cfc
	find $(DIR)/ -maxdepth 2 -type f -name Application.cfc | xargs -IFF sh -c 'BB=FF; mv FF $${BB%%.*};'
	for n in app components db files log setup std sql views; do \
		cp share/Application-Redirect.cfc $(DIR)/$$n/Application.cfc; done
	cp share/Application.cfc $(DIR)/
	cp share/index.cfm $(DIR)/
	cp myst.cfc $(DIR)/
	cp -r share/components/ $(DIR)/std/
	test -d $(DIR)/middleware/ && rm -rf $(DIR)/middleware/
	sed 's/master-post/post/' $(DIR)/data_.cfm > $(DIR)/data.cfm 

# get rid of all the old crap that's been fixed up
otndel: DIR=
otndel:
	find $(DIR)/ -maxdepth 2 -type f -name "*_.cfm" -o -name "*_.cfc"	| xargs rm -f

otn-rollback:
	printf ''	

#endif
