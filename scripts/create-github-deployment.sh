#!/bin/sh -xe
: "${text:?There must be a text environment variable set}"

. $HOME/.nvm/nvm.sh
source "$HOME/.rvm/scripts/rvm"

echo "The command was ${text}"
version=${text:7}

alias cftool='node_modules/classfitter-tools/lib/index.js'

cftool createGitHubDeployment classfitter classfitter master '["ui-tests","unit-tests","build","coverage"]' $version



cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'pending' 'running' ${BUILD_URL}
