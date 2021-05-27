#################
Local Development
#################
Running development natively on the local host instead of in a container
************************************************************************

This directory contains a `<./Makefile>`_ and some ``./bin/*`` scripts that can be used
to stitch together, via symbolic links, the buildout configuration files from VCS
checkouts of the various repositories that are used to build the Docker image and their
base layers.  This way the buildout can be run locally against a configuration that
should be the same as the one used in the built images and changes made to that
configuration should be visible in ``$ git status`` in the checkouts they are linked
from.

So far, this has only been tested and used on an Ubuntu Groovy 20.10 host that was
largely already set up for local development.  As such there is likely more work needed
to support other development hosts (e.g. OS X).  There are also likely clean build
issues that will be discovered even on other Ubuntu hosts that don't have or have
different packages than my host.  Please test and report issues.

******
Set Up
******

The `<./Makefile>`_ depends on the given project's container image build repository
being checked out next to the repositories for any EEA base images and the
`eea.docker.plone`_ repository (for the core local development support). For example, to
do local development against `eea.docker.plone-eea-www`_, that repository must be
checked out next to the `eea.docker.kgs`_ and `eea.docker.plone`_ repositories.

The `<./Makefile>`_ build process will also use ``$ rsync ...`` to copy the latest
Postgres DB backup and restore it into a local service container.  It will also use
`SSHFS`_ to mount the BLOBs volume locally.  These both require that an ``eeacms/rsync``
service be in your personal Rancher development stack and configured with your public
SSH key.  Reach out to `Alin Voinea`_ for further details.

The default ``all`` target just builds the local development environment without running
anything::

  $ make

That process creates some configuration files intended to contain variations specific to
the given host (and thus not intended to be committed in VCS).  When it creates such
files, it will prompt the user to make any necessary changes and then stop.  In
particular, the ``RANCHER_STACK_PREFIX`` variable in ``./.env`` must match the name
prefix of your personal Rancher development stack.

***********
Basic Usage
***********

Use the ``run-debug`` target to build and run the instance locally::

  $ make run-debug

After being built, the buildout should be usable in the usual ways, e.g.::

  $ ./bin/test -s eea...


.. _`SSHFS`: https://github.com/libfuse/sshfs

.. _`eea.docker.plone`: https://github.com/eea/eea.docker.plone/
.. _`eea.docker.kgs`: https://github.com/eea/eea.docker.kgs/
.. _`eea.docker.plone-eea-www`: https://github.com/eea/eea.docker.plone-eea-www/

.. _`Alin Voinea`: https://matrix.to/#/@voineali:matrix.eea.europa.eu
