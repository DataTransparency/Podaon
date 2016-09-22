#!/bin/sh -xe

ENVIRONMENT='test'

source install.sh

TEST_DIR="${WORKSPACE}/ClassfitteriOS/unittest/"
COVERAGE_DIR="${TEST_DIR}/coverage"
TEST_STATUS_FILE="${TEST_DIR}/status.txt"
TEST_REPORTS_FOLDER="${TEST_DIR}/reports/"

rm -rf ${TEST_DIR}
mkdir ${TEST_DIR}
mkdir ${COVERAGE_DIR}

cat <<EOM > ${TEST_STATUS_FILE}
failure
EOM

cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'unit-tests' 'pending' 'running' ${BUILD_URL}
cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'coverage' 'pending' 'running' ${BUILD_URL}

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 0
/usr/bin/xcodebuild test -scheme UnitTests -derivedDataPath ${TEST_DIR} -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug -destination 'platform=iOS Simulator,name=iPhone SE,OS=10.0' GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit

mv test-reports $TEST_REPORTS_FOLDER
$(brew --prefix gcovr)/bin/gcovr --object-directory=${TEST_DIR}/Logs/Test/ --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${COVERAGE_DIR}/coverage.xml"

rm -rf ${TEST_STATUS_FILE}

cat <<EOM > ${TEST_STATUS_FILE}
success
EOM