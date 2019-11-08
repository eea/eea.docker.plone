#!/bin/bash

echo "Fixing permissions for external /data volumes"
mkdir -vp /data/log /plone/instance/src
chown -v plone:plone /data/log /plone/instance/src

exec /plone-entrypoint.sh "$@"
