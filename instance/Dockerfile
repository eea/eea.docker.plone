FROM eeacms/centos:7
MAINTAINER "Alin Voinea" <alin.voinea@eaudeweb.ro>

ENV PYTHON python
ENV CONFIG base.cfg
ENV SETUPTOOLS 7.0
ENV ZCBUILDOUT 2.2.1
ENV PLONE_HOME /opt/plone

COPY src/start.sh           /usr/bin/start
COPY src/configure.py       /configure.py
COPY src/versions.cfg       $PLONE_HOME/
COPY src/sources.cfg        $PLONE_HOME/
COPY src/base.cfg           $PLONE_HOME/
COPY src/bootstrap.py       $PLONE_HOME/
COPY src/install.sh         $PLONE_HOME/

RUN mkdir -p $PLONE_HOME/var && \
    groupadd -g 500 zope-www && \
    useradd  -g 500 -u 500 -m -s /bin/bash zope-www && \
    chown -R 500:500 $PLONE_HOME

VOLUME $PLONE_HOME/var/

WORKDIR $PLONE_HOME

RUN ./install.sh
CMD ["start"]
