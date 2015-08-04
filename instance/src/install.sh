#!/bin/bash
#
# Buildout config file to use. Default: base.cfg
#
if [ -z "$CONFIG" ]; then
    CONFIG="base.cfg"
fi
echo "Using $CONFIG"
echo ""
#
# Use setuptools version. Default: 7.0
#
if [ -z "$SETUPTOOLS" ]; then
  SETUPTOOLS=`cat versions.cfg | grep "setuptools\s*\=\s*" | sed 's/ *//g' | sed 's/=//g' | sed 's/[a-z]//g'`
  if [ -z "$SETUPTOOLS" ]; then
    SETUPTOOLS="7.0"
  fi
fi
echo "Using setuptools $SETUPTOOLS"
echo ""
#
# Use zc.buildout version. Default: 2.2.1
#
if [ -z "$ZCBUILDOUT" ]; then
  ZCBUILDOUT=`cat versions.cfg | grep "zc\.buildout\s*=\s*" | sed 's/^.*\=\s*//g'`
  if [ -z "$ZCBUILDOUT" ]; then
    ZCBUILDOUT="2.2.1"
  fi
fi
echo "Using zc.buildout $ZCBUILDOUT"
echo ""
#
# Use python version. Default: 2.7
#
if [ -z "$PYTHON" ]; then
  PYTHON="/usr/bin/env python"
fi
echo "Using Python: "
echo `$PYTHON --version`
#
# Run bootstrap.py
#
echo "Running $PYTHON bootstrap.py -c $CONFIG -v $ZCBUILDOUT --setuptools-version=$SETUPTOOLS"
$PYTHON "bootstrap.py" -c $CONFIG -v $ZCBUILDOUT --setuptools-version=$SETUPTOOLS
#
# Run buildout
#
echo "Running bin/buildout -c $CONFIG"
./bin/buildout -c $CONFIG
