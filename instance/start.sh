#!/bin/bash

_terminate() {
  $PLONE_HOME/bin/instance stop
  kill -TERM $child 2>/dev/null
}

trap _terminate SIGTERM SIGINT

if ! test -e $PLONE_HOME/buildout.cfg; then
    python /configure.py
fi

if test -e $PLONE_HOME/buildout.cfg; then
    $PLONE_HOME/bin/buildout -c $PLONE_HOME/buildout.cfg
fi

chown -R 500:500 $PLONE_HOME

$PLONE_HOME/bin/instance start
$PLONE_HOME/bin/instance logtail &

child=$!
wait "$child"
