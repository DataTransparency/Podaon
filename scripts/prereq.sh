touch ~/.bash_profile
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
\curl -sSL https://get.rvm.io | bash -s stable --ruby

chgrp -R admin /usr/local
chmod -R g+w /usr/local