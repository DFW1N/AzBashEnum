PREFIX = /usr
MANDIR = $(PREFIX)/share/man

all:
	@echo Run \'make install\' to install AzBashEnum.

install:
		@mkdir -p $(DESTDIR)$(PREFIX)/bin
		@mkdir -p $(DESTDIR)$(MANDIR)/man1
		@cp -p azbashenum $(DESTDIR)$(PREFIX)/bin/azbashenum
		@cp -p azbashenum.1 $(DESTDIR)$(MANDIR)/man1
		@chmod 755 $(DESTDIR)$(PREFIX)/bin/azbashenum

uninstall:
		@rm -rf $(DESTDIR)$(PREFIX)/bin/azbashenum
		@rm -rf $(DESTDIR)$(MANDIR)/man1/azbashenum.1*