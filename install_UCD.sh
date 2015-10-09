#!/bin/bash

rm -rf /etc/yum.repos.d/BB.repo

echo "Instalando pre-requisito para o IBM Rational License Manager"
mount -o loop /my_drive/rhel-server-6.5-x86_64-dvd.iso /mnt
repo_file=/etc/yum.repos.d/server.repo
echo "[server]" > $repo_file
echo "name=server" >> $repo_file
echo "baseurl=file:///mnt" >> $repo_file
echo "enabled=1" >> $repo_file
yum clean all
rpm --import /mnt/*GPG*
yum install redhat-lsb-core-4.0-7.el6.i686 -y 

echo "Instalando o IBM Installation Manager"
unzip /vagrant/binary/agent.installer.linux.gtk.x86_64_1.8.1000.20141126_2002.zip -d /tmp/IM

/tmp/IM/eclipse/tools/imcl \
	install com.ibm.cic.agent  -acceptLicense -installationDirectory /opt/IM \
	-repositories /tmp/IM -showVerboseProgress -log /tmp/IM.log

echo "Instalando o servidor de licencas"
unzip /vagrant/binary/RLKS_8.1.4_FOR_LINUX_X86_ML.zip -d /tmp/license

/opt/IM/eclipse/tools/imcl install com.ibm.rational.license.key.server.linux.x86_8.1.4000.20130823_0513 \
	-acceptLicense -installationDirectory /opt/RLM \
	-repositories /tmp/license/RLKSSERVER_SETUP_LINUX_X86/disk1 \
	-showVerboseProgress -log /tmp/RLM.log

echo "ATENCAO: Eh preciso ter o arquivo license.bat"
export LM_LICENSE_FILE=/vagrant/license.dat 

echo "Inciando o servidor de licencas"
/opt/RLM/config/start_lmgrd start

sleep 3

netstat -an | grep -q 27000 && [[ $? -eq 0 ]] && echo "Servidor de licencas iniciado."

echo "Instalando o java"
rpm -ivh --prefix /opt/java /vagrant/binary/jdk-8u51-linux-x64.rpm 

echo "Descompactando o UrbanCode Deployer"
unzip /vagrant/binary/IBM_UCD_SERVER_6.1.1.6.zip  -d /tmp/UCD

echo "Faz o backup do arquivo"
cp /tmp/UCD/ibm-ucd-install/install.properties /tmp/UCD/ibm-ucd-install/install.properties_bkp

echo "Copiando o arquivo de propriedades de instalacao do UCD"
cp /vagrant/install.properties /tmp/UCD/ibm-ucd-install/install.properties

echo "START:: Executando a instalacao do UrbanCode."
/tmp/UCD/ibm-ucd-install/install-server.sh
echo "END:: Finalizada a instalacao do UrbanCode."

echo "START:: Iniciando processo de start do UrbanCode"
chmod ugo+x /etc/rc.d/init.d/functions

sed -i.bak 's/@SERVER_USER@/root/g;s/@SERVER_GROUP@/root/g'  /opt/ibm-ucd/server/bin/init/server

cd /etc/init.d
ln -s /opt/ibm-ucd/server/bin/init/server ucdserver

chkconfig --add ucdserver

service ucdserver start
echo "END:: Finalizado o processo de start do UrbanCode"
echo "Acesse: https://$(hostname):8443 ou http://$(hostname):8080"

#to Start a agent:
# /opt/ibm-ucd/agent/bin/agent start
