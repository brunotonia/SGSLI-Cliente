#!/bin/bash

# Validando usuário
if [ $USER = root ]; then
  # Carregando Variáveis
  SGSLI_PATH=/etc/sgsli
  SGSLI_CONF=$SGSLI_PATH/sgsli.conf

  if [ -f $SGSLI_CONF ]; then
    SGSLI_URL=$(grep 'SGSLI_WEB_URL' $SGSLI_CONF | awk -F "=" '{print $2 ; }')

    ########################################################################
    # Atualização do arquivo sources.list                                  #
    ########################################################################
    SGSLI_SRC_WS_VLR=$(curl -s $SGSLI_URL/etc/apt/sources.list/versao)
    SGSLI_SRC_FS_VLR=$(grep 'Sources' $SGSLI_CONF | awk -F "=" '{print $2 ; }')
    SGSLI_UPD_RUN=0;

    if [ "$SGSLI_SRC_WS_VLR" -gt "$SGSLI_SRC_FS_VLR" ]; then
      echo "Atualizando /etc/apt/sources.list"
      SGSLI_APT_DIR=/etc/apt
      mv "$SGSLI_APT_DIR/sources.list" "$SGSLI_APT_DIR/sources.list.bkp"
      curl -s "$SGSLI_URL/etc/apt/sources.list" > "$SGSLI_APT_DIR/sources.list"
      sed -i "s/^Sources=.*/Sources=$SGSLI_SRC_WS_VLR/" $SGSLI_CONF

      echo "Executando apt-get update"
      apt-get update
      SGSLI_UPD_RUN=1;
      SGSLI_UPT_WS_VLR=$(curl -s $SGSLI_URL/apt-get/update/versao)
      sed -i "s/^Update=.*/Update=$SGSLI_UPT_WS_VLR/" $SGSLI_CONF
    fi

    ########################################################################
    # Atualização do arquivo sources.list                                  #
    ########################################################################
    if [ "$SGSLI_UPT_RUN" = 0 ]; then
      SGSLI_UPT_WS_VLR=$(curl -s $SGSLI_URL/apt-get/update/versao)
      SGSLI_UPT_FS_VLR=$(grep 'Update' $SGSLI_CONF | awk -F "=" '{print $2 ; }')

      if [ "$SGSLI_UPT_WS_VLR" -gt "$SGSLI_UPT_FS_VLR" ]; then
        echo "Executando apt-get update"
        apt-get update
        SGSLI_UPD_RUN=1;
        SGSLI_UPT_WS_VLR=$(curl -s $SGSLI_URL/apt-get/update/versao)
        sed -i "s/^Update=.*/Update=$SGSLI_UPT_WS_VLR/" $SGSLI_CONF
      fi

    fi

    ########################################################################
    # Instalação de Pacotes                                                #
    ########################################################################
    SGSLI_INS_WS_VLR=$(curl -s $SGSLI_URL/apt-get/install/versao)
    SGSLI_INS_FS_VLR=$(grep 'Instalacao' $SGSLI_CONF | awk -F "=" '{print $2 ; }')

    if [ "$SGSLI_INS_WS_VLR" -gt "$SGSLI_INS_FS_VLR" ]; then
      echo "Executando apt-get install"
      SGSLI_INS_PKG=$(curl -s $SGSLI_URL/apt-get/install/$SGSLI_INS_FS_VLR)
      echo $SGSLI_INS_PKG
      apt-get install --force-yes $SGSLI_INS_PKG
      if [ $? = 0 ]; then
        sed -i "s/^Instalacao=.*/Instalacao=$SGSLI_INS_WS_VLR/" $SGSLI_CONF
      fi
    fi

    ########################################################################
    # Remoção de Pacotes                                                   #
    ########################################################################
    SGSLI_REM_WS_VLR=$(curl -s $SGSLI_URL/apt-get/remove/versao)
    SGSLI_REM_FS_VLR=$(grep 'Remocao' $SGSLI_CONF | awk -F "=" '{print $2 ; }')

    if [ "$SGSLI_REM_WS_VLR" -gt "$SGSLI_REM_FS_VLR" ]; then
      echo "Executando apt-get remove"
      SGSLI_REM_PKG=$(curl -s $SGSLI_URL/apt-get/remove/$SGSLI_REM_FS_VLR)
      apt-get remove --force-yes $SGSLI_REM_PKG
      if [ $? = 0 ]; then
        sed -i "s/^Remocao=.*/Remocao=$SGSLI_REM_WS_VLR/" $SGSLI_CONF
      fi
    fi

    ########################################################################
    # Atualização de Pacotes                                               #
    ########################################################################
    SGSLI_UPG_WS_VLR=$(curl -s $SGSLI_URL/apt-get/upgrade/versao)
    SGSLI_UPG_FS_VLR=$(grep 'Upgrade' $SGSLI_CONF | awk -F "=" '{print $2 ; }')

    if [ "$SGSLI_UPG_WS_VLR" -gt "$SGSLI_UPG_FS_VLR" ]; then
      echo "Executando apt-get upgrade"
      apt-get upgrade --force-yes
      if [ $? = 0 ]; then
        sed -i "s/^Upgrade=.*/Upgrade=$SGSLI_UPG_WS_VLR/" $SGSLI_CONF
      fi
    fi

    ########################################################################
    # Atualização do Sistema                                               #
    ########################################################################
    SGSLI_DUP_WS_VLR=$(curl -s $SGSLI_URL/apt-get/dist-upgrade/versao)
    SGSLI_DUP_FS_VLR=$(grep 'Dist' $SGSLI_CONF | awk -F "=" '{print $2 ; }')

    if [ "$SGSLI_DUP_WS_VLR" -gt "$SGSLI_DUP_FS_VLR" ]; then
      echo "Executando apt-get upgrade"
      apt-get dist-upgrade --force-yes
      if [ $? = 0 ]; then
        sed -i "s/^Dist=.*/Dist=$SGSLI_DUP_WS_VLR/" $SGSLI_CONF
      fi
    fi

  else
    echo [ERRO!] Arquivo de configuração $SGSLI_CONF não encontrado.
    echo         Reinstale o aplicativo.
    exit
  fi
else
  echo [ERRO!] Usuário sem permissões de acesso.
  echo         É preciso ser super usuário para executar este programa.
  echo
fi
