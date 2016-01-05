# Plone ready to run Docker image

Docker image for Plone with `plone.recipe.zope2instance` full support
(supports all plone.recipe.zope2instance options as docker environment variables).

This image is generic, thus you can obviously re-use it within
your non-related EEA projects.

### Warning

For security reasons, latest builds of this image run Plone on port **8080** instead
of **80**. Please update your deployment accordingly.

## Supported tags and respective Dockerfile links

  - `:latest` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/master/instance/Dockerfile) (default)
  - `:5.x` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/5.x/instance/Dockerfile)
  - `:5.0` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/5.0/instance/Dockerfile)
  - `:4.x` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/4.x/instance/Dockerfile)
  - `:4.3.7` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/4.3.7/instance/Dockerfile)
  - `:4.3.6` [*Dockerfile*](https://github.com/eea/eea.docker.plone/blob/4.3.6/instance/Dockerfile)

### Changes

 - [CHANGELOG.md](https://github.com/eea/eea.docker.plone/blob/master/CHANGELOG.md)

## Base docker image

 - [hub.docker.com](https://registry.hub.docker.com/u/eeacms/plone)

## Source code

  - [eea.docker.plone](http://github.com/eea/eea.docker.plone)

## Installation

1. Install [Docker](https://www.docker.com/)

2. Install [Docker Compose](https://docs.docker.com/compose/) (optional)

## Usage

Most of the configuration of this image is based on the
[plone.recipe.zope2instance](https://pypi.python.org/pypi/plone.recipe.zope2instance)
recipe package so it is advised that you check it out.

### Run with basic configuration

    $ docker run -p 8080:8080 eeacms/plone

The above will first download the images (first time) and than exposing plone on the host port 8080. Now go to `http://<yourserverip>:8080` to see Plone in action.

The above will run the container in foreground and output to consol. As usual you can [start docker container in detached mode](https://docs.docker.com/reference/run/#detached-vs-foreground).

The image is built using a bare [base.cfg](https://github.com/eea/eea.docker.plone/blob/master/instance/src/base.cfg) file:

    ...
    [instance]
    recipe = plone.recipe.zope2instance
    user = admin:admin
    http-address = 8080
    effective-user = zope-www
    eggs =
      Pillow
      Plone
      plone.app.upgrade
    ...

`plone` will therefore run inside the container with the default parameters given
by the recipe, with some little customization, such as `effective-user`.

### Extend configuration through environment variables

Environment variables can be supplied either via an `env_file` with the `--env-file` flag

    $ docker run --env-file plone.env eeacms/plone

or via the `--env` flag

    $ docker run --env BUILDOUT_HTTP_ADDRESS="8081" eeacms/plone

It is **very important** to know that the environment variables supplied are translated
into `zc.buildout` configuration. For each variable with the prefix `BUILDOUT_` there will be
a line added to the `[instance]` configuration. For example, if you want to set the
`read-only` attribute to the value `true`, you have to supply an environment variable
in the form `BUILDOUT_READ_ONLY="true"`. When the environment variable is processed,
the prefix is striped, `_` turns to `-` and uppercase turns to lowercase. Also, if the
value is enclosed in quotes or apostrophes, they will be striped. The configuration will
look like

    [instance]
    ...
    read-only = true
    ...

The variables supported are the ones supported by the [recipe](https://pypi.python.org/pypi/plone.recipe.zope2instance),
so check out its documentation for a full list. Keep in mind that this option will trigger
a rebuild when the docker container is created and might cause a few seconds of delay.

### Use a custom configuration file mounted as a volume

    $ docker run -v /path/to/your/configuration/file:/opt/zope/buildout.cfg eeacms/plone

**buildout.cfg**

    [buildout]
    extends = base.cfg

    parts +=
      zopepy

    [instance]
    eggs +=
      eea.facetednavigation

    [zopepy]
    recipe = zc.recipe.egg
    eggs = ${instance:eggs}
    interpreter = zopepy


You are able to start a container with your custom `buildout` configuration with the mention
that it must be mounted at `/opt/zope/buildout.cfg` inside the container. Keep in mind
that this option will trigger a rebuild at container creation and might cause delay, based on your
configuration. It is unadvised to use this option to install many packages, because they will
have to be reinstalled every time a container is created. To speed up deployment,
you may want to build your custom image. See the next section for examples
on how to accomplish this task.


### Extend the image with custom buildout configuration files

For this you have the possibility to override:

* `versions.cfg` - provide your custom Plone and Add-ons versions
* `sources.cfg`  - provide un-released Plone Add-ons
* `base.cfg`     - customize everything

Below is an example of `base.cfg` and `Dockerfile` to build a custom version
of Plone with your custom versions of packages based on this image:

**base.cfg**:

    [buildout]
    extends = plone.cfg

    [instance]
    eggs += eea.facetednavigation

**Dockerfile**:

    FROM eeacms/plone

    COPY base.cfg /opt/zope/base.cfg
    RUN ./install.sh

and then run

    $ docker build -t plone:custom .

In the same way you can provide custom `sources.cfg` and `versions.cfg` or all of
them together.

If your egg has system dependencies, you should define these dependencies
within a file called *requires.yum* inside the egg. For example, eea.converter
requires wkhtmltopdf and ImageMagick, for this:

    $ tree /opt/zope/eggs/eea.converter
    /opt/zope/eggs/eea.converter
    |_ EGG-INFO/requires.yum
    |_ ...

    $ cat /opt/zope/eggs/eea.converter/EGG-INFO/requires.yum
    ImageMagick
    http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-centos7-amd64.rpm

In this way, this image will know to install these dependencies before starting
Zope.


### ZEO client

Below is an example of `docker-compose.yml` file for `plone` used as a `ZEO` client:

    plone:
      image: eeacms/plone
      ports:
      - "8080:8080"
      links:
      - zeoserver
      environment:
      - BUILDOUT_ZEO_CLIENT=True
      - BUILDOUT_ZEO_ADDRESS=zeoserver:8100

    zeoserver:
      image: eeacms/zeoserver

### RelStorage client

Below is an example of `docker-compose.yml` file for `plone` used as a `RelStorage + PostgreSQL` client

    plone:
      image: eeacms/plone
      ports:
      - "8080:8080"
      links:
      - postgres
      environment:
      - BUILDOUT_REL-STORAGE=type postgresql \n host postgres \n dbname datafs \n user zope \n password zope
      - BUIDLOUT_EGGS=RelStorage psycopg2

    postgres:
      image: eeacms/postgres
      environment:
      - POSTGRES_DBNAME=datafs
      - POSTGRES_DBUSER=zope
      - POSTGRES_DBPASS=zope
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret


### Developing Plone Add-ons

Add the following code within `docker-compose.yml` to develop `eea.pdf` add-on:

    plone:
      image: eeacms/plone
      ports:
      - "8080:8080"
      environment:
      - SOURCE_EEA_PDF=git https://github.com/collective/eea.pdf.git pushurl=git@github.com:collective/eea.pdf.git
      - BUILDOUT_EGGS=eea.pdf
      volumes:
      - ./src:/opt/zope/src

Then:

    $ mkdir -p src
    $ docker-compose up -d

This will git pull `eea.pdf` source code within `src` directory located on host
relatively to `docker-compose.yml` file, re-run buildout within container
to include your add-on (in this case `eea.pdf`) and start Plone instance.

Now you can start developing your add-on within `src/eea.pdf` using your favorite editor/ide.

To reload add-on changes just restart Plone container using docker stop/start/restart commands:

    $ docker-compose stop
    $ docker-compose start
    $ docker-compose logs

or

    $ docker-compose restart
    $ docker-compose logs

If you need to re-run buildout before Plone start, then use the `docker-compose up` command:

    $ docker-compose up -d
    $ docker-compose logs


## Persistent data as you wish

For production use, in order to avoid data loss we advise you to keep your Data.fs and blobs within
a [data-only container](https://medium.com/@ramangupta/why-docker-data-containers-are-good-589b3c6c749e).
The `data` container keeps the persistent data for a production environment and must be backed up.
If you are running in a devel environment, you can skip the backup and delete the container if you want.

If you have a Data.fs file for your application, you can add it to the `data` container with the following
command:

    $ docker run --rm \
      --volumes-from my_data_container \
      --volume /host/path/to/Data.fs:/restore/Data.fs:ro \
      busybox \
        sh -c "cp /restore/Data.fs /opt/zope/var/filestorage && \
        chown -R 500:500 /opt/zope/var/filestorage"

The command above creates a bare `busybox` container using the persistent volumes of your data container.
The parent directory of the `Data.fs` file is mounted as a `read-only` volume in `/restore`, from where the
`Data.fs` file is copied to the filestorage directory you are going to use (default `/opt/zope/var/filestorage`).
The `data` container must have this directory marked as a volume, so it can be used by the `plone` container,
with a command like:

    $ docker run --volumes-from my_data_container eeacms/plone

The volumes from the `data` container will overwrite the contents of the directories inside the `plone`
container, in a similar way in which the `mount` command works. So, for example, if your data container
has `/opt/zope/var/filestorage` marked as a volume, running the above command will overwrite the
contents of that folder in the `plone` with whatever there is in the `data` container.

The data container can also be easily [copied, moved and be reused between different environments](https://docs.docker.com/userguide/dockervolumes/#backup-restore-or-migrate-data-volumes).

### Docker-compose example

A `docker-compose.yml` file for `plone` using a `data` container:

    plone:
      image: eeacms/plone
      volumes_from:
      - data

    data:
      image: busybox
      volumes:
      - /opt/zope/var/filestorage
      - /opt/zope/var/blobstorage
      command: chown -R 500:500 /opt/zope/var

## Upgrade

    $ docker pull eeacms/plone


## Supported environment variables ##

As mentioned above, the supported environment variables are derived from the configuration options
from the [recipe](https://pypi.python.org/pypi/plone.recipe.zope2instance). For example, `read-only`
becomes `BUILDOUT_READ_ONLY` and `http-address` becomes `BUILDOUT_HTTP_ADDRESS`.

For variables that support a list of values (such as `eggs`, for example), separate them by space, as
in `BUILDOUT_EGGS="eea.pdf eea.annotator"`.

For complex variables (such as `event-log-custom`, for example), specify new lines with `\n`, as
in BUILDOUT_EVENT_LOG_CUSTOM="<graylog> \n server 123.4.5.6 \n rabbit True \n </graylog>"

Besides the variables supported by the `zope2instance` recipe, you can also use the following variables
to extend the `[buildout]` tag:
- `INDEX`
- `FIND_LINKS`
- `EXTENSIONS`
- `AUTO_CHECKOUT`
- `ALWAYS_CHECKOUT`

Also, to provide `[sources]` entries, use `SOURCE_` prefix, like:

    SOURCE_EEA_PDF=git https://github.com/collective/eea.pdf.git


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
