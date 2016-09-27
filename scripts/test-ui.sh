#!/bin/sh -xe

: "${BIN_DIRECTORY:?There must be a BIN_DIRECTORY environment variable set}"
: "${UI_TEST_SCHEME:?There must be a UI_TEST_SCHEME environment variable set}"
: "${XCODE_WORKSPACE_FILE:?There must be a XCODE_WORKSPACE_FILE environment variable set}"
: "${DESTINATION:?There must be a DESTINATION environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
: "${TEST_REPORTS_FOLDER:?There must be a TEST_REPORTS_FOLDER environment variable set}"
: "${TEST_RESULTS_FILE:?There must be a TEST_RESULTS_FILE environment variable set}"

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0

/usr/bin/xcodebuild test -scheme ${UI_TEST_SCHEME} -derivedDataPath ${TEST_REPORTS_FOLDER} -workspace ${XCODE_WORKSPACE_FILE} -configuration Debug -destination "${DESTINATION}" GOOGLE_APP_ID=${GOOGLE_APP_ID} | ocunit2junit
mv ${TEST_REPORTS_FOLDER}/TEST-ClassfitteriOSUITests.xml $TEST_RESULTS_FILE
