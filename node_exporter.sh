#!/bin/bash
#Downloading
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz # Replace on new verison
tar -xvzf node_exporter-1.1.2.linux-amd64.tar.gz
cp node_exporter-1.1.2.linux-amd64/node_exporter /usr/local/bin/
/usr/sbin/useradd --no-create-home --shell /bin/false node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter
#Add
tee /etc/systemd/system/node_exporter.service <<"EOF"
[Unit]
Description=Node Exporter

[Service]
User=node_exporter
Group=node_exporter
EnvironmentFile=-/etc/sysconfig/node_exporter
ExecStart=/usr/local/bin/node_exporter $OPTIONS

[Install]
WantedBy=multi-user.target
EOF
#Create
mkdir /etc/sysconfig
tee /etc/sysconfig/node_exporter <<"EOF"
OPTIONS="--collector.processes --collector.systemd"
EOF
chown node_exporter:node_exporter /etc/sysconfig/node_exporter
#Delete
rm node_exporter-1.1.2.linux-amd64.tar.gz
rm -rf node_exporter-1.1.2.linux-amd64
#Run
sudo systemctl daemon-reload && \
sudo systemctl enable node_exporter && \
sudo systemctl start node_exporter  
#Downloading
wget https://github.com/ncabatoff/process-exporter/releases/download/v0.7.5/process-exporter-0.7.5.linux-amd64.tar.gz # Replace on new verison
tar -xvzf process-exporter-0.7.5.linux-amd64.tar.gz
cp process-exporter-0.7.5.linux-amd64/process-exporter /usr/local/bin/
/usr/sbin/useradd --no-create-home --shell /bin/false process-exporter
chown process-exporter:process-exporter /usr/local/bin/process-exporter
#Add
tee /etc/systemd/system/process-exporter.service <<"EOF"
[Unit]
Description=Process Exporter
[Service]
User=process-exporter
Group=process-exporter
Type=simple
ExecStart=/usr/local/bin/process-exporter --config.path /etc/sysconfig/process-exporter.yml
[Install]
WantedBy=multi-user.target
EOF
tee /etc/sysconfig/process-exporter.yml <<"EOF"
process_names:
  - name: "{{.Comm}}"
    cmdline:
    - '.+'
EOF
chown process-exporter:process-exporter /etc/sysconfig/process-exporter.yml
#Delete
rm process-exporter-0.7.5.linux-amd64.tar.gz
rm -rf process-exporter-0.7.5.linux-amd64
#Run
sudo systemctl daemon-reload && \
sudo systemctl enable process-exporter && \
sudo systemctl start process-exporter && \
sudo systemctl status process-exporter && sudo systemctl status node_exporter 