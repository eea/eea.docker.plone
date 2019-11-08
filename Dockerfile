FROM plone:5.2.0
LABEL maintainer="EEA: IDM2 A-Team <eea-edw-a-team-alerts@googlegroups.com>"

RUN mv /docker-entrypoint.sh /plone-entrypoint.sh \
 && mv -v /plone/instance/buildout.cfg /plone/instance/buildout-core.cfg

COPY src/docker/* /
COPY src/plone/* /plone/instance/
RUN /docker-setup.sh
