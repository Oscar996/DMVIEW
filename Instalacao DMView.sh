#!/usr/bin/env bash

#Download do arquivo de instalacao MongoDB
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/Database_MongoDB/Linux/Linux/64/mongodb-linux-x86_64-rhel70-3.4.13.tgz

#Download do arquivo de instalacao Oracle
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/Database_Oracle_Instaladores/oracle-xe-11.2.0-1.0.Linuxx86_64.rpm.zip

#Download do arquivo de instalacao DMView
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/DmView_Instaladores/DmView_11/Linux/010.0001.94-DmView-11.0.1-5-linux-20210805203535.jar

echo "Downloads finalizados."

#Instalacao do Oracle

#Verificar hostname
hostname
cat /etc/hosts \
&& echo "Hostnames verificados" || echo "Hostnames nao encontrados"

#Instalacao dos requisitos para o Oracle
yum install glibc make binutils gcc libaio bc flex unzip -y \
&& echo "Download de dependencias do Oracle concluido" || echo "Falha no download de dependencias do Oracle"

#Descompactacao do Oracle
unzip oracle-xe-11.2.0-1.0.Linuxx86_64.rpm.zip
cd Disk1

#Execucao do Instalador do Oracle
rpm -Uvh oracle-xe-11.2.0-1.0.x86_64.rpm \
&& echo "Instalacao do Oracle concluida." || echo "Falha na instalacao do Oracle"


#Configuracao Oracle
printf '\8080\n1521\nnms\nnms\ny\n' | /etc/init.d/oracle-xe configure \
&& echo "Configuracao do Oracle concluida." || echo "Falha na configuracao do Oracle"


#Configuracao do ulimit para o bom funcionamento do MongoDB
ulimit -f unlimited
ulimit -t unlimited
ulimit -v unlimited
ulimit -l unlimited
ulimit -n 131072
ulimit -m unlimited
ulimit -u 64000
ulimit -a \
&& echo "Definicoes de sistema ajustadas para o bom funcionamento do MongoDB." || echo "Falha na configuracao do Ulimit"

#Instalar pre-requisitos MongoDB
yum install libcurl openssl xz-libs -y
echo "Dependencias do MongoDB instaladas."

#Copiar o arquivo para o diretorio opt e extrair o MongoDB
cp mongodb-linux-x86_64-rhel70-3.4.13.tgz /opt
cd /opt
tar -zxvf mongodb-linux-x86_64-rhel70-3.4.13.tgz

#Renomear a pasta extraida e definir permissao de execucao
mv mongodb-linux-x86_64-rhel70-3.4.13 mongodb
chmod -R 777 mongodb

#Manter a variavel de ambiente atualizada
echo 'export PATH=/opt/mongodb/bin:$PATH' >> /etc/bashrc

#Criacao de links simbolicos
ln -s /opt/mongodb/bin/* /usr/bin

#Criacao de diretorio padrao
mkdir -p /data/db

#Inicializacao do MongoDb
mongod
echo "Instalacao MongoDB finalizada."

#Instalacao dependencia DMView
yum install java -y
echo "Instalacao dependencias DmView concluida."

#*Verificar como realizar este procedimento
#Inicializacao da instalacao do DMView
Java –jar 010.0001.93-DmView-10.1.0-4-linux-20180808130157.jar –
console
echo "Instalacao do DmView concluida."

#Inicia os servicos do DMView
/etc/init.d/nms.allservices start

#Configuracao de inicializacao automatica dos servicos
cd /opt/DmView/bin/
sudo ./auto_start_services.sh

#Instalacao Client de acesso remoto DMView
yum install -y xorg-x11-server-Xorg xorg-x11-xauth xorg-x11-apps epel-release x2goserver
