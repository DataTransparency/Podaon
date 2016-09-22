#!/bin/sh -xe

: "${ENVIRONMENT_DIRECTORY:?There must be a ENVIRONMENT_DIRECTORY environment variable set}"
: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
: "${TEST_RESULTS_FILE:?There must be a TEST_RESULTS_FILE environment variable set}"



TEST_REPORTS_FOLDER="${BIN_DIRECTORY}/reports"
mkdir ${COVERAGE_DIR}


defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0
/usr/bin/xcodebuild test -scheme UnitTests -derivedDataPath ${BIN_DIRECTORY} -workspace ${ENVIRONMENT_DIRECTORY}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug -destination 'platform=iOS Simulator,name=iPhone SE,OS=10.0' GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit

mv test-reports $TEST_REPORTS_FOLDER/
$(brew --prefix gcovr)/bin/gcovr --object-directory=${BIN_DIRECTORY}/Logs/Test/ --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${COVERAGE_DIR}/coverage.xml"

mv $TEST_REPORTS_FOLDER/TEST-ClassfitteriOSTests.xml $TEST_RESULTS_FILE