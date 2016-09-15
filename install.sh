: "${WORKSPACE:?There must be a WORKSPACE environment variable set}"
#git clean -d -x -f

export GEM_HOME=$HOME/.gem
#!/bin/sh -xe

export PATH=$GEM_HOME/bin:$PATH
. $(brew --prefix nvm)/nvm.sh
brew install gcovr
brew install tailor
nvm install
npm install

alias cftool='node_modules/classfitter-tools/lib/index.js'
gem install bundler
bundle install
pod repo update
pod install --project-directory=ClassfitteriOS/
echo $NODE_ENV

if [[ $LOCATION == "CI" ]]; then
    npm install cftool
else

FIREBASE_SYMBOL_SERVICE_JSON=${HOME}/FirebaseCrash-Development.json
FIREBASE_ANALYTICS_PLIST=${HOME}/GoogleService-Info-Development.plist
FIREBASE_SERVICE_FILE=${WORKSPACE}/ClassfitteriOS/FirebaseServiceAccount.json
FIREBASE_ANALYTICS_FILE=${WORKSPACE}/ClassfitteriOS/GoogleService-Info.plist
#FIREBASE CRASH
rm -rf FIREBASE_SERVICE_FILE
cp $FIREBASE_SYMBOL_SERVICE_JSON $FIREBASE_SERVICE_FILE
#FIREBASE ANALYTICS
rm -rf FIREBASE_ANALYTICS_FILE
cp $FIREBASE_ANALYTICS_PLIST $FIREBASE_ANALYTICS_FILE