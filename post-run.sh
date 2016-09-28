#!/bin/sh -xe

COMMAND=$1
ENVIRONMENT=$2

: "${ENVIRONMENT:?There must be a ENVIRONMENT environment variable set}"
: "${COMMAND:?There must be a COMMAND environment variable set}"
: "${LOCATION:?There must be a LOCATION environment variable set}"


echo "The ENVIRONMENT is ${ENVIRONMENT}"
echo "The COMMAND is ${COMMAND}"
echo "The LOCATION is ${LOCATION}"


. $HOME/.nvm/nvm.sh
source "$HOME/.rvm/scripts/rvm"
alias cftool='node_modules/classfitter-tools/lib/index.js'

source scripts/environment-variables.sh

: "${BIN_DIRECTORY:?There must be a BIN_DIRECTORY environment variable set}"

COMMAND_STATUS_FILE="${BIN_DIRECTORY}/status.txt"
COMMAND_STATUS=`cat ${COMMAND_STATUS_FILE}`

echo "STATUS WAS ${COMMAND_STATUS}"

if [[ $COMMAND_STATUS == 'success' ]]; then
    if [[ $COMMAND == 'test-unit' ]] || [[ $COMMAND == 'test-ui' ]]; then
        : "${TEST_RESULTS_FILE:?There must be a TEST_RESULTS_FILE environment variable set}"
        if [ ! -f ${BIN_DIRECTORY}/results.xml ]; then
            cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ${GITHUB_STATUS_NAME} error 'no test results' ${BUILD_URL}
        else
        
            cftool setGitHubStatusFromTestResutsFile ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ${TEST_RESULTS_FILE} ${GITHUB_STATUS_NAME} ${BUILD_URL}
        fi
    else
        cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ${GITHUB_STATUS_NAME} success 'success' ${BUILD_URL}
    fi
else
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ${GITHUB_STATUS_NAME} 'error' 'error' ${BUILD_URL}
fi  
