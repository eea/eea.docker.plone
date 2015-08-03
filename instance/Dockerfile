FROM eeacms/centos:7
MAINTAINER "Alin Voinea" <alin.voinea@eaudeweb.ro>

ENV PLONE_HOME=/opt/plone
RUN mkdir -p $PLONE_HOME

COPY base.cfg           $PLONE_HOME/base.cfg
COPY bootstrap.py       $PLONE_HOME/

WORKDIR $PLONE_HOME

RUN python bootstrap.py -v 2.2.1 --setuptools-version=7.0 -c base.cfg && \
    ./bin/buildout -c base.cfg && \
    groupadd -g 500 zope-www && \
    useradd -u 500 -g 500 -m -s /bin/bash zope-www && \
    chown -R 500:500 $PLONE_HOME

COPY start.sh           /usr/bin/start
COPY configure.py       /configure.py

VOLUME $PLONE_HOME/var/

CMD ["start"]
