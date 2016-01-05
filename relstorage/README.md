# Plone Docker image used as a RelStorage client

Bellow is an example of `docker-compose.yml` file for `plone` used as a `RelStorage + PostgreSQL` client

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
