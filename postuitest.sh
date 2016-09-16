: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
. $HOME/.nvm/nvm.sh
source "$HOME/.rvm/scripts/rvm"
alias cftool='node_modules/classfitter-tools/lib/index.js'

TEST_DIR="${WORKSPACE}/ClassfitteriOS/uitest"
TEST_REPORTS_FOLDER="${TEST_DIR}/reports"
COVERAGE_DIR="${TEST_DIR}/coverage"
TEST_STATUS_FILE="${TEST_DIR}/status.txt"
TEST_STATUS=`cat ${TEST_STATUS_FILE}`

if [[ $TEST_STATUS == 'success' ]]; then
    if [ ! -f ${TEST_REPORTS_FOLDER}/TEST-ClassfitteriOSUITests.xml ]
    then
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT}  ui-tests error 'no test results' ${BUILD_URL}
    else
    cftool setGitHubStatusFromTestResutsFile ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ${TEST_REPORTS_FOLDER}/TEST-ClassfitteriOSUITests.xml ui-tests ${BUILD_URL}
    fi
else
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} ui-tests 'error' 'error' ${BUILD_URL}
fi  