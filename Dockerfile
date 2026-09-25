FROM plone:5.2.13
LABEL maintainer="EEA: IDM2 A-Team <eea-edw-a-team-alerts@googlegroups.com>"

ENV GRAYLOG=logcentral.eea.europa.eu:12201 \
    GRAYLOG_FACILITY=eea.docker.plone

RUN mv /docker-entrypoint.sh /plone-entrypoint.sh \
 && mv /docker-initialize.py /plone_initialize.py \
 && mv /plone/instance/buildout.cfg /plone/instance/plone-buildout.cfg \
 && mv /plone/instance/develop.cfg /plone/instance/plone-develop.cfg \
 #Update bullseye repositories
 && sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list \
 ## && sed -i 's|security.debian.org|archive.debian.org/|g' /etc/apt/sources.list \
 && sed -i '/bullseye-updates/d' /etc/apt/sources.list

COPY src/docker/* /
COPY src/plone/* /plone/instance/
RUN /docker-setup.sh
