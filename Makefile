########################################################################
#
# Generic Makefile
#
# Time-stamp: <Thursday 2024-08-08 10:19:05 +1000 Graham Williams>
#
# Copyright (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# App is often the current directory name.
#
# App version numbers
#   Major release
#   Minor update
#   Trivial update or bug fix

APP=$(shell pwd | xargs basename)
VER = $(shell egrep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
DATE=$(shell date +%Y-%m-%d)

# Identify a destination used by install.mk

DEST=/var/www/html/$(APP)

########################################################################
# Supported Makefile modules.

# Often the support Makefiles will be in the local support folder, or
# else installed in the local user's shares.

INC_BASE=$(HOME)/.local/share/make
INC_BASE=support

# Specific Makefiles will be loaded if they are found in
# INC_BASE. Sometimes the INC_BASE is shared by multiple local
# Makefiles and we want to skip specific makes. Simply define the
# appropriate INC to a non-existant location and it will be skipped.

INC_DOCKER=skip
INC_MLHUB=skip
INC_WEBCAM=skip

# Load any modules available.

INC_MODULE=$(INC_BASE)/modules.mk

ifneq ("$(wildcard $(INC_MODULE))","")
  include $(INC_MODULE)
endif

########################################################################
# HELP
#
# Help for targets defined in this Makefile.

define HELP
$(APP):

  rtest       Run the R script tests.

  local	     Install to $(HOME)/.local/share/$(APP)
    tgz	     Upload the installer to access.togaware.com

endef
export HELP

help::
	@echo "$$HELP"

########################################################################
# LOCAL TARGETS

locals:
	@echo "This might be the instructions to install $(APP)"

.PHONY: rtests
rtests:
	@bash r_test/rpart_test.sh

# realclean::
# 	snapcraft clean rattle

.PHONY: snap
snap:
	flutter clean
	snapcraft clean rattle
	perl -pi -e 's|version: .*|version: $(VER)|' snap/snapcraft.yaml
	snapcraft
	scp rattle_$(VER)_amd64.snap togaware.com:apps/access/rattle_dev_amd64.snap

.PHONY: isnap
isnap:
	snap install --dangerous rattle_0.0.1_amd64.snap 

rattle.zip:
	rm -f rattle.zip
	flutter build linux
	rsync -avzh build/linux/x64/release/bundle/ rattle/
	zip -r rattle.zip rattle
	rm -rf rattle

%.itest:
	flutter test --device-id linux --dart-define=PAUSE=0 integration_test/$*_test.dart

# Linux: Install locally.

local: tgz
	sudo tar zxvf installers/$(APP).tar.gz -C /opt/

# No more tgz to togaware. Moved to zip archives.
#
# tgz::
#	chmod a+r installers/*.tar.gz
#	rsync -avzh installers/*.tar.gz togaware.com:apps/access/

ginstall:
	(cd installers; make $@)
