#!/bin/sh -xe

: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${GIT_COMMIT:?There must be a GIT_COMMIT environment variable set}"
: "${BUILD_URL:?There must be a BUILD_URL environment variable set}"
: "${GITHUB_REPO:?There must be a GITHUB_REPO environment variable set}"
: "${GITHUB_OWNER:?There must be a GITHUB_OWNER environment variable set}"
: "${BUILD_NUMBER:?There must be a BUILD_NUMBER environment variable set}"
: "${GOOGLE_APP_ID:?There must be a GOOGLE_APP_ID environment variable set}"
. $(brew --prefix nvm)/nvm.sh
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH
alias cftool='node_modules/classfitter-tools/lib/index.js'

BUILD_DIR="${WORKSPACE}/ClassfitteriOS/build"
ARCHIVE_DIR="${BUILD_DIR}/archive"
EXPORT_DIR="${BUILD_DIR}/export"
EXPORT_CHECK_DIR="${BUILD_DIR}/export_check"
UPLOAD_DIR="${BUILD_DIR}/upload"
UPLOAD_CHECK_DIR="${BUILD_DIR}/upload_check"
VERSION_FILE="${BUILD_DIR}/version.txt"
BUILD_STATUS_FILE="${BUILD_DIR}/status.txt"

rm -rf ${BUILD_DIR}
mkdir ${BUILD_DIR}
cat <<EOM > ${BUILD_STATUS_FILE}
failure
EOM
cftool setGitHubStatus ${GITHUB_OWNER} ${GITHUB_REPO} ${GIT_COMMIT} 'build' 'pending' 'running' ${BUILD_URL}


FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Development.json
FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Development.plist
FIREBASE_SERVICE_FILE=${WORKSPACE}/ClassfitteriOS/FirebaseServiceAccount.json
FIREBASE_ANALYTICS_FILE=${WORKSPACE}/ClassfitteriOS/GoogleService-Info.plist
#FIREBASE CRASH
rm -rf FIREBASE_SERVICE_FILE
echo "cp ${FIREBASE_SYMBOL_SERVICE_JSON} ${FIREBASE_SERVICE_FILE}"
cp $FIREBASE_SYMBOL_SERVICE_JSON $FIREBASE_SERVICE_FILE
#FIREBASE ANALYTICS
echo "rm -rf ${FIREBASE_ANALYTICS_FILE}"
rm -rf $FIREBASE_ANALYTICS_FILE
cp $FIREBASE_ANALYTICS_PLIST $FIREBASE_ANALYTICS_FILE

GOOGLE_APP_ID=1:1096116560042:ios:bc5a416402e93b61


cd ClassfitteriOS
agvtool new-version -all ${BUILD_NUMBER}
cd ..

#ARCHIVE
mkdir ${ARCHIVE_DIR}
/usr/bin/xcodebuild -workspace ${WORKSPACE}/ClassfitteriOS/ClassfitteriOS.xcworkspace -configuration Release -scheme ClassfitteriOS  -archivePath ${ARCHIVE_DIR}/ClassfitteriOS archive GOOGLE_APP_ID=${GOOGLE_APP_ID}

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

echo "Exporting with command: xcodebuild -exportArchive -exportOptionsPlist ${EXPORT_DIR}/exportOptions.plist -archivePath ${ARCHIVE_DIR}/ClassfitteriOS.xcarchive -exportPath ${EXPORT_DIR} -exportProvisioningProfile ""21367793-6aea-488d-bccf-70ecaad1fefb"""
xcrun xcodebuild -exportArchive -exportOptionsPlist ${EXPORT_DIR}/exportOptions.plist -archivePath ${ARCHIVE_DIR}/ClassfitteriOS.xcarchive -exportPath ${EXPORT_DIR}

cat <<EOM > ${EXPORT_DIR}/index.html
<a href="itms-services://?action=download-manifest&amp;url=https://dev.datatransparency.com/jenkins/job/Classfitter/${BUILD_NUMBER}/artifact/ClassfitteriOS/build/export/manifest.plist">click this link to install</a>
EOM


#CHECK EXPORT
IPA_FILE=${EXPORT_DIR}/ClassfitteriOS.ipa
unzip -q  ${IPA_FILE} -d ${EXPORT_CHECK_DIR}
xcrun codesign -dv ${EXPORT_CHECK_DIR}/Payload/Classfitter.app

rm -rf ${BUILD_STATUS_FILE}
cat <<EOM > ${BUILD_DIR}/status.txt
success
EOM