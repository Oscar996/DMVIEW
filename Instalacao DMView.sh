#!/bin/bash

#Download do arquivo de instalacao MongoDB
curl -kLJOv https://download.datacom.com.br/ftp/produtos/DmView/Database_MongoDB/Linux/Linux/64/mongodb-linux-x86_64-rhel70-3.4.13.tgz

#Download do arquivo de instalacao Oracle
curl -kLJOv https://download.datacom.com.br/ftp/produtos/DmView/Database_Oracle_Instaladores/oracle-xe-11.2.0-1.0.Linuxx86_64.rpm.zip

#Download do arquivo de instalacao DMView
curl -kLJOv https://download.datacom.com.br/ftp/produtos/DmView/DmView_Instaladores/DmView_11/Linux/010.0001.94-DmView-11.0.1-5-linux-20210805203535.jar

#Instalacao do Oracle

#Verificar hostname
hostname
cat /etc/hosts

#Descompactacao do Oracle
unzip oracle-xe-11.2.0-1.0.Linuxx86_64.rpm.zip
cd Disk1

#Execucao do Instalador do Oracle
rpm -Uvh oracle-xe-11.2.0-1.0.x86_64.rpm


