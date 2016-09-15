: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
. $(brew --prefix nvm)/nvm.sh
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH
alias cftool='node_modules/classfitter-tools/lib/index.js'

DEPLOY_DIRECTORY="${WORKSPACE}/ClassfitteriOS/deploy"
PAYLOAD_FILE="${DEPLOY_DIRECTORY}/payload.json"
DEPLOY_STATUS_FILE="${DEPLOY_DIRECTORY}/status.txt"
DEPLOY_STATUS=`cat ${DEPLOY_STATUS_FILE}`

cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} ${DEPLOY_STATUS} ${DEPLOY_STATUS} ${BUILD_URL}