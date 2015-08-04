# Plone Docker image used as a ZEO client

Bellow is an example of `docker-compose.yml` file for `plone-instance` used as a `ZEO` client:

    plone:
      image: eeacms/plone-instance
      ports:
      - "80:80"
      links:
      - zeoserver
      environment:
      - BUILDOUT_ZEO_CLIENT=True
      - BUILDOUT_ZEO_ADDRESS=zeoserver:8100

    zeoserver:
      image: eeacms/zeoserver
