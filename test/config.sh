#!/bin/bash
set -e

globalTests+=(
	utc
	cve-2014--shellshock
	no-hard-coded-passwords
	override-cmd
	plone-basics
	plone-addons
	plone-cors
	plone-versions
	plone-zeoclient
	plone-relstorage
)

# for "explicit" images, only run tests that are explicitly specified for that image/variant
explicitTests+=(
	[:onbuild]=1
	[:nanoserver]=1
	[:windowsservercore]=1
)
imageTests[:onbuild]+='
	override-cmd
'

testAlias+=(
	[hola-mundo]='hello-world'
	[hello-seattle]='hello-world'
)

imageTests+=(
# example onbuild
#	[python:onbuild]='
#		py-onbuild
#	'
)

globalExcludeTests+=(
	# single-binary images
	[hello-world_utc]=1
	[nats_utc]=1
	[nats-streaming_utc]=1
	[swarm_utc]=1
	[traefik_utc]=1

	[hello-world_no-hard-coded-passwords]=1
	[nats_no-hard-coded-passwords]=1
	[nats-streaming_no-hard-coded-passwords]=1
	[swarm_no-hard-coded-passwords]=1
	[traefik_no-hard-coded-passwords]=1

	# clearlinux has no /etc/password
	# https://github.com/docker-library/official-images/pull/1721#issuecomment-234128477
	[clearlinux_no-hard-coded-passwords]=1

	# alpine/slim openjdk images are headless and so can't do font stuff
	[openjdk:alpine_java-uimanager-font]=1
	[openjdk:slim_java-uimanager-font]=1
	# and adoptopenjdk has opted not to
	[adoptopenjdk_java-uimanager-font]=1

	# no "native" dependencies
	[ruby:alpine_ruby-bundler]=1
	[ruby:alpine_ruby-gems]=1
	[ruby:slim_ruby-bundler]=1
	[ruby:slim_ruby-gems]=1
	[percona:psmdb_percona-tokudb]=1
	[percona:psmdb_percona-rocksdb]=1

	# the Swift slim images are not expected to be able to run the swift-hello-world test because it involves compiling Swift code. The slim images are for running an already built binary.
	# https://github.com/docker-library/official-images/pull/6302#issuecomment-512181863
	[swift:slim_swift-hello-world]=1
)
