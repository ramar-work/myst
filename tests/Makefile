# myst/tests (test suite for Myst)
# =================================
# Available targets are:

# - These are variables used to help testing
PREFIX=/srv/http
#PREFIX=/etc/flashy
DNSFILE=/etc/hosts
SRVUSER=ramar
PROG=myst

# explain (default) - Describes all of the available targets 
explain:
	@grep '^# [A-Z,a-z,=]' Makefile | sed 's/^# //' | sed 's/^/  /' | \
		awk -F '-' '{ printf "%-20s\t%s\n", $$1, $$2 }'

# check - Checks that myst is installed and that the prefix exists
check:
	@test -d $(PREFIX) || mkdir -p $(PREFIX) || echo "$(PREFIX) couldn't be created."
	@test -d $(PREFIX)
	@test -f $(DNSFILE) || echo "$(DNSFILE) does not exist"
	@test -f $(DNSFILE)
	@$(PROG) 2>&1 >/dev/null; test $$? -eq 0 || echo "Myst is not installed." 

# all - Build tooling for and run all tests
all:
	printf '' >/dev/null

# generate - Generates new instances (not intended to be used ala carte)
generate:
	$(PROG) --create --name $(TESTCASE) --folder $(PREFIX)/$(TESTCASE).local --ses --apache 

# a - add host, part of generate?
addhost:
	test `grep $(TESTCASE).local /etc/hosts && echo 1 || | echo 0` -eq 1 || \ 
		printf "127.0.0.1\t$(TESTCASE).local\n" >> /etc/hosts

# ...
#	rm -rf $(PREFIX)/$(TESTCASE)/{app,views}
#	ln -s ./$(TESTCASE).local $(PREFIX)/$(TESTCASE)

# api - Generates stress tests for XML&JSON generation routines in Myst 
api: TESTCASE=testapi
api: generate
api:
	printf ''>/dev/null


# basic - Generates stress tests for exception handling routines in Myst 
basic: TESTCASE=testbasic
basic: generate
basic:
	printf ''>/dev/null


# apache - Generates stress tests for layers requiring Apache hooks (e.g. SES) 
apache: TESTCASE=testapache
apache: generate
apache:
	printf ''>/dev/null
