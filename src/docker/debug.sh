#!/bin/bash
set -e

cd /plone/instance
if [ ! -z "$GIT_NAME" ]; then
  if [ ! -z "$GIT_BRANCH" ]; then
    cd src/$GIT_NAME
    git pull
    if [ ! -z "$GIT_CHANGE_ID" ]; then
       GIT_BRANCH=PR-${GIT_CHANGE_ID}
       git fetch origin pull/$GIT_CHANGE_ID/head:$GIT_BRANCH
       git checkout $GIT_BRANCH
    else
       git checkout $GIT_BRANCH
       git pull
    fi
    cd ../..
    sed -i "s|^$GIT_NAME .*$|$GIT_NAME = fs $GIT_NAME|g" sources.cfg
    if [[ "$GIT_BRANCH" == "hotfix"* ||  "$GIT_BRANCH" == "HOTFIX"* ||  "$GIT_BRANCH" == "Hotfix"* ||  "$GIT_BRANCH" == "HotFix"* || ! -z "$GIT_CHANGE_ID" ]]; then
      echo "Switching sources.cfg to master"
      sed -i "s|branch=develop|branch=master|g" sources.cfg
    fi
  fi
fi

if [[ "$GIT_BRANCH" == "master" ]]; then
  echo "Switching sources.cfg to master"
  sed -i "s|branch=develop|branch=master|g" sources.cfg
fi

bin/develop rb
python /docker-initialize.py

if [ -z "$1" ]; then
  echo "============================================================="
  echo "All set. Now you can dive into container and start debugging:"
  echo "                                                             "
  echo "    $ docker exec -it <container_name_or_id> bash            "
  echo "    $ ps aux                                                 "
  echo "    $ bin/instance fg                                        "
  echo "                                                             "
  echo "============================================================="
  exec cat
fi

# Coverage
if [ "$1" == "coverage" ]; then
    cd src/$GIT_NAME
    ../../bin/coverage run ../../bin/xmltestreport --test-path $(pwd) -v -vv -s $GIT_NAME
    ../../bin/report xml --include=*$GIT_NAME*
    exit 0
fi

# Tests
if [ "$1" == "tests" ]; then
 for i in $(ls src); do

   # Auto exclude tests
   if ! grep -q "$i" bin/test; then
       echo "============================================================="
       echo "Auto: Skipping tests for: $i                                 "
       continue
   fi

   # Manual exclude tests
   if [ ! -z "$EXCLUDE" ]; then
     if [[ $EXCLUDE == *"$i"* ]]; then
       echo "============================================================="
       echo "Manual: Skipping tests for: $i                               "
       continue
     fi
   fi

   # Run tests
   echo "============================================================="
   echo "Running tests for:                                           "
   echo "                                                             "
   echo "    $i                                                       "
   echo "                                                             "

   ./bin/test --test-path /plone/instance/src/$i -v -vv -s $i
  done
else
  exec "$@"
fi

