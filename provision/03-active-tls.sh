#!/bin/bash
# ===================================================
# active tls
# ===================================================
# 

echo "
======================================
Configure docker with TLS
======================================"

# Clean
rm -f /etc/systemd/system/docker.service.d/override.conf
rm -f /etc/docker/daemon.json

sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker


sudo tee /etc/docker/daemon.json <<EOF
{
  "hosts"    : ["fd://", "tcp://0.0.0.0:2376"],
  "tls": true,
  "tlsverify": true,
  "tlscacert": "/root/.docker/ca.pem",
  "tlscert": "/root/.docker/server.pem",
  "tlskey": "/root/.docker/server-key.pem"
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker

journalctl -u docker -n 10


