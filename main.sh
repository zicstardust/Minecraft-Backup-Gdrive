#!/bin/sh

NAME_DIR_DRIVE(){
  gdrive list -m 100 --order folder 1>/tmp/.${HORARIO}NAME_DIR_DRIVE
  awk '$1 == "'"$ID_DIR_GDRIVE"'" { print $2 }' /tmp/.${HORARIO}NAME_DIR_DRIVE 1>/tmp/.${HORARIO}1NAME_DIR_DRIVE
  export NAME_DIR_DRIVE=$(cat /tmp/.${HORARIO}1NAME_DIR_DRIVE)
  rm -f /tmp/.${HORARIO}NAME_DIR_DRIVE /tmp/.${HORARIO}1NAME_DIR_DRIVE
}

BK_MAIOR_RETENCAO(){
  gdrive list --absolute -m 100 --order createdTime 1>/tmp/.${HORARIO}BK_MAIOR_RETENCAO
  grep "$NAME_DIR_DRIVE" /tmp/.${HORARIO}BK_MAIOR_RETENCAO 1>/tmp/.${HORARIO}1BK_MAIOR_RETENCAO
  grep .tar.gz /tmp/.${HORARIO}1BK_MAIOR_RETENCAO 1>/tmp/.${HORARIO}2BK_MAIOR_RETENCAO
  awk '$3 == "bin" && $6 > "'"${RETENCAO_DATA}"'" { print $2 }' /tmp/.${HORARIO}2BK_MAIOR_RETENCAO 1>/tmp/.${HORARIO}BK_MAIOR_RETENCAO 
  export BK_MAIOR_RETENCAO="/tmp/.${HORARIO}BK_MAIOR_RETENCAO"
  rm -f /tmp/.${HORARIO}1BK_MAIOR_RETENCAO /tmp/.${HORARIO}2BK_MAIOR_RETENCAO
}

BK_MENOR_RETENCAO(){
  gdrive list --absolute -m 100 --order createdTime 1>/tmp/.${HORARIO}BK_MENOR_RETENCAO
  grep "$NAME_DIR_DRIVE" /tmp/.${HORARIO}BK_MENOR_RETENCAO 1>/tmp/.${HORARIO}1BK_MENOR_RETENCAO
  awk '$3 == "bin" && $6 < "'"${RETENCAO_DATA}"'" { print $2 }' /tmp/.${HORARIO}1BK_MENOR_RETENCAO 1>/tmp/.${HORARIO}BK_MENOR_RETENCAO
  awk '$3 == "bin" && $6 < "'"${RETENCAO_DATA}"'" { print $1 }' /tmp/.${HORARIO}1BK_MENOR_RETENCAO 1>/tmp/.${HORARIO}ID_MENOR_RETENCAO
  export BK_MENOR_RETENCAO="/tmp/.${HORARIO}BK_MENOR_RETENCAO"
  export ID_MENOR_RETENCAO=$(cat /tmp/.${HORARIO}ID_MENOR_RETENCAO)
  rm -f /tmp/.${HORARIO}1BK_MENOR_RETENCAO /tmp/.${HORARIO}ID_MENOR_RETENCAO
}


check_game_run(){
	if pidof -x "${PROCESS_NAME}" >/dev/null; then
		echo "Game em executação no momento, nao foi possivel realizar backup" >> ${LOG}
	else
		backup
	fi
}

backup(){
	echo "***************************************************INICIANDO BACKUP***************************************************" >> ${LOG}
	echo "***************************************************COMPACTANDO MAPAS***************************************************" >> ${LOG}
	tar -czvf ${TARGZ_TEMP} ${LOCAL_DIR_MINECRAFT_MAP} >>${LOG}
	echo "***********************************************ENVIANDO PARA GOOGLE DRIVE**********************************************" >> ${LOG}
	gdrive upload -p ${ID_DIR_GDRIVE} --name ${HORARIO}.tar.gz ${TARGZ_TEMP} >>${LOG}
	echo "***************************************************BACKUP FINALIZADO***************************************************" >> ${LOG}
  rm -f ${TARGZ_TEMP}
}

