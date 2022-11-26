#!/bin/bash

wget https://releases.hashicorp.com/consul/1.14.0/consul_1.14.0_linux_amd64.zip
apt install unzip
unzip consul_1.14.0_linux_amd64.zip
rm -rf consul_1.14.0_linux_amd64.zip
mv consul /usr/bin
consul keygen > /home/ubuntu/key.txt
mkdir /var/consul

mkdir -p /etc/consul.d/
touch /etc/consul.d/config.json
cd /etc/consul.d

tee -a config.json <<EOF
{
"bootstrap": true,
"server": true,
"log_level": "DEBUG",
"enable_syslog": true,
"datacenter": "dc1",
"addresses" : {
"http": "0.0.0.0"
},
"bind_addr": "0.0.0.0",
"node_name": "node-1",
"data_dir": "/var/consul",
"encrypt": "$(cat /home/ubuntu/key.txt)",
"ui": true
}
EOF

cd /etc/systemd/system
touch consul.service

tee -a consul.service <<EOF
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/consul
Restart=on-failure
ExecStart=/usr/bin/consul agent -config-dir=/etc/consul.d


[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start consul
systemctl status consul
