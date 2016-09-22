#!/bin/sh -xe
: "${ENVIRONMENT:?There must be a ENVIRONMENT environment variable set}"
: "${LOCATION:?There must be a LOCATION environment variable set}"



JOB=environment
echo "The JOB is ${JOB}"

if [[ ${ENVIRONMENT} == 'production' ]]; then
    export APPLEID=1132280754
    export VENDOR_ID=com.classfitter.classfitterios
    export GOOGLE_APP_ID=1:287953837448:ios:bc5a416402e93b61
fi
if [[ ${ENVIRONMENT} == 'beta' ]]; then
    export APPLEID=1157550012
    export VENDOR_ID=com.classfitter.classfitterios.beta
    export GOOGLE_APP_ID=1:287953837448:ios:bc5a416402e93b61
fi
if [[ ${ENVIRONMENT} == 'development' ]]; then
    export APPLEID=1157576885
    export VENDOR_ID=com.classfitter.classfitterios-development
    export GOOGLE_APP_ID=1:1096116560042:ios:bc5a416402e93b61
fi
if [[ ${ENVIRONMENT} == 'test' ]]; then
    export APPLEID=1157598323
    export VENDOR_ID=com.classfitter.classfitterios-test
    export GOOGLE_APP_ID=1:1096116560042:ios:bc5a416402e93b61
fi

export TEAMID=TQYB6VJLUN
export PROVIDER=JamesWOOD1426797195
export GITHUB_REPO=classfitter
export GITHUB_OWNER=classfitter

if [[ $LOCATION == "CI" ]]; then
    export NODE_ENV=production
    export PATH=/Users/buildservice/.rvm/gems/ruby-2.3.0/bin:/Users/buildservice/.rvm/gems/ruby-2.3.0@global/bin:/Users/buildservice/.rvm/rubies/ruby-2.3.0/bin:/Users/buildservice/.rvm/bin:/Users/buildservice/.nvm/versions/node/v6.5.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/go/bin
else
    export WORKSPACE=$PWD
    export NODE_ENV=development
    export BUILD_URL=http://www.fakeurl.com
    export BUILD_NUMBER=0
    export GIT_COMMIT=efdbd257dd5aa178ebcdfc265db22997d781654e
fi

: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
echo "The WORKSPACE is ${WORKSPACE}"

export ENVIRONMENT_DIRECTORY="${WORKSPACE}/env/${ENVIRONMENT}"
export BIN_DIRECTORY="${WORKSPACE}/bin/${ENVIRONMENT}/${COMMAND}"


export FIREBASE_SERVICE_FILE=${ENVIRONMENT_DIRECTORY}/ClassfitteriOS/FirebaseServiceAccount.json
export FIREBASE_ANALYTICS_FILE=${ENVIRONMENT_DIRECTORY}/ClassfitteriOS/GoogleService-Info.plist

if [[ ${ENVIRONMENT} == 'production' ]] || [[ ${ENVIRONMENT} == 'beta' ]]; then
    export FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Live.json
    export FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Live.plist	
else
    export FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Development.json
    export FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Development.plist
fi


export VERSION_FILE="${BIN_DIRECTORY}/version.txt"
export FULL_VERSION_FILE="${BIN_DIRECTORY}/fullversion.txt"

if [[ ${LOCATION} == 'CI' ]] && [[ ${COMMAND} == 'deploy' ]] && [[ ${ENVIRONMENT} == 'production' ]]; then
	echo "Using payload from GitHub"
	: "${payload:?There must be a payload environment variable set}"
else
	echo "Using dev payload"
	export payload=`cat ${WORKSPACE}/scripts/deploymentPayload.json`
fi

export PAYLOAD_FILE="${BIN_DIRECTORY}/payload.json"
export GITHUB_STATUS_NAME="${COMMAND}/${ENVIRONMENT}"

export STATUS_FILE="${BIN_DIRECTORY}/status.txt"

export TEST_RESULTS_FILE="${BIN_DIRECTORY}/results.xml"

BUNDLE_IDENTIFIER="com.classfitter.classfitterios"
if [[ ${ENVIRONMENT} != 'production' ]]; then
	BUNDLE_IDENTIFIER="${BUNDLE_IDENTIFIER}-${ENVIRONMENT}"
fi
export BUNDLE_IDENTIFIER
echo "The BUNDLE_IDENTIFIER is ${BUNDLE_IDENTIFIER}"

export ARCHIVE_DIR="${BIN_DIRECTORY}/archive"
export EXPORT_DIR="${BIN_DIRECTORY}/export"
export EXPORT_CHECK_DIR="${BIN_DIRECTORY}/export_check"
export UPLOAD_DIR="${BIN_DIRECTORY}/upload"
export ITSMP_FILE=${UPLOAD_DIR}/mybundle.itmsp
export UPLOAD_CHECK_DIR="${BIN_DIRECTORY}/upload_check"
export COVERAGE_DIR="${BIN_DIRECTORY}/coverage"

