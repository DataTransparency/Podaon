touch ~/.bash_profile
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
\curl -sSL https://get.rvm.io | bash -s stable --ruby

defaults write com.apple.finder AppleShowAllFiles YES

sudo chgrp -R admin /usr/local
sudo chmod -R g+w /usr/local

scp buildservice@192.168.5.25:.ssh/id_rsa ~/.ssh/id_rsa
scp buildservice@192.168.5.25:.ssh/id_rsa.pub ~/.ssh/id_rsa.pub
eval `ssh-agent -s`
sudo ssh-add ~/.ssh/id_rsa
sudo scp buildservice@192.168.5.25:.ssh/authorized_keys ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys


# Disable password login for jenkins user
Match User jenkins  
PasswordAuthentication no

sudo vim /etc/ssh/sshd_config

sudo /etc/init.d/ssh restart

sh scripts/firebase.sh

brew install gcovr
brew install tailor