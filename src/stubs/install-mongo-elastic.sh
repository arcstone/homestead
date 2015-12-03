#!/usr/bin/env bash

echo "Disabling MySQL"
sudo service mysql stop
sudo update-rc.d mysql disable

echo "Disabling PostgreSQL"
sudo service postgresql stop
sudo update-rc.d postgresql disable

echo "Adding MongoDB Repo"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list

echo "Adding Elasticsearch Repo"
wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee /etc/apt/sources.list.d/elasticsearch-2.x.list

echo "Installing MongoDB and Elasticsearch"
sudo apt-get update
sudo apt-get install -y mongodb-org php5-mongo default-jre-headless elasticsearch
restart php5-fpm

echo "Configuring MongoDB"
sudo sed -ri "s/(bindIp: )127.0.0.1/\10.0.0.0/" /etc/mongod.conf
sudo restart mongod

echo "Configuring Elasticsearch"
echo 'network.host: 0.0.0.0' | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo 'http.cors.enabled: true' | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo 'http.cors.allow-origin: "http://quirks"' | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo 'http.cors.allow-headers: "X-Requested-With, Content-Type, Content-Length, authorization"' | sudo tee -a /etc/elasticsearch/elasticsearch.yml
echo 'http.cors.allow-credentials: true' | sudo tee -a /etc/elasticsearch/elasticsearch.yml
sudo service elasticsearch restart
