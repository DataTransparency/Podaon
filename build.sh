#VERSION
echo "Getting version from payload:"
VERSION_NUMBER=$(cftool getVersionFromPayload ${PAYLOAD_FILE})
echo "${VERSION_NUMBER}" > version.txt
cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'pending' 'versioning: '${VERSION_NUMBER} ${BUILD_URL}
cd ClassfitteriOS
agvtool new-marketing-version ${VERSION_NUMBER}
agvtool new-version -all ${BUILD_NUMBER}
cd ..

#ARCHIVE
cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'pending' 'archiving' ${BUILD_URL}
cd ClassfitteriOS
rm -rf build
/usr/bin/xcodebuild -target ClassfitteriOS -configuration Release -scheme ClassfitteriOS  -archivePath build/artifacts/ClassfitteriOS archive

#EXPORT
cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'pending' 'exporting' ${BUILD_URL}
xcrun xcodebuild -exportArchive -exportOptionsPlist exportOptions.plist -archivePath build/artifacts/ClassfitteriOS.xcarchive -exportPath build/artifacts
cd build
unzip -q ClassfitteriOS.ipa
cd build
cd Payload
xcrun codesign -dv Classfitter.app
cd ..

#UPLOAD
cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'pending' 'bundling' ${BUILD_URL}
set -ex

ARTIFACTS="${WORKSPACE}/ClassfitteriOS/build/artifacts"
IPA_FILE="${ARTIFACTS}/*.ipa"
IPA_FILENAME=$(basename $IPA_FILE)
MD5=$(md5 -q $IPA_FILE)
BYTESIZE=$(stat -f "%z" $IPA_FILE)
TEMPDIR=itmsp

test -d ${TEMPDIR} && rm -rf ${TEMPDIR}
mkdir ${TEMPDIR}
mkdir ${TEMPDIR}/mybundle.itmsp
cat <<EOM > ${TEMPDIR}/mybundle.itmsp/metadata.xml
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
cp ${IPA_FILE} ${TEMPDIR}/mybundle.itmsp
ITMSP_FILE_PATH=${TEMPDIR}/mybundle.itmsp
cp -rf $ITMSP_FILE_PATH ${ARTIFACTS}/mybundle.itmsp
/Applications/Xcode-beta.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m lookupMetadata -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} -vendor_id ${VENDORID} -destination ${TEMPDIR}
/Applications/Xcode-beta.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m verify -f ${TEMPDIR} -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} -v detailed

echo "Setting status to pending with payload:"
cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'pending' 'uploading' ${BUILD_URL}
#/Applications/Xcode-beta.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m upload -f ${TEMPDIR} -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} --upload
echo "Setting status to success with payload:"
cftool setGitHubDeploymentStatusWithPayload ${PAYLOAD_FILE} 'success' 'deployed' ${BUILD_URL}