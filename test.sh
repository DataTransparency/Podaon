: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"

TEST_DIR="${WORKSPACE}/ClassfitteriOS/test"
COVERAGE_DIR="${TEST_DIR}/coverage"
TEST_STATUS_FILE="${TEST_DIR}/status.txt"
export TEST_REPORTS_FOLDER=${TEST_DIR}/reports

rm -rf ${TEST_DIR}
mkdir ${TEST_DIR}
mkdir ${COVERAGE_DIR}

cat <<EOM > ${TEST_STATUS_FILE}
failure
EOM

cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'ui-tests' 'pending' 'running' ${BUILD_URL}
cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'unit-tests' 'pending' 'running' ${BUILD_URL}
cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'coverage' 'pending' 'running' ${BUILD_URL}

export TEST_REPORTS_FOLDER=${TEST_DIR}/reports
/usr/bin/xcodebuild build test -scheme ClassfitteriOS -derivedDataPath ${TEST_DIR} -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug -destination "platform=iOS Simulator,name=iPhone 6,OS=9.3" -destination "platform=iOS Simulator,name=iPhone 6 plus,OS=9.3" -destination "platform=iOS Simulator,name=iPhone 6,OS=10.0" -destination "platform=iOS Simulator,name=iPhone 6 plus,OS=10.0" -destination "platform=iOS Simulator,name=iPad Pro,OS=9.3"  -enableCodeCoverage YES | ocunit2junit

# generate gcovr+cobertura report
/usr/local/bin/gcovr --object-directory=${TEST_DIR}/Logs/Test/ --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${COVERAGE_DIR}/coverage.xml"

rm -rf ${TEST_STATUS_FILE}
cat <<EOM > ${TEST_STATUS_FILE}
success
EOM