#!/bin/sh -xe

: "${XCODE_WORKSPACE_FILE:?There must be a XCODE_WORKSPACE_FILE environment variable set}"
: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
: "${TEST_RESULTS_FILE:?There must be a TEST_RESULTS_FILE environment variable set}"
: "${UNIT_TEST_RESULTS_FOLDER:?There must be a UNIT_TEST_RESULTS_FOLDER environment variable set}"
: "${OCUNIT2JUNIT_FOLDER:?There must be a OCUNIT2JUNIT_FOLDER environment variable set}"

mkdir ${UNIT_TEST_RESULTS_FOLDER}
mkdir ${COVERAGE_DIR}

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0
/usr/bin/xcodebuild test -scheme ${UNIT_TEST_SCHEME} -derivedDataPath ${UNIT_TEST_RESULTS_FOLDER} -workspace ${XCODE_WORKSPACE_FILE} -configuration Debug -destination "${DESTINATION}" GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | bundle exec ocunit2junit

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 1

echo ${UNIT_TEST_RESULTS_FOLDER}/Logs/Test/
echo "${COVERAGE_DIR}/coverage.xml"
gcovr --object-directory=${UNIT_TEST_RESULTS_FOLDER}/Logs/Test/ --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${COVERAGE_DIR}/coverage.xml"
mv ${OCUNIT2JUNIT_FOLDER}/TEST-ClassfitteriOSTests.xml $TEST_RESULTS_FILE
