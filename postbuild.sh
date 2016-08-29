BUILD_DIR="${WORKSPACE}/ClassfitteriOS/build"
ARCHIVE_DIR="${BUILD_DIR}/archive"
EXPORT_DIR="${BUILD_DIR}/export"
EXPORT_CHECK_DIR="${BUILD_DIR}/export_check"
UPLOAD_DIR="${BUILD_DIR}/upload"
UPLOAD_CHECK_DIR="${BUILD_DIR}/upload_check"
VERSION_FILE="${BUILD_DIR}/version.txt"
BUILD_STATUS_FILE=${BUILD_DIR}/status.txt
TEST_DIR="${WORKSPACE}/ClassfitteriOS/test"
COVERAGE_DIR="${TEST_DIR}/coverage"
TEST_STATUS_FILE=${TEST_DIR}/status.txt


if [[ $ENVIRONMENT == 'build' ]]; then
    if [ ! -f ${BUILD_DIR}/classfitterios/test/coverage/coverage.xml ]
    then
    cftool setGitHubStatus 'classfitter' 'classfitter' ${GIT_COMMIT} 'coverage' 'error' 'no coverage found' ${BUILD_URL}
    else
    cftool setGitHubStatus 'classfitter' 'classfitter' ${GIT_COMMIT} 'coverage' 'success' '0%' ${BUILD_URL}
    fi
fi