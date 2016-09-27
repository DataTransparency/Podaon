#!/bin/sh -xe

source scripts/environment-variables.sh

: "${FIREBASE_DIRECTORY_NAME:?There must be a FIREBASE_DIRECTORY_NAME environment variable set}"

PROJECT_DIR=ClassfitteriOS
rm -Rf ~/${FIREBASE_DIRECTORY_NAME}/
mkdir ~/${FIREBASE_DIRECTORY_NAME}
scp buildservice@192.168.5.25:${FIREBASE_DIRECTORY_NAME}/*.* ~/${FIREBASE_DIRECTORY_NAME}/