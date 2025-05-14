#!/bin/bash

echo "Fixing permissions for external /data volumes"
mkdir -p /data/blobstorage /data/cache /data/filestorage /data/instance /data/ /data/log /data/zeoserver
mkdir -p /plone/instance/src
find /data  -not -user plone -exec chown plone:plone {} \+
find /plone -not -user plone -exec chown plone:plone {} \+

touch /etc/contab /etc/cron.*/*

if [ -n "$RESTART_CRON" ] ; then
    echo "${RESTART_CRON} kill -2 1" | sed "s/x/$((RANDOM % 7))/g > /var/plone_jobs.txt
    
    crontab /var/plone_jobs.txt
    chmod 600 /etc/crontab
    service cron restart

fi
if [ -n "$CRON_JOBS" ] ; then
    echo "${CRON_JOBS}" >> /var/plone_jobs.txt

    crontab /var/plone_jobs.txt
    chmod 600 /etc/crontab
    service cron restart

fi

exec /plone-entrypoint.sh "$@"
