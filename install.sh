: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"

brew install gcovr
gem install ocunit2junit
pod install --project-directory=ClassfitteriOS/

if [[ NODE_ENV == "production" ]]; then
    FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Live.json
    FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Live.plist
else
    FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Development.json
    FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Development.plist
fi

FIREBASE_SERVICE_FILE=${WORKSPACE}/ClassfitteriOS/FirebaseServiceAccount.json
FIREBASE_ANALYTICS_FILE=${WORKSPACE}/ClassfitteriOS/GoogleService-Info.plist
echo $FIREBASE_SYMBOL_SERVICE_JSON
echo $FIREBASE_SERVICE_FILE
#FIREBASE CRASH
rm -rf FIREBASE_SERVICE_FILE
cp $FIREBASE_SYMBOL_SERVICE_JSON $FIREBASE_SERVICE_FILE

#FIREBASE ANALYTICS
rm -rf FIREBASE_ANALYTICS_FILE
cp $FIREBASE_ANALYTICS_PLIST $FIREBASE_ANALYTICS_FILE