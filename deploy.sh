: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"

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

#GETTING VERSION INFORMATION FROM payload
echo ${payload} > ${PAYLOAD_FILE}
VERSION_NUMBER=$(cftool getVersionFromPayload ${PAYLOAD_FILE})
echo "${VERSION_NUMBER}" > ${VERSION_FILE}
echo "v${VERSION_NUMBER}+${BUILD_NUMBER}" > ${FULL_VERSION_FILE}

#VERSION
cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'pending' 'running' ${BUILD_URL}

cd ClassfitteriOS
agvtool new-marketing-version ${VERSION_NUMBER}
agvtool new-version -all ${BUILD_NUMBER}
cd ..

#ARCHIVE
mkdir ${ARCHIVE_DIR}
/usr/bin/xcodebuild -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Release -scheme ClassfitteriOS GOOGLE_APP_ID=${GOOGLE_APP_ID} -archivePath ${ARCHIVE_DIR}/ClassfitteriOS archive

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
/Applications/Xcode-beta.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m lookupMetadata -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} -vendor_id ${VENDORID} -destination ${UPLOAD_CHECK_DIR}
/Applications/Xcode-beta.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m verify -f ${ITSMP_FILE} -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} -v detailed


if [[ ${NODE_ENV} == 'production' ]]; then
	#UPLOAD
	/Applications/Xcode-beta.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m upload -f ${ITSMP_FILE} -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} --upload
	#CREATE GITHUB RELEASE AND TAG
	curl -d '{"tag_name":"v${VERSION_NUMBER}+${BUILD_NUMBER}","name":"v${VERSION_NUMBER}+${BUILD_NUMBER}"}' -u $GITHUB_TOKEN:x-oauth-basic https://api.github.com/repos/classfitter/classfitter/releases
else
	echo "would have deployed and released"
fi

rm -rf ${DEPLOY_STATUS_FILE}
cat <<EOM > ${DEPLOY_STATUS_FILE}
success
EOM

