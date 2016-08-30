TEST_DIR="${WORKSPACE}/ClassfitteriOS/test"
COVERAGE_DIR="${TEST_DIR}/coverage"
TEST_STATUS_FILE="${TEST_DIR}/status.txt"

rm -rf ${TEST_DIR}
mkdir ${TEST_DIR}
cat <<EOM > ${TEST_STATUS_FILE}
failure
EOM

if [[ $ENVIRONMENT == 'build' ]]; then
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'ui-tests' 'pending' 'running' ${BUILD_URL}
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'unit-tests' 'pending' 'running' ${BUILD_URL}
    cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'coverage' 'pending' 'running' ${BUILD_URL}
fi

/usr/bin/xcodebuild -scheme ClassfitteriOS -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug build test -destination "platform=iOS Simulator,name=iPhone 6,OS=9.3" -enableCodeCoverage YES -IDECustomDerivedDataLocation=${TEST_DIR}

if [[ $ENVIRONMENT == 'build' ]]; then
    if [ ! -f ${WORKSPACE}/ClassfitteriOS/test-reports/TEST-ClassfitteriOSTests.xml ]
    then
    cftool setGitHubStatus classfitter classfitter ${GIT_COMMIT}  unit-tests error 'no test results' ${BUILD_URL}
    else
    cftool setGitHubStatusFromTestResutsFile classfitter classfitter ${GIT_COMMIT} ${WORKSPACE}/ClassfitteriOS/test-reports/TEST-ClassfitteriOSTests.xml unit-tests ${BUILD_URL}
    fi
    if [ ! -f ${WORKSPACE}/ClassfitteriOS/test-reports/TEST-ClassfitteriOSUITests.xml ]
    then
    cftool setGitHubStatus classfitter classfitter ${GIT_COMMIT}  ui-tests error 'no test results' ${BUILD_URL}
    else
    cftool setGitHubStatusFromTestResutsFile classfitter classfitter ${GIT_COMMIT} ${WORKSPACE}/ClassfitteriOS/test-reports/TEST-ClassfitteriOSUITests.xml ui-tests ${BUILD_URL}
    fi
fi

cp -r ${TEST_DIR}/**/Logs/Test/ ${COVERAGE_DIR}
# generate gcovr+cobertura report
/usr/local/bin/gcovr --object-directory=${COVERAGE_DIR} --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${TEST_DIR}/coverage.xml"

rm -rf ${TEST_STATUS_FILE}
cat <<EOM > ${TEST_STATUS_FILE}
success
EOM