#!/bin/bash
set -eo pipefail

dir="$(dirname "$(readlink -f "$BASH_SOURCE")")"

image="$1"

PLONE_TEST_SLEEP=6
PLONE_TEST_TRIES=30
POSTGRES_IMAGE="eeacms/postgres:9.6-3.5"

# Start PostgreSQL server
zname="postgres-container-$RANDOM-$RANDOM"
zid="$(docker run -d --name "$zname" -e POSTGRES_DBNAME="datafs zasync" -e POSTGRES_DBUSER=zope -e POSTGRES_DBPASS=zope -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres $POSTGRES_IMAGE)"

# Start Plone as RelStorage Client
pname="plone-container-$RANDOM-$RANDOM"
pid="$(docker run -d --name "$pname" --link=$zname:postgres -e ZOPE_MODE=rel_client "$image")"

# Tear down
trap "docker rm -vf $pid $zid > /dev/null" EXIT

get() {
	docker run --rm -i \
		--link "$pname":plone \
		--entrypoint /plone/instance/bin/zopepy \
		"$image" \
		-c "from six.moves.urllib.request import urlopen; con = urlopen('$1'); print(con.read())"
}

get_auth() {
	docker run --rm -i \
		--link "$pname":plone \
		--entrypoint /plone/instance/bin/zopepy \
		"$image" \
		-c "from six.moves.urllib.request import urlopen, Request; request = Request('$1'); request.add_header('Authorization', 'Basic $2'); print(urlopen(request).read())"
}

. "$dir/../../retry.sh" --tries "$PLONE_TEST_TRIES" --sleep "$PLONE_TEST_SLEEP" get "http://plone:8080"

# Plone is up and running
[[ "$(get 'http://plone:8080')" == *"Plone is up and running"* ]]

# Create a Plone site
[[ "$(get_auth 'http://plone:8080/@@plone-addsite' "$(echo -n 'admin:admin' | base64)")" == *"Create a Plone site"* ]]
