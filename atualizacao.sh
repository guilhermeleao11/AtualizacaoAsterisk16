#!/bin/bash


#variaveis
os=$(hostnamectl | grep Operating | awk '{print $3 $4 $5}')
pacote='redt-asterisk-jansson-pjproject.zip'
src=/usr/src/
LOG=/var/log/atualiza_asterisk.log

echo "[`date`] ==== Inicio de rotina..." >> $LOG
#exec 1>>${LOG}
#exec 2>&1

#Efetuando Backups
cp -av /etc/asterisk/ /etc/asterisk-16.11/ >> $LOG
cp -av /var/lib/asterisk/ /var/lib/asterisk-16.11/ >> $LOG
cp -av /usr/lib/asterisk/ /usr/lib/asterisk-16.11/ >> $LOG

#Verificar se o sistema operacional e "CentOSLinux7"
if [ "$os" == "CentOSLinux7" ]; then
    echo "Sistema compativel. Iniciando instalacao" >> $LOG
    
	sleep 5
    cd /tmp/
    wget --no-check-certificate https://monitoring.redt.com.br/suporte/redt-asterisk-jansson-pjproject.zip >> $LOG
    pwd >> $LOG
    sleep 1
    unzip "$pacote" >> $LOG
    mv asterisk-16.26.1.tar.gz $src >> $LOG 
    cd $src
    pwd >> $LOG
    sleep 2
    tar xf asterisk-16.26.1.tar.gz >> $LOG
    cd asterisk-16.26.1
    sleep 3
    ## Preparando ambiente 
    ./configure -q --with-jansson-bundled >> $LOG
    ## Preparando Menu de Configuracao da Compilacao
    make menuselect.makeopts >> $LOG
    menuselect/menuselect --enable-category MENUSELE CT_CODECS --disable codec_g729a >> $LOG
    ## Compilando Arquivos
    make -j 4 >> $LOG
    sleep 10
   
    CHAMADAS_ATIVAS=$(rasterisk -x 'core show calls' |grep active |cut -d \  -f 1) 

	if [ "$CHAMADAS_ATIVAS" = '0' ]; then
		echo 'executando MAKE INSTALL...' >> $LOG
		sleep 3
		nohup make install -j2 >> $LOG

	else
        echo "Existem $CHAMADAS_ATIVAS chamadas em Curso" >> $LOG
		echo "Por favor, aguarde a finalizacao e execute NOHUP MAKE INSTALL" >> $LOG  
		echo "Apos isso, reinicie o Asterisk" >> $LOG  >&2
	fi	

        if [ "$CHAMADAS_ATIVAS" = '0' ]; then
            echo "Reiniciando Asterisk..."  >> $LOG 
            asterisk -rx 'core restart now'  
            sleep 13
            asterisk -rx 'core show version'  
        else
            echo "Existem $CHAMADAS_ATIVAS chamadas em Curso" >> $LOG
            echo "Por favor, aguarde a finalizacao e reinicie o Asterisk apos isso" >> $LOG
			echo "[`date`] ==== Fim de rotina..." >> $LOG
		fi
	
else
    echo "Sistema incompativel, esse procedimento é para o sistema operacional CentOS 7" >> $LOG
	echo "[`date`] ==== Fim de rotina..." >> $LOG

fi