apt install curl
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
sudo apt-get install -y nodejs


mkdir /home/vagrant/app
curl https://raw.githubusercontent.com/juan-pinzon/compunube/main/consul/resources/app/index.js --output /home/vagrant/app/index.js

curl https://raw.githubusercontent.com/juan-pinzon/compunube/main/consul/resources/service_template.service --output /lib/systemd/system/appweb.service
systemctl daemon-reload
systemctl start appweb
systemtl enable appweb
