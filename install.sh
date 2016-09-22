#!/bin/sh -xe
: "${ENVIRONMENT:?There must be a ENVIRONMENT environment variable set}"
: "${LOCATION:?There must be a LOCATION environment variable set}"

echo "The ENVIRONMENT is ${ENVIRONMENT}"
echo "The LOCATION is ${LOCATION}"

APPLEID=1132280754
VENDORID=ClassfitteriOS
TEAMID=TQYB6VJLUN
PROVIDER=JamesWOOD1426797195
GITHUB_REPO=classfitter
GITHUB_OWNER=classfitter

if [[ $LOCATION == "CI" ]]; then
    npm install cftool
    export NODE_ENV=production
    export PATH=/Users/buildservice/.rvm/gems/ruby-2.3.0/bin:/Users/buildservice/.rvm/gems/ruby-2.3.0@global/bin:/Users/buildservice/.rvm/rubies/ruby-2.3.0/bin:/Users/buildservice/.rvm/bin:/Users/buildservice/.nvm/versions/node/v6.5.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/go/bin
else
    WORKSPACE=$PWD
    
    export NODE_ENV=development
    export BUILD_URL=http://www.fakeurl.com
    export BUILD_NUMBER=0
    export GIT_COMMIT=efdbd257dd5aa178ebcdfc265db22997d781654e
fi

echo "The WORKSPACE is ${WORKSPACE}"

. $HOME/.nvm/nvm.sh
source "$HOME/.rvm/scripts/rvm"

brew install gcovr
brew install tailor
nvm install
npm install

alias cftool='node_modules/classfitter-tools/lib/index.js'
gem install bundler
bundle install
pod repo update
pod install --project-directory=ClassfitteriOS/

if [[ $LOCATION == "CI" ]]; then
    npm install cftool
fi

: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"

FIREBASE_SERVICE_FILE=${WORKSPACE}/ClassfitteriOS/FirebaseServiceAccount.json
FIREBASE_ANALYTICS_FILE=${WORKSPACE}/ClassfitteriOS/GoogleService-Info.plist

if [[ ${ENVIRONMENT} == 'production' ]] || [[ ${ENVIRONMENT} == 'beta' ]]; then
    echo "Replacing Firebase files with Production versions"
    FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Live.json
    FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Live.plist	
    export GOOGLE_APP_ID=1:287953837448:ios:bc5a416402e93b61
else
    echo "Replacing Firebase files with Development versions"
    FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Development.json
    FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Development.plist
    export GOOGLE_APP_ID=1:1096116560042:ios:bc5a416402e93b61
fi

#FIREBASE CRASH
rm -rf FIREBASE_SERVICE_FILE
echo "cp ${FIREBASE_SYMBOL_SERVICE_JSON} ${FIREBASE_SERVICE_FILE}"
cp $FIREBASE_SYMBOL_SERVICE_JSON $FIREBASE_SERVICE_FILE
#FIREBASE ANALYTICS
echo "rm -rf ${FIREBASE_ANALYTICS_FILE}"
rm -rf $FIREBASE_ANALYTICS_FILE
cp $FIREBASE_ANALYTICS_PLIST $FIREBASE_ANALYTICS_FILE