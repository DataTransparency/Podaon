#!/bin/sh -xe

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
