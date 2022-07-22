#!/bin/sh
export HORARIO=$(date +%y-%m-%d.%H.%M)
export ID_DIR_GDRIVE="1M40tz-AjIPcIxEsZOU7mJ9OQm28IoUiR"
export DIR_MINECRAFT_MAP="${HOME}/.minecraft/saves"
export TARGZ_TEMP="/tmp/minebackup.tar.gz"
export PROCESS_NAME="minecraft-launcher"
export LOG="/tmp/${HORARIO}.log"
export RETENCAO_DATA=$(date +%Y-%m-%d --date "7 days ago")
#source ./main.sh

backup(){
	echo "***************************************************INICIANDO BACKUP***************************************************" >> ${LOG}
	if pidof -x "${PROCESS_NAME}"; then
		echo "Game em executação no momento, nao foi possivel realizar backup" >> ${LOG}
	else
		echo "***************************************************COMPACTANDO MAPAS***************************************************" >> ${LOG}
		tar -czvf ${TARGZ_TEMP} ${DIR_MINECRAFT_MAP} >>${LOG}
		echo "***********************************************ENVIANDO PARA GOOGLE DRIVE**********************************************" >> ${LOG}
		gdrive upload -p ${ID_DIR_GDRIVE} --name ${HORARIO}.tar.gz --delete ${TARGZ_TEMP} >>${LOG}
	fi
}

delete_old_backups(){
	if awk '$7 > "${RETENCAO_DATA}" {print $1}'; then
		echo "***************************************************DELETANDO BACKUPS COM MAIS DE 7 DIAS***************************************************" >> ${LOG}
		gdrive list | awk '$7 <= "${RETENCAO_DATA}" {print $1}' | xargs gdrive delete >>${LOG}
	fi
}

backup
delete_old_backups
echo "***************************************************BACKUP FINALIZADO***************************************************" >> ${LOG}
gdrive upload -p ${ID_DIR_GDRIVE} --name ${HORARIO}.log --delete ${LOG} >/dev/null
echo "Backup finalizado"
