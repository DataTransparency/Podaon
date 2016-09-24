#!/bin/sh -xe

if [[ $LOCATION == "CI" ]]; then
    export PATH=/Users/buildservice/.rvm/gems/ruby-2.3.0/bin:/Users/buildservice/.rvm/gems/ruby-2.3.0@global/bin:/Users/buildservice/.rvm/rubies/ruby-2.3.0/bin:/Users/buildservice/.rvm/bin:/Users/buildservice/.nvm/versions/node/v6.5.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/go/bin
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

brew install gcovr
brew install tailor
nvm install
npm install

gem install bundler
bundle install
pod repo update
pod install --project-directory=ClassfitteriOS/

rm -rf env/
rm -rf bin/

rm -Rf ~/Library/MobileDevice/Provisioning\ Profiles/*.*
cp ./ProvisioningProfiles/*.* ~/Library/MobileDevice/Provisioning\ Profiles/

FIREBASE_DIR=Firebase
PROJECT_DIR=ClassfitteriOS
rm -Rf ${FIREBASE_DIR}/
mkdir ${FIREBASE_DIR}
scp buildservice@192.168.5.25:FirebaseServiceAccount-beta.json ${FIREBASE_DIR}/FirebaseServiceAccount-beta.json
scp buildservice@192.168.5.25:FirebaseServiceAccount-development.json ${FIREBASE_DIR}/FirebaseServiceAccount-development.json
scp buildservice@192.168.5.25:FirebaseServiceAccount-production.json ${FIREBASE_DIR}/FirebaseServiceAccount-production.json
scp buildservice@192.168.5.25:FirebaseServiceAccount-test.json ${FIREBASE_DIR}/FirebaseServiceAccount-test.json

scp buildservice@192.168.5.25:GoogleService-Info-beta.plist ${FIREBASE_DIR}/GoogleService-Info-beta.plist
scp buildservice@192.168.5.25:GoogleService-Info-production.plist ${FIREBASE_DIR}/GoogleService-Info-production.plist
scp buildservice@192.168.5.25:GoogleService-Info-development.plist ${FIREBASE_DIR}/GoogleService-Info-development.plist
scp buildservice@192.168.5.25:GoogleService-Info-test.plist ${FIREBASE_DIR}/GoogleService-Info-test.plist


cp ${FIREBASE_DIR}/FirebaseServiceAccount-development.json ${PROJECT_DIR}/FirebaseServiceAccount.json
cp ${FIREBASE_DIR}/GoogleService-Info-development.plist ${PROJECT_DIR}/GoogleService-Info.plist