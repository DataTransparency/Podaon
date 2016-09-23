#!/bin/sh -xe

: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${LOCATION:?There must be a LOCATION environment variable set}"
: "${ENVIRONMENT:?There must be a ENVIRONMENT environment variable set}"
: "${ENVIRONMENT_DIRECTORY:?There must be a ENVIRONMENT_DIRECTORY environment variable set}"
: "${VENDOR_ID:?There must be a VENDOR_ID environment variable set}"
: "${ARCHIVE_FILE_NAME:?There must be a ARCHIVE_FILE_NAME environment variable set}"
: "${ARCHIVE_DIR:?There must be a ARCHIVE_DIR environment variable set}"



cd ClassfitteriOS
agvtool new-marketing-version ${VERSION_NUMBER}
agvtool new-version -all ${BUILD_NUMBER}
cd ..

#ARCHIVE
mkdir ${ARCHIVE_DIR}
/usr/bin/xcodebuild -workspace ${XCODE_WORKSPACE_FILE} -configuration Release -scheme ${BUILD_SCHEME} -archivePath ${ARCHIVE_DIR}/${ARCHIVE_FILE_NAME} archive GOOGLE_APP_ID=${GOOGLE_APP_ID} PRODUCT_BUNDLE_IDENTIFIER=${BUNDLE_IDENTIFIER} PROVISIONING_PROFILE_SPECIFIER=${PROVISIONING_PROFILE_FILENAME}