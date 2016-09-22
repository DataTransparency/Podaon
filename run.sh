#!/bin/sh -xe

COMMAND=$1
ENVIRONMENT=$2

: "${ENVIRONMENT:?There must be a ENVIRONMENT environment variable set}"
: "${COMMAND:?There must be a COMMAND environment variable set}"
: "${LOCATION:?There must be a LOCATION environment variable set}"


echo "The ENVIRONMENT is ${ENVIRONMENT}"
echo "The COMMAND is ${COMMAND}"
echo "The LOCATION is ${LOCATION}"

if ([[ $ENVIRONMENT == "beta" ]] || [[ $ENVIRONMENT == "production" ]]) && ([[ $COMMAND == "test-ui" ]] || [[ $COMMAND == "test-unit" ]]); then
    echo "Invalid ENVIRNONMENT and COMMAND combination ${ENVIRONMENT} ${COMMAND}"
    exit 1
fi

if ([[ $ENVIRONMENT == "development" ]] || [[ $ENVIRONMENT == "test" ]]) && [[ $COMMAND == "deploy" ]]; then
    echo "Invalid ENVIRNONMENT and COMMAND combination ${ENVIRONMENT} ${COMMAND}"
    exit 1
fi


source scripts/environment-variables.sh
source scripts/environment-files.sh

: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${PAYLOAD_FILE:?There must be a PAYLOAD_FILE environment variable set}"


if [[ $COMMAND == 'deploy' ]] && [[ $ENVIRONMENT == 'CI' ]]; then
    cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'pending' 'running' ${BUILD_URL}
fi


cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ${GITHUB_STATUS_NAME} 'pending' 'running' ${BUILD_URL}

cat <<EOM > ${STATUS_FILE}
failure
EOM

sh scripts/${COMMAND}.sh

cat <<EOM > ${STATUS_FILE}
success
EOM