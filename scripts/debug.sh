#!/bin/sh -xe

: "${VERSION_NUMBER:?There must be a VERSION_NUMBER environment variable set}"
: "${BUILD_NUMBER:?There must be a BUILD_NUMBER environment variable set}"
: "${COMPILE_TYPE:?There must be a COMPILE_TYPE environment variable set}"
: "${XCODE_WORKSPACE_FILE:?There must be a XCODE_WORKSPACE_FILE environment variable set}"
: "${BUILD_SCHEME:?There must be a BUILD_SCHEME environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
: "${BIN_DIRECTORY:?There must be a BIN_DIRECTORY environment variable set}"

defaults write com.apple.iphonesimulator ConnectHardwareKeyboard 1

/usr/bin/xcodebuild -workspace ${XCODE_WORKSPACE_FILE} -derivedDataPath ${BIN_DIRECTORY} -configuration Debug -scheme ${BUILD_SCHEME} clean build GOOGLE_APP_ID=${GOOGLE_APP_ID}
node_modules/ios-deploy/build/release/ios-deploy --debug --bundle ${BIN_DIRECTORY}/build/products/debug-iphoneos/classfitter.app