check_old_backups(){
	echo "***************************************************CHECANDO BACKUPS ANTIGOS***************************************************" >> ${LOG}
	if [[ -s $BK_MENOR_RETENCAO ]];
	then
        delete_old_backups
	else
        echo "Não exixtem backups anteriores a ${RETENCAO_DATA} para deletar" >> ${LOG}
	fi
  rm -f $BK_MENOR_RETENCAO $BK_MAIOR_RETENCAO
}

delete_old_backups(){
  echo "***************************************************DETELANDO BACKUPS ANTIGOS***************************************************" >> ${LOG}
  if [[ -s $BK_MAIOR_RETENCAO ]];
  then
        echo "${ID_MENOR_RETENCAO}"| xargs -I % sh -c 'gdrive delete % >> "'"${LOG}"'"'
	else
        echo "Não foram encontrados backups recentes, por segurança, não sera apagado os backup anteriores a ${RETENCAO_DATA}" >> ${LOG}
	fi
}

CARGA_GERAL(){
  export HORARIO=$(date +%y-%m-%d.%H.%M)
  export TARGZ_TEMP="/tmp/.minebackup.tar.gz"
  export LOG="/tmp/.${HORARIO}.log.txt"
  export LOG_UPLOAD="/tmp/.${HORARIO}upload.log"
  export LOG_NAME_EXPORT="${HORARIO}-log.txt"
  export RETENCAO_DATA=$(date +%Y-%m-%d --date "5 days ago")
}

CARGA_ESPECIFICA(){
    NAME_DIR_DRIVE
    BK_MENOR_RETENCAO
    BK_MAIOR_RETENCAO
}



##################################################################MAIN FUNCTION##########################################################################################

if [[ -z $1 ]];
then
    echo "Sem parametro, por favor adicione o parametro obrigatorio"
    echo ""
    echo "java: Para Java Edition Launcher"
    echo "bedrockappimage: Para Bedrock instalada via appimage launcher"
    echo "bedrockflatpak: Para Bedrock instalada via flatpak:"
    exit
else
  case $1 in

    "java" | "-java" | "--java")
      export LOCAL_DIR_MINECRAFT_MAP="${HOME}/.minecraft/saves"
      export PROCESS_NAME="minecraft-launcher"
      export ID_DIR_GDRIVE="1M40tz-AjIPcIxEsZOU7mJ9OQm28IoUiR"
      ;;

    "bedrockappimage" | "-bedrockappimage" | "--bedrockappimage")
      export LOCAL_DIR_MINECRAFT_MAP="${HOME}/.local/share/mcpelauncher/games/com.mojang/minecraftWorlds"
      export PROCESS_NAME="mcpelauncher-client"
      export ID_DIR_GDRIVE="1-eNR6KUg2kgyQ6vkB9GiBvRRnFuD1gFb"
      ;;

      "bedrockflatpak" | "-bedrockflatpak" | "--bedrockflatpak")
      echo "Ainda não implementado suporte a flatpak"
      exit
      ;;
      "h" | "-h" | "--h" | "help" | "-help" | "--help")
      echo "Ainda não implementado"
      exit
      ;;
      *)
      echo "parametro invalido"
      exit
      ;;
esac
fi


if [[ -z $2 ]];
then
    CARGA_GERAL
    CARGA_ESPECIFICA
    check_game_run
    check_old_backups
    gdrive upload -p ${ID_DIR_GDRIVE} --name ${LOG_NAME_EXPORT} --delete ${LOG}
    echo "Backup finalizado"
    exit
else
  case $2 in
    "f" | "-f" | "--f" | "force" | "-force" | "--force")
      echo "ATENÇÂO: Backup executado em modo forçado" >> ${LOG}
      CARGA_GERAL
      backup
      gdrive upload -p ${ID_DIR_GDRIVE} --name ${LOG_NAME_EXPORT} --delete ${LOG}
      echo "Backup finalizado"
      exit
    ;;
    "check_old_backups" | "deletebkold" | delete_old_backups)
      CARGA_GERAL
      CARGA_ESPECIFICA
      check_old_backups
      gdrive upload -p ${ID_DIR_GDRIVE} --name ${LOG_NAME_EXPORT} --delete ${LOG}
      echo "Check finalizado"
      exit
    ;;
    "s" | "-s" | "--s" | "set" | "-set" | "--set")
    echo "Ainda não implementado"
    exit
    ;;
    *)
      echo "parametro invalido"
      exit
    ;;
  esac
fi
