#!/bin/sh -xe

sh scripts/export.sh

: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${LOCATION:?There must be a LOCATION environment variable set}"
: "${ENVIRONMENT:?There must be a ENVIRONMENT environment variable set}"
: "${ENVIRONMENT_DIRECTORY:?There must be a ENVIRONMENT_DIRECTORY environment variable set}"
: "${ITSMP_FILE:?There must be a ITSMP_FILE environment variable set}"
: "${ITUNES_USERNAME:?There must be a ITUNES_USERNAME environment variable set}"
: "${ITUNES_PASSWORD:?There must be a ITUNES_PASSWORD environment variable set}"


if [[ ${LOCATION} == 'CI' ]] || [[ ${ENVIRONMENT} == 'development' ]]; then
	#UPLOAD
	/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m upload -f ${ITSMP_FILE} -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} --upload
	#CREATE GITHUB RELEASE AND TAG
	if [[ ${ENVIRONMENT} == 'production' ]]; then
		data='{"tag_name":"v'${VERSION_NUMBER}'+'${BUILD_NUMBER}'","name":"v'${VERSION_NUMBER}'+'${BUILD_NUMBER}'"}'
		curl -d $data -u $GITHUB_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases
	fi
else
	echo 'Only development builds can be uploaded from locations other than CI'
	exit 1
fi
