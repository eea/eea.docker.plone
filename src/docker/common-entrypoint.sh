#!/bin/bash

echo "Fixing permissions for external /data volumes"
mkdir -p /data/log /plone/instance/src
find /data/log -not -user plone -exec chown plone:plone {} \+
find /plone/instance/src -not -user plone -exec chown plone:plone {} \+

exec /plone-entrypoint.sh "$@"
