#!/bin/sh -xe

: "${XCODE_WORKSPACE_FILE:?There must be a XCODE_WORKSPACE_FILE environment variable set}"
: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
: "${TEST_RESULTS_FILE:?There must be a TEST_RESULTS_FILE environment variable set}"

. $HOME/.nvm/nvm.sh
source "$HOME/.rvm/scripts/rvm"
alias cftool='node_modules/classfitter-tools/lib/index.js'

TEST_REPORTS_FOLDER="${BIN_DIRECTORY}/reports"

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0
if [[ ${LOCATION} == 'CI' ]]; then
    DESTINATION="'platform=iOS Simulator,name=iPhone SE,OS=10.0'"
else
    DESTINATION="'platform=iOS Simulator,name=iPhone 6,OS=10.0'"
fi

echo "/usr/bin/xcodebuild test -scheme ${UI_TEST_SCHEME} -derivedDataPath ${BIN_DIRECTORY} -workspace ${XCODE_WORKSPACE_FILE} -configuration Debug -destination $DESTINATION GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit"
/usr/bin/xcodebuild test -scheme ${UI_TEST_SCHEME} -derivedDataPath ${BIN_DIRECTORY} -workspace ${XCODE_WORKSPACE_FILE} -configuration Debug -destination $DESTINATION GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit


mv test-reports $TEST_REPORTS_FOLDER/
rm -rf ${JOB_STATUS_FILE}

mv ${TEST_REPORTS_FOLDER}/TEST-ClassfitteriOSUITests.xml $TEST_RESULTS_FILE
