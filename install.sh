#!/bin/sh -xe
: "${ENVIRONMENT:?There must be a ENVIRONMENT environment variable set}"
: "${LOCATION:?There must be a LOCATION environment variable set}"

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