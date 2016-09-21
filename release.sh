#!/bin/sh -xe

: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${LOCATION:?There must be a LOCATION environment variable set}"
: "${ENVIRONMENT:?There must be a ENVIRONMENT environment variable set}"

. $HOME/.nvm/nvm.sh
source "$HOME/.rvm/scripts/rvm"

alias cftool='node_modules/classfitter-tools/lib/index.js'

DEPLOY_DIRECTORY="${WORKSPACE}/ClassfitteriOS/deploy"
PAYLOAD_FILE="${DEPLOY_DIRECTORY}/payload.json"
ARCHIVE_DIR="${DEPLOY_DIRECTORY}/archive"
EXPORT_DIR="${DEPLOY_DIRECTORY}/export"
EXPORT_CHECK_DIR="${DEPLOY_DIRECTORY}/export_check"
UPLOAD_DIR="${DEPLOY_DIRECTORY}/upload"
UPLOAD_CHECK_DIR="${DEPLOY_DIRECTORY}/upload_check"
VERSION_FILE="${DEPLOY_DIRECTORY}/version.txt"
FULL_VERSION_FILE="${DEPLOY_DIRECTORY}/fullversion.txt"
DEPLOY_STATUS_FILE="${DEPLOY_DIRECTORY}/status.txt"

rm -rf ${DEPLOY_DIRECTORY}
mkdir ${DEPLOY_DIRECTORY}
cat <<EOM > ${DEPLOY_STATUS_FILE}
failure
EOM


if [[ ${LOCATION} == 'CI' ]] && [[ ${ENVIRONMENT} == 'production' ]]; then
	echo "Using payload from GitHub"
	: "${payload:?There must be a payload environment variable set}"
else
	echo "Using dev payload"
	payload=`cat ${WORKSPACE}/deploymentPayload.json`
fi

if [[ ${ENVIRONMENT} == 'production' ]]; then
	echo "Replacing Firebase files with Production versions"
	FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Live.json
	FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Live.plist	
	GOOGLE_APP_ID=1:287953837448:ios:bc5a416402e93b61
else
	echo "Replacing Firebase files with Depelopment versions"
	FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Development.json
	FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Development.plist
	GOOGLE_APP_ID=1:1096116560042:ios:bc5a416402e93b61
fi

FIREBASE_SERVICE_FILE=${WORKSPACE}/ClassfitteriOS/FirebaseServiceAccount.json
FIREBASE_ANALYTICS_FILE=${WORKSPACE}/ClassfitteriOS/GoogleService-Info.plist
#FIREBASE CRASH
rm -rf FIREBASE_SERVICE_FILE
cp $FIREBASE_SYMBOL_SERVICE_JSON $FIREBASE_SERVICE_FILE
#FIREBASE ANALYTICS
rm -rf FIREBASE_ANALYTICS_FILE
cp $FIREBASE_ANALYTICS_PLIST $FIREBASE_ANALYTICS_FILE



#GETTING VERSION INFORMATION FROM payload
echo ${payload} > ${PAYLOAD_FILE}
VERSION_NUMBER=$(cftool getVersionFromPayload ${PAYLOAD_FILE})
echo "${VERSION_NUMBER}" > ${VERSION_FILE}
echo "v${VERSION_NUMBER}+${BUILD_NUMBER}" > ${FULL_VERSION_FILE}

if [[ ${LOCATION} == 'CI' ]] && [[ ${ENVIRONMENT} == 'production' ]]; then
#VERSION
	cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'pending' 'running' ${BUILD_URL}
else
	cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'dev-release' 'pending' 'running' ${BUILD_URL}
fi

cd ClassfitteriOS
agvtool new-marketing-version ${VERSION_NUMBER}
agvtool new-version -all ${BUILD_NUMBER}
cd ..

#ARCHIVE
mkdir ${ARCHIVE_DIR}
/usr/bin/xcodebuild -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Release -scheme ClassfitteriOS -archivePath ${ARCHIVE_DIR}/ClassfitteriOS archive GOOGLE_APP_ID=${GOOGLE_APP_ID}

#EXPORT
mkdir ${EXPORT_DIR}
cat <<EOM > ${EXPORT_DIR}/exportOptions.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>teamID</key>
        <string>TQYB6VJLUN</string>
        <key>method</key>
        <string>app-store</string>
        <key>uploadSymbols</key>
        <true/>
</dict>
</plist>
EOM

xcrun xcodebuild -exportArchive -exportOptionsPlist ${EXPORT_DIR}/exportOptions.plist -archivePath ${ARCHIVE_DIR}/ClassfitteriOS.xcarchive -exportPath ${EXPORT_DIR}

#CHECK EXPORT
IPA_FILE=${EXPORT_DIR}/ClassfitteriOS.ipa
unzip -q  ${IPA_FILE} -d ${EXPORT_CHECK_DIR}
xcrun codesign -dv ${EXPORT_CHECK_DIR}/Payload/Classfitter.app

#CREATE ITSMP
set -ex
IPA_FILENAME=$(basename $IPA_FILE)
MD5=$(md5 -q $IPA_FILE)
BYTESIZE=$(stat -f "%z" $IPA_FILE)

mkdir ${UPLOAD_DIR}
ITSMP_FILE=${UPLOAD_DIR}/mybundle.itmsp
mkdir ${ITSMP_FILE}

cat <<EOM > ${ITSMP_FILE}/metadata.xml
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://apple.com/itunes/importer" version="software5.1">
	<provider>$PROVIDER</provider>
	<team_id>$TEAMID</team_id>
	<software>
		<vendor_id>$VENDORID</vendor_id>
		<software_assets>
			<asset type="bundle">
				<data_file>
					<size>$BYTESIZE</size>
					<file_name>$IPA_FILENAME</file_name>
					<checksum type="md5">$MD5</checksum>
				</data_file>
			</asset>
		</software_assets>
	</software>
</package>
EOM
cp ${IPA_FILE} ${ITSMP_FILE}

#CHECK UPLOAD
mkdir ${UPLOAD_CHECK_DIR}
/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m lookupMetadata -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} -vendor_id ${VENDORID} -destination ${UPLOAD_CHECK_DIR}
/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m verify -f ${ITSMP_FILE} -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} -v detailed



if [[ ${LOCATION} == 'CI' ]]; then
	#UPLOAD
	/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m upload -f ${ITSMP_FILE} -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} --upload
	#CREATE GITHUB RELEASE AND TAG
	if [[ ${ENVIRONMENT} == 'production' ]]; then
		data='{"tag_name":"v'${VERSION_NUMBER}'+'${BUILD_NUMBER}'","name":"v'${VERSION_NUMBER}'+'${BUILD_NUMBER}'"}'
		curl -d $data -u $GITHUB_TOKEN:x-oauth-basic https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases
	fi
fi

rm -rf ${DEPLOY_STATUS_FILE}
cat <<EOM > ${DEPLOY_STATUS_FILE}
success
EOM
