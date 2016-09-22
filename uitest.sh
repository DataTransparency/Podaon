#!/bin/sh -xe

export ENVIRONMENT = 'test'

source install.sh

: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"

. $HOME/.nvm/nvm.sh
source "$HOME/.rvm/scripts/rvm"

alias cftool='node_modules/classfitter-tools/lib/index.js'

TEST_DIR="${WORKSPACE}/ClassfitteriOS/uitest/"
COVERAGE_DIR="${TEST_DIR}/coverage"
TEST_STATUS_FILE="${TEST_DIR}/status.txt"
TEST_REPORTS_FOLDER="${TEST_DIR}/reports/"

rm -rf ${TEST_DIR}
mkdir ${TEST_DIR}
mkdir ${COVERAGE_DIR}

cat <<EOM > ${TEST_STATUS_FILE}
failure
EOM

    FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Development.json
    FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Development.plist
    FIREBASE_SERVICE_FILE=${WORKSPACE}/ClassfitteriOS/FirebaseServiceAccount.json
    FIREBASE_ANALYTICS_FILE=${WORKSPACE}/ClassfitteriOS/GoogleService-Info.plist
    #FIREBASE CRASH
    rm -rf FIREBASE_SERVICE_FILE
    echo "cp ${FIREBASE_SYMBOL_SERVICE_JSON} ${FIREBASE_SERVICE_FILE}"
    cp $FIREBASE_SYMBOL_SERVICE_JSON $FIREBASE_SERVICE_FILE
    #FIREBASE ANALYTICS
    echo "rm -rf ${FIREBASE_ANALYTICS_FILE}"
    rm -rf $FIREBASE_ANALYTICS_FILE
    cp $FIREBASE_ANALYTICS_PLIST $FIREBASE_ANALYTICS_FILE

    GOOGLE_APP_ID=1:1096116560042:ios:bc5a416402e93b61


    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'ui-tests' 'pending' 'running' ${BUILD_URL}

    defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0

    #if [[ $NODE_ENV == "production" ]]; then
    # DESTINATION="-destination ""platform=iOS,name=James's iPhone"""
    #else
    # DESTINATION="-destination 'platform=iOS Simulator,name=iPhone 6,OS=9.3'"
    #fi
    #killall "Simulator" 2> /dev/null; xcrun simctl erase all
    #IOS_VER="10.0"
    #SIMULATOR_ID=$(xcrun instruments -s | grep -o "iPhone 6 (${IOS_VER}) \[.*\]" | grep -o "\[.*\]" | sed "s/^\[\(.*\)\]$/\1/")
    #echo $SIMULATOR_ID
    #open -b com.apple.iphonesimulator --args -CurrentDeviceUDID $SIMULATOR_ID
    echo "LOCATION WAS ${LOCATION}"
    /usr/bin/xcodebuild test -scheme UITests -derivedDataPath ${TEST_DIR} -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug -destination 'platform=iOS Simulator,name=iPhone SE,OS=10.0' GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit

    #if [[ $LOCATION == "CI" ]]; then
    #else
    #/usr/bin/xcodebuild test -scheme UITests -derivedDataPath ${TEST_DIR} -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug -destination 'platform=iOS,name=iPhone6' GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit
    #fi

    mv test-reports $TEST_REPORTS_FOLDER
    rm -rf ${TEST_STATUS_FILE}
cat <<EOM > ${TEST_STATUS_FILE}
success
EOM

