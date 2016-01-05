# Plone Docker image (development mode)

Below is an example of `docker-compose.yml` file that will allow you to run
Plone within a Docker container and still be able to test and develop
your Plone add-ons using your favorite editor/IDE:

    plone:
      image: eeacms/plone
      ports:
      - "8080:8080"
      environment:
      - SOURCE_EEA_PDF=git https://github.com/collective/eea.pdf.git pushurl=git@github.com:collective/eea.pdf.git
      - BUILDOUT_EGGS=eea.pdf
      volumes:
      - ./src:/opt/zope/src

Now:

    $ mkdir -p src
    $ docker-compose up -d

This will git pull `eea.pdf` source code within `src` directory located on host
relatively to `docker-compose.yml` file, re-run buildout within container
to include your add-on (in this case `eea.pdf`) and start Plone instance.

Now you can start developing your add-on within `src/eea.pdf` using your
favorite editor/ide (no need to break-in docker container for this).

To reload add-on changes just restart Plone container using
docker stop/start/restart commands:

    $ docker-compose stop
    $ docker-compose start
    $ docker-compose logs

or

    $ docker-compose restart
    $ docker-compose logs

If you need to re-run buildout before Plone start,
then use the `docker-compose up` command:

    $ docker-compose up -d
    $ docker-compose logs
