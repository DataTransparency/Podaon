: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"

pod install --project-directory=ClassfitteriOS/

if [[ NODE_ENV == "production" ]]; then
    FIREBASE_SYMBOL_SERVICE_JSON=~/FirebaseCrash-Live.json
    FIREBASE_ANALYTICS_PLIST=~/GoogleService-Info-Live.plist
else
    FIREBASE_SYMBOL_SERVICE_JSON=~/FirebaseCrash-Development.json
    FIREBASE_ANALYTICS_PLIST=~/GoogleService-Info-Development.plist
fi

#FIREBASE CRASH
rm -rf ${FIREBASE_SERVICE_FILE}
cp $FIREBASE_SYMBOL_SERVICE_JSON ${WORKSPACE}/ClassfitteriOS/FirebaseServiceAccount.json

#FIREBASE ANALYTICS
rm -rf ${FIREBASE_ANALYTICS_FILE}
cp $FIREBASE_ANALYTICS_PLIST ${WORKSPACE}/ClassfitteriOS/GoogleService-Info.plist