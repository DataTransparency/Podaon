#!/bin/sh -xe

: "${VERSION_NUMBER:?There must be a VERSION_NUMBER environment variable set}"
: "${BUILD_NUMBER:?There must be a BUILD_NUMBER environment variable set}"
: "${ARCHIVE_DIR:?There must be a ARCHIVE_DIR environment variable set}"
: "${XCODE_WORKSPACE_FILE:?There must be a XCODE_WORKSPACE_FILE environment variable set}"
: "${BUILD_SCHEME:?There must be a BUILD_SCHEME environment variable set}"
: "${ARCHIVE_FILE_NAME:?There must be a ARCHIVE_FILE_NAME environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"

cd ClassfitteriOS
agvtool new-marketing-version ${VERSION_NUMBER}
agvtool new-version -all ${BUILD_NUMBER}
cd ..

#ARCHIVE
mkdir ${ARCHIVE_DIR}
/usr/bin/xcodebuild -workspace ${XCODE_WORKSPACE_FILE} -configuration Release -scheme ${BUILD_SCHEME} -archivePath ${ARCHIVE_DIR}/${ARCHIVE_FILE_NAME} archive GOOGLE_APP_ID=${GOOGLE_APP_ID}