# EEA Plone application local development set up

### Defensive settings for make:
#     https://tech.davis-hansson.com/p/make/
SHELL:=bash
.ONESHELL:
.SHELLFLAGS:=-xeu -o pipefail -O inherit_errexit -c
.SILENT:
.DELETE_ON_ERROR:
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules

# Constants

RANCHER_CLI_VERSION=0.6.8
# Breaks `$ tmux` automatic window sizing, `Ctrl-c` exits the shell and probably other
# console/tty issues
# RANCHER_CLI_VERSION=0.6.9
# Latest known version that reproduces the above issue
# RANCHER_CLI_VERSION=0.6.14


# Top-level targets

.PHONY: all
all: ~/.rancher/cli.json

.PHONY: clean
clean:
	test '!' -e "./bin/rancher" || rm -rv "./bin/rancher"

# Real targets

# Rancher CLI install and set up
#
# We're using an outdated version so install locally in case the user or system needs
# the current version
~/.rancher/cli.json: bin/rancher
# Use values from Rancher Account API Keys:
#   https://rancherdev.eea.europa.eu/env/1a140884/api/keys
	./bin/rancher config
bin/rancher: var/downloads/rancher-linux-amd64-v$(RANCHER_CLI_VERSION).tar.gz
	mkdir -pv "./$(dir $(@))"
	tar -xvz --strip-components=2 -C "./$(dir $(@))" -f "./$(<)"
	touch "./$(@)"
var/downloads/rancher-linux-amd64-v$(RANCHER_CLI_VERSION).tar.gz:
	mkdir -pv "./$(dir $(@))"
	cd "./$(dir $(@))"
	wget "https://releases.rancher.com/cli/v$(RANCHER_CLI_VERSION)/rancher-linux-amd64-v$(RANCHER_CLI_VERSION).tar.gz"
