cd /home/vagrant
apt install curl
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.profile
nvm install node

mkdir /home/vagrant/app
curl https://raw.githubusercontent.com/juan-pinzon/compunube/main/consul/resources/app/index.js --output /home/vagrant/app/index.js
cd /home/vagrant/app
npm init -y
npm install express
