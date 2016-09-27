#!/bin/sh -xe

: "${XCODE_WORKSPACE_FILE:?There must be a XCODE_WORKSPACE_FILE environment variable set}"
: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
: "${TEST_RESULTS_FILE:?There must be a TEST_RESULTS_FILE environment variable set}"
: "${TEST_REPORTS_FOLDER:?There must be a TEST_REPORTS_FOLDER environment variable set}"

mkdir ${COVERAGE_DIR}
echo "THE PRODUCT_BUNDLE_IDENTIFIER is ${BUNDLE_IDENTIFIER}"

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0

/usr/bin/xcodebuild clean test -scheme ${UNIT_TEST_SCHEME} -derivedDataPath ${TEST_REPORTS_FOLDER} -workspace ${XCODE_WORKSPACE_FILE} -configuration Debug -destination "${DESTINATION}" GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit
#gcovr --object-directory=${TEST_REPORTS_FOLDER}/Logs/Test/ --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${COVERAGE_DIR}/coverage.xml"
mv ${TEST_REPORTS_FOLDER}/TEST-ClassfitteriOSTests.xml $TEST_RESULTS_FILE