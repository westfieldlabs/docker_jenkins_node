#/bin/bash

#isntall RVM
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /usr/local/rvm/scripts/rvm
#Add jenkins to sudoers
echo 'jenkins ALL=(ALL:ALL) ALL' >> /etc/sudoers

#Download Heroku script
wget https://toolbelt.heroku.com/install.sh 
chmod +x install.sh

#modify the script to not use sudo. we are already root. 
sed -i "s/sudo sh <<SCRIPT/echo 'skipping sudo'/g" install.sh
sed -i "s/sudo -k/echo 'skipping sudo'/g" install.sh
sed -i "s/SCRIPT/echo 'skipping sudo'/g" install.sh
./install.sh
/usr/local/heroku/bin/heroku