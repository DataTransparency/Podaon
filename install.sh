#!/bin/sh -xe

if [[ $LOCATION == "CI" ]]; then
    export PATH=/Users/buildservice/.rvm/gems/ruby-2.3.0/bin:/Users/buildservice/.rvm/gems/ruby-2.3.0@global/bin:/Users/buildservice/.rvm/rubies/ruby-2.3.0/bin:/Users/buildservice/.rvm/bin:/Users/buildservice/.nvm/versions/node/v6.5.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/go/bin
fi

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

rm -Rf Firebase/
mkdir Firebase
scp buildservice@192.168.5.25:FirebaseServiceAccount-beta.json Firebase/FirebaseServiceAccount-beta.json
scp buildservice@192.168.5.25:FirebaseServiceAccount-development.json Firebase/FirebaseServiceAccount-development.json
scp buildservice@192.168.5.25:FirebaseServiceAccount-production.json Firebase/FirebaseServiceAccount-production.json
scp buildservice@192.168.5.25:FirebaseServiceAccount-test.json Firebase/FirebaseServiceAccount-test.json

scp buildservice@192.168.5.25:GoogleService-Info-beta.plist Firebase/GoogleService-Info-beta.plist
scp buildservice@192.168.5.25:GoogleService-Info-production.plist Firebase/GoogleService-Info-production.plist
scp buildservice@192.168.5.25:GoogleService-Info-development.plist Firebase/GoogleService-Info-development.plist
scp buildservice@192.168.5.25:GoogleService-Info-test.plist Firebase/GoogleService-Info-test.plist


scp buildservice@192.168.5.25:FirebaseServiceAccount-development.json classfitterios/FirebaseServiceAccount.json
scp buildservice@192.168.5.25:GoogleService-Info-development.plist classfitterios/GoogleService-Info.plist