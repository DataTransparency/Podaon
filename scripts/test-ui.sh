#!/bin/sh -xe

: "${BIN_DIRECTORY:?There must be a BIN_DIRECTORY environment variable set}"
: "${UI_TEST_SCHEME:?There must be a UI_TEST_SCHEME environment variable set}"
: "${XCODE_WORKSPACE_FILE:?There must be a XCODE_WORKSPACE_FILE environment variable set}"
: "${DESTINATION:?There must be a DESTINATION environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
: "${UI_TEST_RESULTS_FOLDER:?There must be a UI_TEST_RESULTS_FOLDER environment variable set}"
: "${TEST_RESULTS_FILE:?There must be a TEST_RESULTS_FILE environment variable set}"
: "${OCUNIT2JUNIT_FOLDER:?There must be a OCUNIT2JUNIT_FOLDER environment variable set}"

mkdir ${UI_TEST_RESULTS_FOLDER}

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0
/usr/bin/xcodebuild test -scheme ${UI_TEST_SCHEME} -derivedDataPath ${UI_TEST_RESULTS_FOLDER} -workspace ${XCODE_WORKSPACE_FILE} -configuration Debug -destination "${DESTINATION}" GOOGLE_APP_ID=${GOOGLE_APP_ID} | bundle exec ocunit2junit

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 1

mv ${OCUNIT2JUNIT_FOLDER}/TEST-ClassfitteriOSUITests.xml $TEST_RESULTS_FILE
