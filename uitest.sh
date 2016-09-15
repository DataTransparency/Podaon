#!/bin/sh -xe
sh install.sh

: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
. $(brew --prefix nvm)/nvm.sh
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

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

if [[ $LOCATION == "CI" ]]; then
/usr/bin/xcodebuild test -scheme UITests -derivedDataPath ${TEST_DIR} -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug -destination 'platform=iOS,name=iPadMiniRetina' GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit
else
/usr/bin/xcodebuild test -scheme UITests -derivedDataPath ${TEST_DIR} -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug -destination 'platform=iOS,name=iPhone6' GOOGLE_APP_ID=${GOOGLE_APP_ID} -enableCodeCoverage YES | ocunit2junit
fi
mv test-reports $TEST_REPORTS_FOLDER
rm -rf ${TEST_STATUS_FILE}
cat <<EOM > ${TEST_STATUS_FILE}
success
EOM
