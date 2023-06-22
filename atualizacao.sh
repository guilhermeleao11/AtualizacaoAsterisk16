#!/bin/bash

# Variáveis
os=$(hostnamectl | grep Operating | awk '{print $3 $4 $5}')
pacote='redt-asterisk-jansson-pjproject.zip'
src=/usr/src/

# Efetuando backups
cp -av /etc/asterisk/ /etc/asterisk-16.11/
cp -av /var/lib/asterisk/ /var/lib/asterisk-16.11/
cp -av /usr/lib/asterisk/ /usr/lib/asterisk-16.11/

# Verificar se o sistema operacional é "CentOSLinux7"
if [ "$os" == "CentOSLinux7" ]; then
    echo "Sistema compatível. Pressione Enter para prosseguir."
    read -r
    cd /tmp/
    wget --no-check-certificate https://monitoring.redt.com.br/suporte/redt-asterisk-jansson-pjproject.zip
    pwd
    sleep 1
    unzip "$pacote"
    mv asterisk-16.26.1.tar.gz "$src"
    cd "$src"
    pwd
    sleep 2
    tar xf asterisk-16.26.1.tar.gz
    cd asterisk-16.26.1
    sleep 3
    # Preparando ambiente
    ./configure -q --with-jansson-bundled
    # Preparando Menu de Configuração da Compilação
    make menuselect.makeopts
    menuselect/menuselect --enable-category MENUSELECT_CODECS --disable codec_g729a
    # Compilando Arquivos
    make -j 4
    sleep 10
    nohup make install -j2
    CHAMADAS_ATIVAS=$(asterisk -rx 'core show calls' | grep active | cut -d \  -f 1)
    if [ "$CHAMADAS_ATIVAS" = '0' ]; then
        echo 'Reiniciando Asterisk...' >&2
        asterisk -rx 'core restart now'
        sleep 13
        asterisk -rx 'core show version'
    else
        echo "Existem $CHAMADAS_ATIVAS chamadas em curso. Reinicie o Asterisk quando não houver chamadas ativas." >&2
        echo 'Execute o comando: asterisk -rx "core restart now" && sleep 13 && asterisk -rx "core show version"' >&2
    fi
else
    echo "Sistema incompatível. Este procedimento é para o sistema operacional CentOS 7."
fi
