#!/bin/sh -xe

: "${XCODE_WORKSPACE_FILE:?There must be a XCODE_WORKSPACE_FILE environment variable set}"
: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
: "${TEST_RESULTS_FILE:?There must be a TEST_RESULTS_FILE environment variable set}"

TEST_REPORTS_FOLDER="${BIN_DIRECTORY}/reports"
mkdir ${COVERAGE_DIR}
echo "THE PRODUCT_BUNDLE_IDENTIFIER is ${BUNDLE_IDENTIFIER}"

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0

/usr/bin/xcodebuild clean test -scheme ${UNIT_TEST_SCHEME} -derivedDataPath ${BIN_DIRECTORY} -workspace ${XCODE_WORKSPACE_FILE} -configuration ${COMPILE_TYPE} -destination "${DESTINATION}" GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit

mv test-reports $TEST_REPORTS_FOLDER/
gcovr --object-directory=${BIN_DIRECTORY}/Logs/Test/ --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${COVERAGE_DIR}/coverage.xml"

mv $TEST_REPORTS_FOLDER/TEST-ClassfitteriOSTests.xml $TEST_RESULTS_FILE