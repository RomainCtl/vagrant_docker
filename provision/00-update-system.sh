#!/bin/bash
# ===================================================
# Update ubuntu system package 
# ===================================================
#

echo "
======================================
Update ubuntu system package
======================================"

# Upgrades system and installs HTTPS requirements
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends apt-transport-https ca-certificates make
#rm -rf /var/lib/apt/lists/* 
update-ca-certificates
