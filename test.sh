BUILD_DIR="${WORKSPACE}/ClassfitteriOS/build"
ARCHIVE_DIR="${BUILD_DIR}/archive"
EXPORT_DIR="${BUILD_DIR}/export"
EXPORT_CHECK_DIR="${BUILD_DIR}/export_check"
UPLOAD_DIR="${BUILD_DIR}/upload"
UPLOAD_CHECK_DIR="${BUILD_DIR}/upload_check"
VERSION_FILE="${BUILD_DIR}/version.txt"
STATUS_FILE=${BUILD_DIR}/status.txt


/usr/bin/xcodebuild -scheme ClassfitteriOS -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Debug build test -destination "platform=iOS Simulator,name=iPhone 6,OS=9.3" -enableCodeCoverage YES -IDECustomDerivedDataLocation=${BUILD_DIR}/build_ccov


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
# generate gcovr+cobertura report
/usr/local/bin/gcovr --object-directory="${BUILD_DIR}/build_ccov/ClassfitteriOS-empfmnxgxdnzlbbyrdpbmibjjmyn/Logs/Test/" --root=. --xml-pretty --gcov-exclude='.*#(?:ConnectSDKTests|Frameworks)#.*' --print-summary --output="${BUILD_DIR}/coverage.xml"