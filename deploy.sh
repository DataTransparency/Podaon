#!/bin/sh -xe
: "${text:?There must be a text environment variable set}"
echo "The command was ${text}"
version=${text:7}

payload='{\""version\"":\""v'${version}'\""}'
data="{""ref"":""master"",""required_contexts"":[""ui-tests"",""unit-tests"",""build"",""coverage""],""payload"":"""${payload}"""}"


curl -d ${data} -u $GITHUB_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/deployments
if [[ ${ENVIRONMENT} == 'production' ]]; then
	curl -d ${data} -u $GITHUB_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/deployments
else
	echo "would have deployed and released: "$data
fi
