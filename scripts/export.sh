#!/bin/sh -xe

sh scripts/archive.sh

: "${EXPORT_DIR:?There must be a EXPORT_DIR environment variable set}"
: "${ARCHIVE_DIR:?There must be a ARCHIVE_DIR environment variable set}"
: "${ARCHIVE_FILE_NAME:?There must be a ARCHIVE_FILE_NAME environment variable set}"
: "${IPA_FILE:?There must be a IPA_FILE environment variable set}"
: "${EXPORT_CHECK_DIR:?There must be a EXPORT_CHECK_DIR environment variable set}"
: "${UPLOAD_DIR:?There must be a UPLOAD_DIR environment variable set}"
: "${ITSMP_FILE:?There must be a ITSMP_FILE environment variable set}"
: "${ITUNES_USERNAME:?There must be a ITUNES_USERNAME environment variable set}"
: "${ITUNES_PASSWORD:?There must be a ITUNES_PASSWORD environment variable set}"
: "${VENDOR_ID:?There must be a VENDOR_ID environment variable set}"

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

xcrun xcodebuild -exportArchive -exportOptionsPlist ${EXPORT_DIR}/exportOptions.plist -archivePath ${ARCHIVE_DIR}/${ARCHIVE_FILE_NAME}.xcarchive -exportPath ${EXPORT_DIR}

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
mkdir ${ITSMP_FILE}

cat <<EOM > ${ITSMP_FILE}/metadata.xml
<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://apple.com/itunes/importer" version="software5.1">
	<provider>$PROVIDER</provider>
	<team_id>$TEAMID</team_id>
	<software>
		<vendor_id>$VENDOR_ID</vendor_id>
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
/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m lookupMetadata -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} -vendor_id ${VENDOR_ID} -destination ${UPLOAD_CHECK_DIR}
/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/itms/bin/iTMSTransporter -m verify -f ${ITSMP_FILE} -u ${ITUNES_USERNAME} -p ${ITUNES_PASSWORD} -v detailed
