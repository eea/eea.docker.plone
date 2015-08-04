# Plone Docker image used as a RelStorage client

Bellow is an example of `docker-compose.yml` file for `plone-instance` used as a `RelStorage + PostgreSQL` client

    plone:
      image: eeacms/plone-instance
      ports:
      - "80:80"
      links:
      - postgres
      environment:
      - BUILDOUT_REL-STORAGE=type postgresql \n host postgres \n dbname datafs \n user plone \n password plone
      - BUIDLOUT_EGGS=RelStorage psycopg2

    postgres:
      image: eeacms/postgres
      environment:
      - POSTGRES_DBNAME=datafs
      - POSTGRES_DBUSER=plone
      - POSTGRES_DBPASS=plone
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secret
