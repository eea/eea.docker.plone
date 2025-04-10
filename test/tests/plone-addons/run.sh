#!/bin/bash
set -eo pipefail

docker run -i --rm \
	-e PLONE_DEVELOP=src/eea.facetednavigation \
	-e PLONE_ADDONS=eea.facetednavigation \
	-e PLONE_ZCML=eea.facetednavigation-meta \
	"$1" cat custom.cfg
