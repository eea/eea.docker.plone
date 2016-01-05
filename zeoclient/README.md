# Plone Docker image used as a ZEO client

Bellow is an example of `docker-compose.yml` file for `plone` used as a `ZEO` client:

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
