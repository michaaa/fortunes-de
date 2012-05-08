# Makefile for fortunes-de

# Copyright (C)  Andreas Tille (tille@debian.org)
PACKAGE=fortunes-de
VERSION=0.30

DISTFILES = README LIESMICH AUTHORS COPYING ChangeLog INSTALL \
            Makefile install.sh GPL-Deutsch NEWS
SUBDIRS = data data-more bin man predata builduti rezepte
FILES_TO_REMOVE = predata/namen

TAR = tar
GZIP = --best

srcdir = .
top_srcdir = .
distdir = $(PACKAGE)-$(VERSION)
top_distdir = $(distdir)
backup_extensions = "~" ".bak"

all: check

check:
	@if [ -z "`which fortune`" -o -z "`which strfile`" ] ; then ( \
	  echo "You will need fortune to use this database."; \
	  exit 1 ) \
	else ( \
	  echo "OK, fortune is installed."; \
	  echo "Read the INSTALL file and use install.sh to install $(distdir)." ) \
	fi

dist: distdir
	-chmod -R a+r $(distdir)
	GZIP=$(GZIP) $(TAR) chozf $(distdir).tar.gz $(distdir)
	-rm -rf $(distdir)

distdir: $(DISTFILES)
	-rm -rf $(distdir)
	mkdir $(distdir)
	-chmod 777 $(distdir)
	@for file in $(DISTFILES); do \
	  d=$(srcdir); \
	  test -f $(distdir)/$$file \
	  || ln $$d/$$file $(distdir)/$$file 2> /dev/null \
	  || cp -p $$d/$$file $(distdir)/$$file; \
	done
	for subdir in $(SUBDIRS); do \
	  d=$(srcdir); \
	  test -d $(distdir)/$$subdir \
	  || cp -pR $$d/$$subdir $(distdir)/$$subdir; \
	done

install: check
	@echo "Sorry, installation via this Makefile is not supported yet."

clean:
	-rm -f build $(FILES_TO_REMOVE)

cleanbackup: clean
	for back in $(backup_extensions); do \
	  ( find . -type f -name *$$back -exec rm -f \{\} \; ) \
	done

distclean: cleanbackup
	-rm -f $(distdir).tar.gz

