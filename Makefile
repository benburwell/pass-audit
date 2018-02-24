PREFIX ?= /usr
LIB_DIR ?= $(PREFIX)/lib
EXTENSION_DIR  ?= $(LIB_DIR)/password-store/extensions
MAN_DIR ?= $(PREFIX)/share/man

info:
	@echo "pass-audit is a shell script that goes into your pass extensions"
	@echo "folder"
	@echo ""
	@echo "To install, simply run \"make install\". On macOS, you will need to"
	@echo "run \"make install PREFIX=/usr/local\"."
	@echo ""
	@echo "To use pass-audit, you will beed to install password store"
	@echo "(https://www.passwordstore.org/)"

install:
	@install -v -d "$(MAN_DIR)/man1" && install -m 0644 -v pass-audit.1 "$(MAN_DIR)/man1/pass-audit.1"
	@install -v -d "$(EXTENSION_DIR)/" && install -m 0755 audit.bash "$(EXTENSION_DIR)/audit.bash"
	@echo "pass-audit has been installed."
	@echo ""
	@echo "Try running \"pass audit --help\" or \"man pass-audit\" for info."

uninstall:
	@rm -vrf \
		"$(MAN_DIR)/man1/pass-audit.1" \
		"$(EXTENSION_DIR)/audit.bash"

.PHONY: info install uninstall

