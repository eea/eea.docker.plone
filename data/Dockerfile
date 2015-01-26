#FROM alteroo/data

FROM busybox:ubuntu-14.04


# Create data directory
RUN mkdir -p /opt/plone/app/var/blobstorage && \
    mkdir -p /opt/plone/app/var/filestorage && \
    mkdir -p /opt/plone/app/var/log && \
    mkdir -p /opt/plone/app/var/instance

# set plone user uid to 88
#RUN useradd plone -s /bin/bash -u 88
RUN chown -R 88:88 /opt/plone/app/var

#RUN chmod -R a+rw /opt/plone/app/var

USER 88

