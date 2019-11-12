# Plone 5 (Python 3) with RelStorage, RestAPI, Memcached, Async, Graylog, Sentry support (and more)

Plone 5 (Python 3) with built-in support for:
* RelStorage
* RestAPI
* Memcached
* zc.async
* Graylog
* Sentry
* Faceted Navigation

This image is generic, thus you can obviously re-use it within your own projects.

## Supported tags and respective Dockerfile links

  - [Tags](https://hub.docker.com/r/eeacms/plone/tags/)

## Base docker image

 - [hub.docker.com](https://hub.docker.com/r/eeacms/plone/)

## Source code

  - [github.com](http://github.com/eeacms/eea.docker.plone)

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

* `ZOPE_MODE` Can be `standalone`, `zeo_client`, `zeo_async`,  `rel_client`, `rel_async`. Default `standalone`
* `ZOPE_THREADS` Configure zserver-threads. Default `2` (e.g.: `ZOPE_THREADS=4`)
* `ZOPE_FAST_LISTEN` Set to `off` to defer opening of the HTTP socket until the end of the Zope startup phase. Defaults to `off` (e.g.: `ZOPE_FAST_LISTEN=on`)
* `ZOPE_FORCE_CONNECTION_CLOSE` Set to `on` to enforce Zope to set `Connection: close header`. Default `on` (e.g.: `ZOPE_FORCE_CONNECTION_CLOSE=off`)
* `GRAYLOG` Configure zope inside container to send logs to GrayLog. (e.g.: `GRAYLOG=logs.example.com:12201`)
* `GRAYLOG_FACILITY` Custom GrayLog facility. Default (e.g.: `GRAYLOG_FACILITY=staging.example.com`)
* `RELSTORAGE_HOST` Custom PostgreSQL address, `postgres` by default (e.g.: `RELSTORAGE_HOST=1.2.3.4`)
* `RELSTORAGE_USER` Custom PostgreSQL user, `zope` by default (e.g.: `RELSTORAGE_USER=plone`)
* `RELSTORAGE_PASS` Custom PostgreSQL password, `zope` by default (e.g.: `RELSTORAGE_PASS=secret`)
* `RELSTORAGE_KEEP_HISTORY` history-preserving database schema, `false` by default (e.g.: `RELSTORAGE_KEEP_HISTORY=true`)
* `SERVER_NAME` Usually the application URL without scheme (e.g.: `SERVER_NAME=staging.example.com`)
* `ENVIRONMENT`, `SENTRY_ENVIRONMENT` Override environment. Leave empty to automatically get it from `rancher-metadata`
* `APP_VERSION` Your custom application version (e.g: `APP_VERSION=5.1.5-1.0`)
* `SENTRY_DSN` Send python tracebacks to sentry.io (e.g.: `SENTRY_DSN=https://<public_key>:<secret_key>@sentry.io`)

See also **Plone** [Supported Environment Variables](https://github.com/plone/plone.docker#for-advanced-usage)
