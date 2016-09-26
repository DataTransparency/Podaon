#!/bin/sh -xe

source scripts/environment-variables.sh

: "${FIREBASE_SOURCE_DIRECTORY:?There must be a FIREBASE_SOURCE_DIRECTORY environment variable set}"
: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${XCODE_WORKSPACE_DIRECTORY_NAME:?There must be a XCODE_WORKSPACE_DIRECTORY_NAME environment variable set}"

PROJECT_DIR=ClassfitteriOS
rm -Rf ~/${FIREBASE_DIRECTORY_NAME}/
mkdir ~/${FIREBASE_DIRECTORY_NAME}
scp buildservice@192.168.5.25:${FIREBASE_DIRECTORY_NAME}/*.* ${FIREBASE_DIRECTORY_NAME}/


cp ~/${FIREBASE_DIRECTORY_NAME}/FirebaseServiceAccount-development.json ${WORKSPACE}/${XCODE_WORKSPACE_DIRECTORY_NAME}/FirebaseServiceAccount.json
cp ~/${FIREBASE_DIRECTORY_NAME}/GoogleService-Info-development.plist ${WORKSPACE}/${XCODE_WORKSPACE_DIRECTORY_NAME}/GoogleService-Info.plist