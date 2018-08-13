XDG_CONFIG_HOME ?= $(HOME)/.config

.PHONY: install
install:
	mkdir -p $(XDG_CONFIG_HOME)/fish
	ln -s $(CURDIR)/config.fish $(XDG_CONFIG_HOME)/fish/config.fish
