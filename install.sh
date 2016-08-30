: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
: "${FIREBASE_SYMBOL_SERVICE_JSON:?There must be a FIREBASE_SYMBOL_SERVICE_JSON environment variable set}"
: "${FIREBASE_ANALYTICS_PLIST:?There must be a FIREBASE_ANALYTICS_PLIST environment variable set}"

pod install --project-directory=ClassfitteriOS/

#FIREBASE CRASH
rm -rf ${FIREBASE_SERVICE_FILE}
cp $FIREBASE_SYMBOL_SERVICE_JSON ${WORKSPACE}/ClassfitteriOS/FirebaseServiceAccount.json

#FIREBASE ANALYTICS
rm -rf ${FIREBASE_ANALYTICS_FILE}
cp $FIREBASE_ANALYTICS_PLIST ${WORKSPACE}/ClassfitteriOS/GoogleService-Info.plist