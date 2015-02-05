# plone-docker-bootstrap

Plone multi-container cluster application for 
fast isolated and automated development, 
staging and production environments.

It is a Plone cluster, with a ZEO server, a dedicated data-volume container,
one or more zope instance, one or more admin dedicated zope instances (non-public), 
a reversed proxy-server for caching and basic load balancing.

It runs on any infrastructure, no matter 
if it is windows, mac or linux. *same same*.

## How to use it ##

Install [Docker](https://docker.com) and [Fig](http://www.fig.sh/) on host.

Clone this repo:

```
$ git clone https://github.com/demarant/plone-docker-bootstrap.git
```

Run the Fig orchestration tool to start up the plone 
application cluster with ```sudo fig up```

```
$ cd docker-plone-bootstrap
$ sudo fig up
```

'''Fig up``` will pull the images from the public docker hub 
(the first time only, next time it is faster)
create all the docker containers, run them  and will 
link them together according to the fig.yml file.

The ZODB data is kept in a 
[data-only container](https://medium.com/@ramangupta/why-docker-data-containers-are-good-589b3c6c749e) named *data*. The data container keeps the persistent data for a production environment and [must be backed up](ttps://github.com/paimpozhil/docker-volume-backup).

Now visit http://127.0.0.1:8080 to see your plone application. 
The standard user name and password is admin:admin.

When you want to stop the application you must run ```sudo fig stop```. 

For more features and documentation see [Fig.sh](http://www.fig.sh) and [Docker](https://docker.com)

## The architecture components ##
To see the entire application architecture see the fig.yml file 
which works both as the configuration for orchestration and it 
also gives a clear overview of the application architecture.
There is one zope instance only which can be scaled with the command
```sudo fig scale app=4``` in case you want 4 load-balanced zope instances. 
After that you need to reconfigure varnish and reload it. 
This varnish reconfiguration can/will be automated in the future via for example
etcd or consul.
