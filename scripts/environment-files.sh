#!/bin/sh -xe

: "${FULL_VERSION_FILE:?There must be a FULL_VERSION_FILE environment variable set}"
: "${VERSION_FILE:?There must be a VERSION_FILE environment variable set}"
: "${PAYLOAD_FILE:?There must be a PAYLOAD_FILE environment variable set}"
: "${payload:?There must be a payload environment variable set}"
: "${FIREBASE_SERVICE_FILE:?There must be a FIREBASE_SERVICE_FILE environment variable set}"
: "${FIREBASE_SYMBOL_SERVICE_JSON:?There must be a FIREBASE_SYMBOL_SERVICE_JSON environment variable set}"
: "${FIREBASE_ANALYTICS_FILE:?There must be a FIREBASE_ANALYTICS_FILE environment variable set}"
: "${FIREBASE_ANALYTICS_PLIST:?There must be a FIREBASE_ANALYTICS_PLIST environment variable set}"
: "${ENVIRONMENT_DIRECTORY:?There must be a ENVIRONMENT_DIRECTORY environment variable set}"
: "${BIN_DIRECTORY:?There must be a BIN_DIRECTORY environment variable set}"
: "${PROVISIONING_PROFILE_NAME:?There must be a PROVISIONING_PROFILE_NAME environment variable set}"
: "${XCODE_PROJECT_FILE_PBXPROJ:?There must be a XCODE_PROJECT_FILE_PBXPROJ environment variable set}"
: "${BUNDLE_IDENTIFIER_BASE:?There must be a BUNDLE_IDENTIFIER_BASE environment variable set}"

. $HOME/.nvm/nvm.sh
source "$HOME/.rvm/scripts/rvm"
alias cftool="${WORKSPACE}/node_modules/classfitter-tools/lib/index.js"

mkdir -p $ENVIRONMENT_DIRECTORY
rm -rf $BIN_DIRECTORY
mkdir -p $BIN_DIRECTORY
rsync -av --progress * $ENVIRONMENT_DIRECTORY/ --exclude 'bin' --exclude 'env' --exclude 'scripts' --exclude 'ProvisioningProfiles' --delete

#GETTING VERSION INFORMATION FROM payload
touch $PAYLOAD_FILE
echo ${payload} > ${PAYLOAD_FILE}

if [[ ${COMMAND} == 'deploy' && ${LOCATION} == 'CI' && ${ENVIRONMENT} == 'production' ]]; then
    VERSION_NUMBER=$(cftool getVersionFromPayload ${PAYLOAD_FILE})
else
    if [[ $COMMAND == 'deploy' ]]; then
        VERSION_NUMBER=0.0.1
    else
        VERSION_NUMBER=0.0.0
    fi
fi

export VERSION_NUMBER
echo "${VERSION_NUMBER}" > ${VERSION_FILE}
echo "v${VERSION_NUMBER}+${BUILD_NUMBER}" > ${FULL_VERSION_FILE}

#FIREBASE CRASH
rm -rf FIREBASE_SERVICE_FILE
echo "cp ${FIREBASE_SYMBOL_SERVICE_JSON} ${FIREBASE_SERVICE_FILE}"
cp $FIREBASE_SYMBOL_SERVICE_JSON $FIREBASE_SERVICE_FILE
#FIREBASE ANALYTICS
echo "rm -rf ${FIREBASE_ANALYTICS_FILE}"
rm -rf $FIREBASE_ANALYTICS_FILE
cp $FIREBASE_ANALYTICS_PLIST $FIREBASE_ANALYTICS_FILE

/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${DISPLAY_NAME}" ${IOS_APP_DIRECTORY}/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${BUNDLE_IDENTIFIER}" ${IOS_APP_DIRECTORY}/Info.plist

perl -i -pe "s/development-release/${ENVIRONMENT}-release/g" ${XCODE_PROJECT_FILE_PBXPROJ}
perl -i -pe "s/development-debug/${ENVIRONMENT}-debug/g" ${XCODE_PROJECT_FILE_PBXPROJ}
perl -i -pe "s/${BUNDLE_IDENTIFIER_BASE}-development/${BUNDLE_IDENTIFIER}/g" ${XCODE_PROJECT_FILE_PBXPROJ}

cd $XCODE_WORKSPACE_DIRECTORY
agvtool new-marketing-version ${VERSION_NUMBER}
agvtool new-version -all ${BUILD_NUMBER}
cd $WORKSPACE
