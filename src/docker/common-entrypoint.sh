#!/bin/bash

echo "Fixing permissions for external /data volumes"
mkdir -p /data/blobstorage /data/cache /data/filestorage /data/instance /data/ /data/log /data/zeoserver
mkdir -p /plone/instance/src
find /data  -not -user plone -exec chown plone:plone {} \+
find /plone -not -user plone -exec chown plone:plone {} \+

exec /plone-entrypoint.sh "$@"
