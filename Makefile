# myst - Makefile last updated: 
PREFIX = /usr/local
SHAREDIR = $(PREFIX)/share
MANDIR = ${PREFIX}/share/man
BINDIR = $(PREFIX)/bin
CONFIG = /etc
WILDCARD=*
NAME=myst
VERSION=v0.2

# list - List all the targets and what they do
list:
	@printf 'Available options are:\n'
	@sed -n '/^#/ { s/# //; 1d; p; }' Makefile | awk -F '-' '{ printf "  %-20s - %s\n", $$1, $$2 }'

# install - Install the myst package on a new system
install:
	-test -d $(PREFIX) || mkdir -p $(PREFIX)/{share,share/man,bin}/
	-mkdir -pv $(PREFIX)/share/$(NAME)/
	-cp -r ./bin/$(WILDCARD) $(PREFIX)/bin/
	-cp -r ./share/$(WILDCARD) $(PREFIX)/share/$(NAME)/
	-cp ./$(NAME).cfc $(PREFIX)/share/$(NAME)/
	-cp ./etc/$(NAME).conf $(CONFIG)/
	-sed -i -e 's;__PREFIX__;$(PREFIX);' $(CONFIG)/$(NAME).conf 

# uninstall - Uninstall the myst package on a new system
uninstall:
	-rm -f $(PREFIX)/bin/$(NAME)
	-rm -f $(CONFIG)/$(NAME).conf
	-rm -rf $(PREFIX)/share/$(NAME)/
	-systemctl disable lucee
	-rm -f /usr/lib/systemd/system/lucee.service

#if 0 
# usermake - Create a modified Makefile for regular users
pkgMakefile:
	@sed '/^# /d' Makefile | cpp - | sed '/^# /d'

# pkg - Create a package out of the most recent version
pkg:
	git archive --format=tar --prefix=myst/ master | gzip > /tmp/$(NAME).tar.gz

# pkgtag - Create new packages for distribution
pkgtag:
	git archive --format=tar --prefix=myst/ `git tag | tail -n 1` | \
		gzip > /tmp/$(NAME)-`git tag | tail -n 1`.tar.gz

# testprojects - Generate projects that stress test Apache proxy and Lucee standalone installs
test: VH_TEST=testvh
test: SA_TEST=testsa
test: LUCEE_DIR=/opt/lucee/tomcat/webapps
test:
	$(NAME) --create --basedir $(SA_TEST) --folder $(LUCEE_DIR)/$(SA_TEST) \
		--name $(SA_TEST)
	$(NAME) --create --folder /srv/http/$(VH_TEST) --name $(VH_TEST)


# testre - Delete project folders and remake them for easy 
reset: VH_TEST=testvh
reset: SA_TEST=testsa
reset: LUCEE_DIR=/opt/lucee/tomcat/webapps
reset:
	rm -rfv $(LUCEE_DIR)/$(SA_TEST) /srv/http/$(VH_TEST)


# testinit - Make sure the dev system is setup to run some tests
testinit:
	systemctl restart httpd
	systemctl restart lucee
	test -z "`grep 'testvh.local' /etc/hosts`" && \
		printf "127.0.0.1\ttestvh.local\twww.testvh.local\n" >> /etc/hosts || \
		printf '' >/dev/null


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
