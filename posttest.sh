: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"

TEST_DIR="${WORKSPACE}/ClassfitteriOS/test"
COVERAGE_DIR="${TEST_DIR}/coverage"
TEST_STATUS_FILE="${TEST_DIR}/status.txt"

TEST_STATUS=`cat ${TEST_STATUS_FILE}`

if [[ $ENVIRONMENT == 'CI' ]]; then
    if [[$TEST_STATUS == 'success']]; then
        if [ ! -f ${WORKSPACE}/ClassfitteriOS/test-reports/TEST-ClassfitteriOSTests.xml ]
        then
        cftool setGitHubStatus classfitter ${GITHUB_OWNER} ${GIT_COMMIT}  unit-tests error 'no test results' ${BUILD_URL}
        else
        cftool setGitHubStatusFromTestResutsFile ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ${WORKSPACE}/ClassfitteriOS/test-reports/TEST-ClassfitteriOSTests.xml unit-tests ${BUILD_URL}
        fi
        if [ ! -f ${WORKSPACE}/ClassfitteriOS/test-reports/TEST-ClassfitteriOSUITests.xml ]
        then
        cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT}  ui-tests error 'no test results' ${BUILD_URL}
        else
        cftool setGitHubStatusFromTestResutsFile ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ${WORKSPACE}/ClassfitteriOS/test-reports/TEST-ClassfitteriOSUITests.xml ui-tests ${BUILD_URL}
        fi
        if [ ! -f ${COVERAGE_DIR}/coverage.xml ]
        then
        cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} coverage 'error' 'no coverage found' ${BUILD_URL}
        else
        cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} coverage 'success' '0%' ${BUILD_URL}
        fi
    else
        cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} unit-tests 'error' 'error' ${BUILD_URL}
        cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} tests 'error' 'error' ${BUILD_URL}
        cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} coverage 'error' 'error' ${BUILD_URL}
    fi  
fi