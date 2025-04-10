#!/bin/bash
set -eo pipefail

docker run -i --rm \
	-e PLONE_DEVELOP=src/eea.facetednavigation \
	-e PLONE_ADDONS=eea.facetednavigation \
	-e PLONE_ZCML=eea.facetednavigation-meta \
	-e PLONE_VERSIONS="eea.facetednavigation=13.3 plone.restapi=5.0.0" \
	-e PLONE_SITE="plone" \
	-e PLONE_PROFILES="eea.facetednavigation:universal" \
	"$1" cat custom.cfg
