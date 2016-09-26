#!/bin/sh -xe

echo "Installing..."
if [[ $LOCATION == "CI" ]]; then
    export PATH=/Users/buildservice/.rvm/gems/ruby-2.3.0/bin:/Users/buildservice/.rvm/gems/ruby-2.3.0@global/bin:/Users/buildservice/.rvm/rubies/ruby-2.3.0/bin:/Users/buildservice/.rvm/bin:/Users/buildservice/.nvm/versions/node/v6.5.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/go/bin
else
    export WORKSPACE=$PWD
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

cp ~/${FIREBASE_DIRECTORY_NAME}/FirebaseServiceAccount-development.json ${WORKSPACE}/${XCODE_WORKSPACE_DIRECTORY_NAME}/FirebaseServiceAccount.json
cp ~/${FIREBASE_DIRECTORY_NAME}/GoogleService-Info-development.plist ${WORKSPACE}/${XCODE_WORKSPACE_DIRECTORY_NAME}/GoogleService-Info.plist

nvm install
npm install

gem install bundler
bundle install
pod repo update
pod install --project-directory=ClassfitteriOS/

rm -rf env/
rm -rf bin/

rm -Rf ~/Library/MobileDevice/Provisioning\ Profiles/*.*
cp ${WORKSPACE}/ProvisioningProfiles/*.* ~/Library/MobileDevice/Provisioning\ Profiles/