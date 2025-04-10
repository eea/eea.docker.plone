#!/bin/bash
set -eo pipefail

docker run -i --rm \
	-e CORS_ALLOW_ORIGIN="http://example.com:4300,http://example.com:5300" \
	-e CORS_ALLOW_METHODS="DELETE,PUT" \
	-e CORS_ALLOW_CREDENTIALS=false \
	-e CORS_EXPOSE_HEADERS="X-Example-Header" \
	-e CORS_ALLOW_HEADERS="X-Example-Header,X-Z-Header" \
	-e CORS_MAX_AGE=600 \
	-e ZOPE_MODE=zeo_client \
	"$1" cat parts/zeo_client/etc/package-includes/999-cors-overrides.zcml
