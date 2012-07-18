all: install

install: 
	@echo "[1/4] Installing program files..."
	@mkdir -p $(DESTDIR)/usr/bin/
	@install "d2s.pl" "$(DESTDIR)/usr/bin/d2s.pl"

	@mkdir -p $(DESTDIR)/usr/share/d2spl/{icons,modules}

	@echo "[2/4] Installing modules..."
	@install modules/* $(DESTDIR)/usr/share/d2spl/modules/

	@echo "[3/4] Installing default icons..."
	@install icons/* $(DESTDIR)/usr/share/d2spl/icons/

	@echo "[4/4] Installing example configuration file..."
	@mkdir -p $(DESTDIR)/etc/xdg/
	@mkdir -p $(DESTDIR)/etc/xdg/d2spl/
	@install "example.conf" "$(DESTDIR)/etc/xdg/d2spl/example.conf"


uninstall:
	@echo "[1/4] Removing program files..."
	@unlink "$(DESTDIR)/usr/bin/d2s.pl"

	@echo "[2/4] Removing example configuration file..."
	@unlink "$(DESTDIR)/etc/xdg/d2spl/example.conf";
	@rm -fr "$(DESTDIR)/etc/xdg/d2spl/"

	@echo "[3/4] Removing default icons..."
	@rm -fr "$(DESTDIR)/usr/share/d2spl/icons"

	@echo "[4/4] Removing modules..."
	@rm -fr "$(DESTDIR)/usr/share/d2spl/modules"

	@rm -fr "$(DESTDIR)/usr/share/d2spl"