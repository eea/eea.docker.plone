# Plone 5 (Python 3) with RelStorage, RestAPI, Memcached, Async, Graylog, Sentry support (and more)

[![Build Status](https://ci.eionet.europa.eu/buildStatus/icon?job=Eionet/eea.docker.plone/master&subject=Build)](https://ci.eionet.europa.eu/blue/organizations/jenkins/Eionet%2Feea.docker.plone/activity/)
[![Pipeline Status](https://ci.eionet.europa.eu/buildStatus/icon?job=Eionet/eea.pipeline.plone/master&subject=Pipeline)](https://ci.eionet.europa.eu/blue/organizations/jenkins/Eionet%2Feea.pipeline.plone/activity/)
[![Release](https://img.shields.io/github/v/release/eea/eea.docker.plone)](https://github.com/eea/eea.docker.plone/releases)

Plone 5 (Python 3) with built-in support for:
* RelStorage
* RestAPI
* LDAP
* Memcached
* zc.async
* Graylog
* Sentry
* Faceted Navigation

This image is generic, thus you can obviously re-use it within your own projects.

## Supported tags and respective Dockerfile links

* `:latest` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/master/Dockerfile)
* `:5.2.x` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/5.2.x/Dockerfile)
* `:5.2.x-python2` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/5.2.x-python2/Dockerfile)
* `:5.1.x` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/5.1.x/Dockerfile)

### Stable and immutable tags

* `:5.2.1-3` [*Dockerfile*](https://github.com/eea/eea.docker.plone/tree/5.2.1-2/Dockerfile)
* `:5.2.0-7` [*Dockerfile*](https://github.com/eea/eea.docker.plone/tree/5.2.0-7/Dockerfile)
* `:5.2.0-python2-7` [*Dockerfile*](https://github.com/eea/eea.docker.plone/tree/5.2.0-python2-7/Dockerfile)
* `:5.1.6-7` [*Dockerfile*](https://github.com/eea/eea.docker.plone/tree/5.1.6-7/Dockerfile)

See [older versions](https://github.com/eea/eea.docker.plone/releases)

### Changes

* `github.com:` [eea/eea.docker.plone/releases](https://github.com/eea/eea.docker.plone/releases)

## Base docker image

* `hub.docker.com:` [eeacms/plone](https://hub.docker.com/r/eeacms/plone/)

## Source code

* `github.com:` [eea/eea.docker.plone](http://github.com/eea/eea.docker.plone)

## Simple Usage

### RestAPI

    $ docker run -it --rm -p 80:8080 -e SITE=api eeacms/plone

    $ curl -i http://localhost/api -H 'Accept: application/json'

### ZEO

    $ docker-compose up -d

### RelStorage (PostgreSQL)

    $ ZOPE_MODE=rel_client docker-compose up -d

### Custom image and PostgreSQL backend

    $ IMAGE=eeacms/plone:5.1.x ZOPE_MODE=rel_client docker-compose up -d

You can also dump the environment variables to `.env` file and run `docker-compose` as usual:

    $ cp .env.example .env
    $ vim .env
    $ docker-compose up -d

Now, ask for http://localhost:8080/ in your workstation web browser and add a Plone site (default credentials `admin:admin`).

See [docker-compose.yml](https://github.com/eea/eea.docker.plone/blob/master/docker-compose.yml) for more details and more about Plone at [plone](https://hub.docker.com/_/plone)

## Extending this image

For this you'll have to provide the following custom files:

* `site.cfg`
* `Dockerfile`

Below is an example of `site.cfg` and `Dockerfile` to build a custom version of Plone with some add-ons based on this image:

**site.cfg**:

    [buildout]
    extends = buildout.cfg

    [configuration]
    eggs +=
      eea.facetednavigation
      collective.elasticsearch
      collective.taxonomy

    [versions]
    eea.facetednavigation = 11.7
    collective.elasticsearch = 3.0.2
    collective.taxonomy = 1.5.1


**Dockerfile**:

    FROM eeacms/plone

    COPY site.cfg /plone/instance/
    RUN gosu plone buildout -c site.cfg

and then run

    $ docker build -t plone-rocks .


## Supported environment variables

### Zope

* `ZOPE_MODE` Can be `standalone`, `zeo_client`, `zeo_async`,  `rel_client`, `rel_async`. Default `standalone`
* `ZOPE_THREADS` Configure zserver-threads. Default `2` (e.g.: `ZOPE_THREADS=4`)
* `ZOPE_FAST_LISTEN` Set to `off` to defer opening of the HTTP socket until the end of the Zope startup phase. Defaults to `off` (e.g.: `ZOPE_FAST_LISTEN=on`)
* `ZOPE_FORCE_CONNECTION_CLOSE` Set to `on` to enforce Zope to set `Connection: close header`. Default `on` (e.g.: `ZOPE_FORCE_CONNECTION_CLOSE=off`)

### RelStorage

* `RELSTORAGE_HOST` Custom PostgreSQL address, `postgres` by default (e.g.: `RELSTORAGE_HOST=1.2.3.4`)
* `RELSTORAGE_USER` Custom PostgreSQL user, `zope` by default (e.g.: `RELSTORAGE_USER=plone`)
* `RELSTORAGE_PASS` Custom PostgreSQL password, `zope` by default (e.g.: `RELSTORAGE_PASS=secret`)
* `RELSTORAGE_KEEP_HISTORY` history-preserving database schema, `false` by default (e.g.: `RELSTORAGE_KEEP_HISTORY=true`)

### Graylog

* `GRAYLOG` Configure zope inside container to send logs to Graylog. Default `logcentral.eea.europa.eu:12201` (e.g.: `GRAYLOG=logs.example.com:12201`)
* `GRAYLOG_FACILITY` Custom GrayLog facility. Default `eea.docker.plone` (e.g.: `GRAYLOG_FACILITY=staging.example.com`)

### Sentry

* `SENTRY_DSN` Send python tracebacks to sentry.io or your custom Sentry installation (e.g.: SENTRY_DSN=https://<public_key>:<secret_key>@sentry.example.com)
* `SENTRY_SITE`, `SERVER_NAME` Add site tag to Sentry logs (e.g.: `SENTRY_SITE=foo.example.com`)
* `SENTRY_RELEASE` Add release tag to Sentry logs (e.g.: `SENTRY_RELEASE=5.1.5-34`)
* `SENTRY_ENVIRONMENT` Add environment tag to Sentry logs. Leave empty to automatically get it from `rancher-metadata` (e.g.: `SENTRY_ENVIRONMENT=staging`)

See also **Plone** [Supported Environment Variables](https://github.com/plone/plone.docker#for-advanced-usage)

## Copyright and license

The Initial Owner of the Original Code is European Environment Agency (EEA).
All Rights Reserved.

The Original Code is free software;
you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation;
either version 2 of the License, or (at your option) any later
version.

## Funding

[European Environment Agency (EU)](http://eea.europa.eu)
