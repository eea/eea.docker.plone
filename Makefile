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

# Use local development modifications to the base compose configuration
export COMPOSE_PATH_SEPARATOR=:
export COMPOSE_FILE=docker-compose.yml:docker-compose.local.yml

# Constants

RANCHER_CLI_VERSION=0.6.8
# Breaks `$ tmux` automatic window sizing, `Ctrl-c` exits the shell and probably other
# console/tty issues
# RANCHER_CLI_VERSION=0.6.9
# Latest known version that reproduces the above issue
# RANCHER_CLI_VERSION=0.6.14

# Export Rancher CLI variables for easier recursive `$ make -e ...` invocation
export RANCHER_CATALOG_NAME=www-eea
# Use the developer's personal stack by default
export RANCHER_STACK_PREFIX=$(USER)
RANCHER_STACK=$(RANCHER_STACK_PREFIX)-$(RANCHER_CATALOG_NAME)
export RANCHER_SERVICE_NAME=debug-instance
RANCHER_DESTINATION=$(RANCHER_STACK_PREFIX)@$(RANCHER_SERVICE_NAME).$(RANCHER_CATALOG_NAME)
# Re-attach to an existing tmux session by default
RANCHER_EXEC_OPTS=-it
RANCHER_EXEC_CMD=tmux a


# Top-level targets

.PHONY: all
all: ~/.rancher/cli.json install-pkgs

.PHONY: run-db-daemon
run-db-daemon: all
	docker-compose up -d postgres
	until docker-compose exec --user "postgres" postgres "pg_isready"
	do
	    sleep 0.5
	done

.PHONY: exec
exec: bin/rancher
	./bin/rancher-rsh $(RANCHER_EXEC_OPTS) "$(RANCHER_DESTINATION)" \
	        $(RANCHER_EXEC_CMD)
# Alternate invocation syntax for reference
#	./bin/rancher-rsh -l "$(RANCHER_STACK_PREFIX)" "$(RANCHER_DESTINATION)" \
#	        $(RANCHER_EXEC_CMD)

.PHONY: install-pkgs
install-pkgs: var/log/apt-install-$(RANCHER_CATALOG_NAME)-$(RANCHER_SERVICE_NAME).log

.PHONY: clean
clean:
	test '!' -e "./bin/rancher" || rm -rv "./bin/rancher"
	test '!' -e ./var/log/apt-install-*.log || rm -rv ./var/log/apt-install-*.log

# Real targets

# DB restore
var/log/postgresql-restore.log: postgresql.backup/datafs.gz
	$(MAKE)  run-db-daemon
	mkdir -pv "./$(dir $(@))"
# Echo restore script commands for easier debugging
	docker-compose exec --user="postgres" postgres bash -x \
	        "/postgresql.restore/database-restore.sh" "datafs" |
	    tee -a "./$(@)"
postgresql.backup/datafs.gz:
	export RANCHER_CATALOG_NAME="www-postgres"
	export RANCHER_SERVICE_NAME="master"
	$(MAKE) -e install-pkgs
	mkdir -pv "./$(dir $(@))"
	test '!' '(' -e "./$(@)" -a '!' -e "./$(@)" ')' || mv -v "./$(@)" "./$(@).tmp"
	rsync -avP --rsh "./bin/rancher-rsh" \
	        "$(RANCHER_STACK_PREFIX)@$${RANCHER_SERVICE_NAME}.$${RANCHER_CATALOG_NAME}:/$(@)" \
	        "./$(@).tmp"
	mv -v "./$(@).tmp" "./$(@)"

# Install commonly used packages, and only once to minimize Rancher CLI delay
var/log/apt-install-$(RANCHER_CATALOG_NAME)-$(RANCHER_SERVICE_NAME).log: bin/rancher
	mkdir -pv "./$(dir $(@))"
	$(MAKE) -e \
	        RANCHER_EXEC_OPTS="" \
	        RANCHER_EXEC_CMD="bash -c 'apt-get update && apt-get install -y rsync tmux'" \
	    exec | tee -a "./$(@)"

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
