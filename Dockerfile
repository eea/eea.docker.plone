FROM plone:5.2.1
LABEL maintainer="EEA: IDM2 A-Team <eea-edw-a-team-alerts@googlegroups.com>"

ENV GRAYLOG=logcentral.eea.europa.eu:12201 \
    GRAYLOG_FACILITY=eea.docker.plone

RUN mv /docker-entrypoint.sh /plone-entrypoint.sh \
 && mv /docker-initialize.py /plone_initialize.py \
 && mv -v /plone/instance/buildout.cfg /plone/instance/plone-buildout.cfg

COPY src/docker/* /
COPY src/plone/* /plone/instance/
RUN /docker-setup.sh
