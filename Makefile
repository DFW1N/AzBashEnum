PREFIX = /usr

all:
	@echo Please ensure you run make with sudo privileges.
	@echo Run \'make install\' to install AzBashEnum.
	@echo Run \'make uninstall\' to uninstall AzBashEnum.

install:
		@mkdir -p $(DESTDIR)$(PREFIX)/bin
		@cp -p azbash $(DESTDIR)$(PREFIX)/bin/azbash
		@chmod 755 $(DESTDIR)$(PREFIX)/bin/azbash
		@curl -L https://aka.ms/InstallAzureCli | bash

uninstall:
		@rm -rf $(DESTDIR)$(PREFIX)/bin/azbash