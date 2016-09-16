: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
. $HOME/.nvm/nvm.sh
source "$HOME/.rvm/scripts/rvm"
alias cftool='node_modules/classfitter-tools/lib/index.js'

BUILD_DIR="${WORKSPACE}/ClassfitteriOS/build"
BUILD_STATUS_FILE="${BUILD_DIR}/status.txt"
BUILD_STATUS=`cat ${BUILD_STATUS_FILE}`

echo "The build status is: ${BUILD_STATUS}"

if [[ $BUILD_STATUS == "success" ]]; then
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} build 'success' 'passing' ${BUILD_URL}
else
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} build 'failure' 'failed' ${BUILD_URL}
fi
