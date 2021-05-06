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

# Defaults if not defined in `./.env`
RANCHER_STACK_PREFIX=$(USER)
PYTHON_EXECUTABLE=python3
ZC_BUILDOUT_VERSION=2.13.4
SETUPTOOLS_VERSION=51.3.3
WHEEL_VERSION=0.36.2
# Version from `FROM plone:...` in `../Dockerfile`
PLONE_VERSION=5.2.4

# Share environment variables between `$ make ...`, `$ docker-compose ...`, etc.:
# https://lithic.tech/blog/2020-05/makefile-dot-env
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

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
RANCHER_STACK=$(RANCHER_STACK_PREFIX)-$(RANCHER_CATALOG_NAME)
export RANCHER_SERVICE_NAME=debug-instance
RANCHER_DESTINATION=$(RANCHER_STACK_PREFIX)@$(RANCHER_SERVICE_NAME).$(RANCHER_CATALOG_NAME)
# Re-attach to an existing tmux session by default
RANCHER_EXEC_OPTS=-it
RANCHER_EXEC_CMD=tmux a

# Process source files for use as prerequisites
BUILDOUT_PLONE_CFGS=$(shell \
    docker run --rm --entrypoint="bash" "plone:$(PLONE_VERSION)" -c "ls -d1 *.cfg")
BUILDOUT_PLONE_OVERRIDEN_CFGS=buildout.cfg develop.cfg


# Top-level targets

.PHONY: all
all: ~/.rancher/cli.json var/log/buildout-install.log

.PHONY: run-debug
run-debug: \
		all var/log/postgresql-restore.log run-db-daemon \
		data/blobstorage/.local-devel.placeholder
	./bin/rel_client fg
.PHONY: run-db-daemon
run-db-daemon: all
	docker-compose exec --user "postgres" postgres "pg_isready" ||
	    ./bin/mv-backup "./var/log/postgresql-up.log"
	$(MAKE) "var/log/postgresql-up.log"

.PHONY: exec
exec: bin/rancher
	./bin/rancher-rsh $(RANCHER_EXEC_OPTS) "$(RANCHER_DESTINATION)" \
	        $(RANCHER_EXEC_CMD)
# Alternate invocation syntax for reference
#	./bin/rancher-rsh -l "$(RANCHER_STACK_PREFIX)" "$(RANCHER_DESTINATION)" \
#	        $(RANCHER_EXEC_CMD)

.PHONY: debug-db
debug-db: var/log/postgresql-restore.log run-db-daemon
	docker-compose exec --user "postgres" postgres "psql" "datafs"

.PHONY: install-pkgs
install-pkgs: var/log/apt-install-$(RANCHER_CATALOG_NAME)-$(RANCHER_SERVICE_NAME).log

.PHONY: clean
clean:
	test '!' -e "./bin/rancher" || rm -rv "./bin/rancher"
	test '!' -e ./var/log/apt-install-*.log || rm -rv ./var/log/apt-install-*.log
	rm -rv "$(BUILDOUT_PLONE_CFGS)" "$(BUILDOUT_PLONE_OVERRIDEN_CFGS:%=plone-%)"

# Real targets

# Keep local Plone instance up to date
var/log/buildout-install.log: \
		.venv/bin/activate var/log/apt-install-local.log \
		var/log/buildout-link-configs.log local.cfg
	mkdir -pv "./$(dir $(@))"
# Versions from `.../plone.docker/5.2/$(PLONE_VERSION)/debian/Dockerfile`
	"./$(dir $(<))pip3" install -U --upgrade-strategy=eager \
	        "zc.buildout==2.13.4" "setuptools==51.3.3" "wheel==0.36.2" |
	    tee -a "./$(@)"
	"./$(dir $(<))buildout" -c "./local.cfg" |
	    tee -a "./$(@)"
var/log/apt-install-local.log:
	mkdir -pv "./$(dir $(@))"
	sudo apt update | tee -a "./$(@)"
	sudo apt install -y "libmemcached-dev" | tee -a "./$(@)"
var/log/buildout-link-configs.log: plone-buildout.cfg ../src/plone/*.cfg
	ln -sfv ../src/plone/*.cfg "./" | tee -a "./$(@)"
# Extract buildout configuration from the base image
# TODO: I'd prefer to do this with symlinks to the from the upstream source to better
# support and test upstream contributions, but I couldn't quickly figure out where the
# source is for these.
plone-buildout.cfg:
	for cfg_file in $(BUILDOUT_PLONE_CFGS)
	do
	    docker run --rm --entrypoint="cat" "plone:$(PLONE_VERSION)" \
	            "./$${cfg_file}" >"./$${cfg_file}"
	done
	for override_file in $(BUILDOUT_PLONE_OVERRIDEN_CFGS)
	do
	    mv --backup=numbered -v "./$${override_file}" "./plone-$${override_file}"
	done
.venv/bin/activate:
	python3 -m venv "./$(@:%/bin/activate=%/)"

# DB restore
var/log/postgresql-restore.log: postgresql.backup/datafs.gz
	$(MAKE)  run-db-daemon
	mkdir -pv "./$(dir $(@))"
# Echo restore script commands for easier debugging
	docker-compose exec --user="postgres" postgres bash -x \
	        "/postgresql.restore/database-restore.sh" "datafs" |
	    tee -a "./$(@)"
postgresql.backup/datafs.gz: postgresql.backup/datafs.gz.update
	mkdir -pv "./$(dir $(@))"
	test '!' '(' -e "./$(@)" -a '!' -e "./$(@).tmp" ')' || mv -v "./$(@)" "./$(@).tmp"
	rsync -avP \
	        "rsync.$(RANCHER_STACK):/data/www-postgres/dump/$(notdir $(@))" \
	        "./$(@).tmp"
	mv -v "./$(@).tmp" "./$(@)"
var/log/postgresql-up.log: $(subst :, ,$(COMPOSE_FILE))
	docker-compose stop postgres | tee -a "./$(@)"
	docker-compose rm -f postgres | tee -a "./$(@)"
	docker-compose up -d postgres | tee -a "./$(@)"
	until docker-compose exec --user "postgres" postgres "pg_isready"
	do
	    sleep 0.5
	done | tee -a "./$(@)"

# BLOB storage local mount via SSH
data/blobstorage/.local-devel.placeholder: /usr/bin/sshfs
	mkdir -pv "./$(dir $(@))" "./data/blobstorage/"
	"$(<)" -o nonempty \
	        "rsync.$(RANCHER_STACK):/data/www-blobstorage/" "./data/blobstorage/"
	touch "./$(@)"
# SSHFS local host OS package install
/usr/bin/sshfs:
	apt-get update
	apt-get install -y sshfs

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
