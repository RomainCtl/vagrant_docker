#!/bin/bash
# ===================================================
# create all certificats
# ===================================================
#

echo "
======================================
create all certificats
======================================"

cd /tmp

CA_CERT=ca.pem
CA_KEY=ca-key.pem
CLIENT_CERT=cert.pem
CLIENT_KEY=key.pem
SERVER_CERT=server.pem
SERVER_KEY=server-key.pem
PASSPHRASE=mapassphrase

SERVER_CERT_PATH=/root/.docker
CLIENT_CERT_PATH=$DOCKER_CERT_PATH_LINUX # DOCKER_CERT_PATH_LINUX provided by vagrantfile

NET_DEFAULT=enp0s8
dhostname=localhost
dip=$(ip -f inet -4 addr show ${NET_DEFAULT} | grep inet | awk '{print $2}' | cut -d/ -f1)
#dip=127.0.0.1

echo "---------------------------------"
echo "- Nom de l'hôte Docker : " $dhostname
echo "- Adresse IP de l'hôte Docker : " $dip
echo "---------------------------------"

## Clean
chmod -R 0700 $CLIENT_CERT_PATH 
chmod -R 0700 $SERVER_CERT_PATH

sudo rm -f *.pem
sudo rm -f $CLIENT_CERT_PATH/*.pem
sudo rm -f $SERVER_CERT_PATH/*.pem


## Generation du certificat CA
openssl genrsa -aes256 -passout pass:$PASSPHRASE -out $CA_KEY 4096
openssl req -new -x509 -days 365 -key $CA_KEY -sha256 -passin pass:$PASSPHRASE -subj "/C=FR/ST=MyState/O=MyOrg" -out $CA_CERT 

## Generation du certificat Serveur
openssl genrsa -out $SERVER_KEY 4096 
openssl req -subj "/CN=${dhostname}" -sha256 -new -key $SERVER_KEY -out server.csr 2>/dev/null
echo subjectAltName = IP:${dip} > extfile.cnf
sudo openssl x509 -passin pass:$PASSPHRASE -req -sha256 -days 365 -in server.csr -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $SERVER_CERT -extfile extfile.cnf

## Generation du certificat Client
openssl genrsa -out $CLIENT_KEY 4096 
openssl req -subj '/CN=client' -new -key $CLIENT_KEY -out client.csr 2>/dev/null
echo extendedKeyUsage = clientAuth > extfile.cnf
openssl x509 -passin pass:$PASSPHRASE -req -sha256 -days 365 -in client.csr -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -out $CLIENT_CERT -extfile extfile.cnf 

## Nettoyage
rm -f client.csr server.csr extfile.cnf ca.srl
chmod 0400 $CA_KEY $CLIENT_KEY $SERVER_KEY
chmod 0444 $CA_CERT $SERVER_CERT $CLIENT_CERT

## Instruction
echo ""
echo " - Server side : copy to [/root/.docker] these files [$CA_CERT $SERVER_CERT $SERVER_KEY]"
echo " - Client side : copy to [~/.docker    ] these files [$CA_CERT $CLIENT_CERT $CLIENT_KEY]"

mkdir -p $SERVER_CERT_PATH $CLIENT_CERT_PATH

cp -v $CA_CERT $SERVER_CERT $SERVER_KEY $SERVER_CERT_PATH
cp -v $CA_CERT $CLIENT_CERT $CLIENT_KEY $CLIENT_CERT_PATH


