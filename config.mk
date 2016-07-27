# Directories
PREFIX = /usr/local
SHARE = $(PREFIX)/share
BIN = $(PREFIX)/bin
CONFIG = /etc

# Deploy source to other directories via this variable.
# See target titled 'depd' for more information.
DIR =

# You probably don't need to touch this
ARCHIVEDIR=..
ARCHIVEFMT = gz
MANPREFIX = ${PREFIX}/share/man
LDDIRS = -L$(PREFIX)/lib
LDFLAGS =
SHARED_LDFLAGS =
CC = gcc
#CC = clang

# Linux
# Modify these to fit your system.
#	-DVERBOSE        - Be verbose
#	-DFASTLINES      - Use fast line optimizations
#	-DSLOW           - Plot slowly
#	-DSPEED=N        - Update screen every N nanoseconds. 
#	-DBOUNDS_CHECK   - Do bounds checking at plot
#	-DBOUNDS_CHECKL  - Do bounds checking at line 
#	-DDEBUG          - Do bounds checking at line 
#  -DGIANTSCREEN    - Use 32 bit integers for large surfaces
# DFLAGS = -DDEBUG -DBOUNDS_CHECK -DTOSTDOUT

# Performance profiling, comment this if you want none...
# -g allows for source annotations
# -pg allows for regular profiling
# PFLAGS = -g -pg 
# CFLAGS = $(PFLAGS) -fPIC -Wall -Werror -Wno-unused -std=c99 -Wno-deprecated-declarations -O2 -pedantic $(LDDIRS) $(LDFLAGS) $(DFLAGS)
CFLAGS = -g -Wall -Werror -Wno-unused -Wstrict-overflow -ansi -std=c99 -Wno-deprecated-declarations -O2 -pedantic-errors $(LDDIRS) $(LDFLAGS) $(DFLAGS)

# Cygwin 
# CFLAGS = -Wall -Werror -Wno-unused -std=c99 -Wno-deprecated-declarations -O2 -pedantic ${LDFLAGS}
# DSOFLAGS = -fpic
# DSOEXT = dll

# OSX 
# CFLAGS = -Wall -Werror -Wno-unused -std=c99 -Wno-deprecated-declarations -O2 -pedantic ${LDFLAGS}
# DSOFLAGS = -fpic
# DSOEXT = dylib
