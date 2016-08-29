BUILD_DIR="${WORKSPACE}/ClassfitteriOS/build"
ARCHIVE_DIR="${BUILD_DIR}/archive"
EXPORT_DIR="${BUILD_DIR}/export"
EXPORT_CHECK_DIR="${BUILD_DIR}/export_check"
UPLOAD_DIR="${BUILD_DIR}/upload"
UPLOAD_CHECK_DIR="${BUILD_DIR}/upload_check"
VERSION_FILE="${BUILD_DIR}/version.txt"
STATUS_FILE=${BUILD_DIR}/status.txt

pod install --project-directory=ClassfitteriOS/

#FIREBASE CRASH
: "${FIREBASE_SYMBOL_SERVICE_JSON:?There must be a FIREBASE_SYMBOL_SERVICE_JSON environment variable set}"
rm -rf ${FIREBASE_SERVICE_FILE}
cp $FIREBASE_SYMBOL_SERVICE_JSON ${WORKSPACE}/ClassfitteriOS/FirebaseServiceAccount.json

#FIREBASE ANALYTICS
: "${FIREBASE_ANALYTICS_PLIST:?There must be a FIREBASE_ANALYTICS_PLIST environment variable set}"
rm -rf ${FIREBASE_ANALYTICS_FILE}
cp $FIREBASE_ANALYTICS_PLIST ${WORKSPACE}/ClassfitteriOS/GoogleService-Info.plist