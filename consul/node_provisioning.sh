#Install Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - &&\
sudo apt-get install -y nodejs

#Download app web
mkdir /home/vagrant/app
curl https://raw.githubusercontent.com/juan-pinzon/compunube/main/consul/resources/app/index.js --output /home/vagrant/app/index.js

#Create appweb as service
curl https://raw.githubusercontent.com/juan-pinzon/compunube/main/consul/resources/service_template.service --output /lib/systemd/system/appweb.service
systemctl daemon-reload
systemctl start appweb
systemctl enable appweb

#Install Consul
wget -O- --no-check-certificate https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
apt install -y consul

#Create agent node
consul agent -node=agent-web1 -bind=192.168.58.3 -enable-script-checks=true -data-dir=/tmp/consul -config-dir=/etc/consul.d 
consul join 192.168.58.2

#Config WebServer for consul
curl https://raw.githubusercontent.com/juan-pinzon/compunube/main/consul/resources/web-service.json --output /etc/consul.d/web-service.json
consul reload
