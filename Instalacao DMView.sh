#!/bin/bash

#Download do arquivo de instalacao MongoDB
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/Database_MongoDB/Linux/Linux/64/mongodb-linux-x86_64-rhel70-3.4.13.tgz

#Download do arquivo de instalacao Oracle
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/Database_Oracle_Instaladores/oracle-xe-11.2.0-1.0.Linuxx86_64.rpm.zip

#Download do arquivo de instalacao DMView
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/DmView_Instaladores/DmView_11/Linux/010.0001.94-DmView-11.0.1-5-linux-20210805203535.jar

#Instalacao do Oracle

#Verificar hostname
hostname
cat /etc/hosts

#Instalacao dos requisitos para o Oracle
yum install glibc make binutils gcc libaio bc flex -y

#Descompactacao do Oracle
unzip oracle-xe-11.2.0-1.0.Linuxx86_64.rpm.zip
cd Disk1

#Execucao do Instalador do Oracle
rpm -Uvh oracle-xe-11.2.0-1.0.x86_64.rpm

#Instalar pre-requisitos MongoDB
yum install libcurl openssl xz-libs -y

#Copiar o arquivo para o diretorio opt e extrair o MongoDB
cp mongodb-linux-x86_64-rhel70-3.4.13.tgz /opt
tar -zxvf mongodb-linux-x86_64-rhel70-3.4.13.tgz

#Renomear a pasta extraida e definir permissao de execucao
mv mongodb-linux-x86_64-rhel70-3.4.13 mongodb
chmod –R 777 mongodb

#Manter a variavel de ambiente atualizada
echo 'export PATH=<mongodb-install-directory>/bin:$PATH' >> /etc/bashrc

#Criacao de links simbolicos
ln -s /opt/mongodb/bin/* /usr/bin

#Criacao de diretorio padrao
mkdir -p /data/db

#Inicializacao do MongoDb
mongod

#Configuracao do ulimit para o bom funcionamento do MongoDB
ulimit -f unlimited
ulimit -t unlimited
ulimit -v unlimited
ulimit -l unlimited
ulimit -n 64000
ulimit -m unlimited
ulimit -u 64000

#*Verificar como realizar este procedimento

#Configuracao Oracle
#/etc/init.d/oracle-xe configure
