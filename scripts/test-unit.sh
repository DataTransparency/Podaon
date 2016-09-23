#!/bin/sh -xe

: "${XCODE_WORKSPACE_FILE:?There must be a XCODE_WORKSPACE_FILE environment variable set}"
: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
: "${TEST_RESULTS_FILE:?There must be a TEST_RESULTS_FILE environment variable set}"



TEST_REPORTS_FOLDER="${BIN_DIRECTORY}/reports"
mkdir ${COVERAGE_DIR}


defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0
/usr/bin/xcodebuild test -scheme ${UNIT_TEST_SCHEME} -derivedDataPath ${BIN_DIRECTORY} -workspace ${XCODE_WORKSPACE_FILE} -configuration Debug -destination 'platform=iOS Simulator,name=iPhone SE,OS=10.0' GOOGLE_APP_ID=${GOOGLE_APP_ID} PRODUCT_BUNDLE_IDENTIFIER=${BUNDLE_IDENTIFIER} PROVISIONING_PROFILE_SPECIFIER=${PROVISIONING_PROFILE_FILENAME} -enableCodeCoverage YES | ocunit2junit

mv test-reports $TEST_REPORTS_FOLDER/
$(brew --prefix gcovr)/bin/gcovr --object-directory=${BIN_DIRECTORY}/Logs/Test/ --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${COVERAGE_DIR}/coverage.xml"

mv $TEST_REPORTS_FOLDER/TEST-ClassfitteriOSTests.xml $TEST_RESULTS_FILE