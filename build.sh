BUILD_DIR="${WORKSPACE}/ClassfitteriOS/build"
ARCHIVE_DIR="${BUILD_DIR}/archive"
EXPORT_DIR="${BUILD_DIR}/export"
EXPORT_CHECK_DIR="${BUILD_DIR}/export_check"
UPLOAD_DIR="${BUILD_DIR}/upload"
UPLOAD_CHECK_DIR="${BUILD_DIR}/upload_check"
VERSION_FILE="${BUILD_DIR}/version.txt"
STATUS_FILE=${BUILD_DIR}/status.txt


rm -rf ${BUILD_DIR}
mkdir ${BUILD_DIR}
cat <<EOM > ${STATUS_FILE}
failure
EOM

cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'build' 'pending' 'running' ${BUILD_URL}
cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'ui-tests' 'pending' 'running' ${BUILD_URL}
cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'unit-tests' 'pending' 'running' ${BUILD_URL}
cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'coverage' 'pending' 'running' ${BUILD_URL}

cd ClassfitteriOS
agvtool new-version -all ${BUILD_NUMBER}
cd ..

#ARCHIVE
mkdir ${ARCHIVE_DIR}
cd ClassfitteriOS
/usr/bin/xcodebuild -target ClassfitteriOS -configuration Release -scheme ClassfitteriOS  -archivePath ${ARCHIVE_DIR}/ClassfitteriOS archive

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
        <string>ad-hoc</string>
        <key>uploadSymbols</key>
        <true/>
		<key>manifest</key>
		<dict>
			<key>appURL</key>
			<string>https://dev.datatransparency.com/jenkins/job/Classfitter/${BUILD_NUMBER}/artifact/ClassfitteriOS/build/export/ClassfitteriOS.ipa</string>
			<key>displayImageURL</key>
			<string>https://dev.datatransparency.com/jenkins/job/Classfitter/${BUILD_NUMBER}/artifact/ClassfitteriOS/build/export/icon57.png</string>
			<key>fullSizeImageURL</key>
			<string>https://dev.datatransparency.com/jenkins/job/Classfitter/${BUILD_NUMBER}/artifact/ClassfitteriOS/build/export/icon512.png</string>
		</dict>
</dict>
</plist>
EOM

xcrun xcodebuild -exportArchive -exportOptionsPlist ${EXPORT_DIR}/exportOptions.plist -archivePath ${ARCHIVE_DIR}/ClassfitteriOS.xcarchive -exportPath ${EXPORT_DIR}

cat <<EOM > ${EXPORT_DIR}/index.html
<a href="itms-services://?action=download-manifest&amp;url=https://dev.datatransparency.com/jenkins/job/Classfitter/${BUILD_NUMBER}/artifact/ClassfitteriOS/build/export/manifest.plist">click this link to install</a>
EOM


#CHECK EXPORT
IPA_FILE=${EXPORT_DIR}/ClassfitteriOS.ipa
unzip -q  ${IPA_FILE} -d ${EXPORT_CHECK_DIR}
xcrun codesign -dv ${EXPORT_CHECK_DIR}/Payload/Classfitter.app

cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'build' 'success' 'passing' ${BUILD_URL}

rm -rf ${STATUS_FILE}
cat <<EOM > ${BUILD_DIR}/status.txt
success
EOM