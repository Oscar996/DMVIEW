#!/usr/bin/env bash

#Script gerado por Oscar Santos
#20241106
#Testado no SO Rocky Linux 8 utilizando os seguintes pacotes:
#MongoDb 4.4 ==> RedHat8
#Oracle Database Preinstall 21c.1.0.1 ==> RedHat-8
#Oracle Database XE 21c.1.0.1 ==> RedHat-8
#DMView 11.5 ==> CentOS-7.9/RedHat-8

#---------
#Variáveis
#Senha do banco de dados Oracle
#Deve conter 8 caracteres, com pelo menos 1 número, 1 letra maiúscula e 1 letra minúscula
echo "pass_oracledb = 9Xk7V9YX"
#---------

#Entrando no diretorio root para efetua as instalacoes
cd /root

#Update básico de lei
yum update -y && yum upgrade -y

#Download do arquivo de instalacao MongoDB
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/Database_MongoDB/Linux/64/4.4/MongoDB_4_4-Red_Hat_8.zip
#Download dos arquivos de instalacao Oracle
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/Database_Oracle_Instaladores/linux/oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/Database_Oracle_Instaladores/linux/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm
#Download do arquivo de instalacao DMView
curl -kLJO https://download.datacom.com.br/ftp/produtos/DmView/DmView_Instaladores/DmView_11.5/Linux/DmView-11.5.0-2-linux.AppImage
echo "Downloads finalizados."

#Verificar hostname
hostname
cat /etc/hosts \
&& echo "Hostnames verificados" || echo "Hostnames nao encontrados"

#Instalacao dos requisitos para o sistema
yum -y install bind-utils compat-openssl10 cyrus-sasl glibc-devel ksh libnsl make net-tools nfs-utils policycoreutils-python-utils psmisc smartmontools sysstat unzip vim xorg-x11-utils xorg-x11-xauth \
&& echo "Download de dependencias do sistema concluido" || echo "Falha no download de dependencias do sistema"

#---------
#Instalacao do Oracle
#Execucao do Pré-Instalador do Oracle
rpm -Uvh oracle-database-preinstall-21c-1.0-1.el8.x86_64.rpm \
&& echo "Instalacao do Pre-Install Oracle concluida." || echo "Falha na instalacao do Pre-Install Oracle"

#Execucao do Instalador do Oracle
rpm -Uvh oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm \
&& echo "Instalacao do Oracle concluida." || echo "Falha na instalacao do Oracle"

echo "So far so good"
#Configuração do Banco Oracle
printf "9Xk7V9YX\n9Xk7V9YX\n" | /etc/init.d/oracle-xe-21c configure \
&& echo "Configuracao do Oracle concluida." || echo "Falha na configuracao do Oracle"

#Exportação de variáveis
echo -e "export ORAENV_ASK=NO\nexport ORACLE_SID=XE\nexport ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE\nexport PATH=\$PATH:/opt/oracle/product/21c/dbhomeXE/bin" >> /etc/profile \
&& echo "Exportação de variáveis concluida." || echo "Falha na exportação de variáveis"

#Inicialização do banco Oracle
systemctl daemon-reload
/sbin/chkconfig oracle-xe-21c on

#---------
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

#Extração do Mongodb 4.4
unzip MongoDB_4_4-Red_Hat_8.zip
cd MongoDB_4_4-Red_Hat_8

#Instalação dos arquivos MongoDB
rpm -Uvh mongodb-* \
&& echo "Instalação do MongoDB concluida." || echo "Falha na Instalação do MongoDB"

#Voltar ao diretorio inicial
cd /root

#Iniciar Serviços MongoDB
systemctl enable mongod.service
systemctl start mongod.service \
&& echo "Inicialização do serviço MongoDB realizada." || echo "Falha na inicialização do serviço MongoDB"
systemctl status mongod.service
#Tempo antes de acessar o banco
sleep 10
#Configuração do MongoDB
#Criação do usuário NMS
mongo <<EOF
use admin
db.createUser({
    user: "admin",
    pwd: "nms",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ] } )

use nms
db.createUser({
    user: "nms",
    pwd: "nms",
    roles: [ { role: "readWrite", db: "nms" }, { role: "dbAdmin", db: "nms" } ] } )
EOF

#Configuração do arquivo do mongod.conf
sed -i '
s/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g;
s/#security/security/g;
/security/a\ authorization: "enabled"
' /etc/mongod.conf \
&& echo "Configuração do arquivo MongoDB realizada." || echo "Falha na Configuração do arquivo MongoDB"

#Restart do serviço mongoD
systemctl restart mongod.service \
&& echo "Reinicialização do serviço MongoDB realizada." || echo "Falha na reinicialização do serviço MongoDB"

#---------
#Permissão total no instalador do DMView
chmod 777 DmView-11.5.0-2-linux.AppImage 

#Atualmente não aceita variável no input
#Pendente implementação
#Inicializacao da instalacao do DMView
printf "1\n1\n/opt/DmView\no\n1\ny\n1\ny\ny\ny\n1\n/opt/DmView/jre11.0.18\n1\n1\n1\n1\nxe\n9Xk7V9YX\n1521\nxepdb1\n1\n1\n1\njdbc:oracle:thin:@localhost:1521/XEPDB1\nnms\nnms\nnms\n1\n/opt/oracle/oradata/XE/XEPDB1\n1\n27017\nnms\nnms\nnms\n1\n1\n1\n" | ./DmView-11.5.0-2-linux.AppImage -console \
&& echo "Instalacao e configuracao do DmView concluida." || echo "Falha no processo de instalacao do DMview"

#Inicia os servicos do DMView
/etc/init.d/nms.allservices start \
&& echo "DMview em funcionamento!!!" || echo "Falha ao iniciar servico DMview"

#Tempo para inicialização dos serviços
sleep 30
echo "Serviços NMS sendo iniciados"

#Verificação do status dos serviços NMS
/etc/init.d/nms.allservices status

#Configuração do Firewall
firewall-cmd --zone=public --permanent --add-port=162/udp \
                   --add-port=81/tcp --add-port=8443/tcp \
                   --add-port=8100/tcp --add-port=8101/tcp \
                   --add-port=8082/tcp --add-port=61616/tcp \
                   --add-port=7547/tcp --add-port=7546/tcp \
&& echo "Firewall configurado" || echo "Falha na configuração do Firewall"

firewall-cmd --reload

echo -e "Instalacao concluida!!! \n
Acesse a Interface Web utilizando o IP do servidor com https:// atraves da porta :8100.\n
Usuario e senha padrao: adminstrator / administrator"
