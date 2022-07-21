#!/bin/sh
export HORARIO=$(date +%y-%m-%d.%H.%M)
export ID_DIR_GDRIVE="1M40tz-AjIPcIxEsZOU7mJ9OQm28IoUiR"
export DIR_MINECRAFT_MAP="${HOME}/.minecraft/saves"
export TARGZ_TEMP="/tmp/minebackup.tar.gz"
export PROCESS_NAME="minecraft-launcher"
export LOG="/tmp/${HORARIO}.log"

backup(){
	echo "****************************************************INICIANDO BACKUP**************************************************" >> ${LOG}
	if pidof -x "${PROCESS_NAME}"; then
		echo "Game em executação no momento, nao foi possivel realizar backup no momento" >> ${LOG}
	else
		echo "****************************************************COMPACTANDO MAPAS**************************************************" >> ${LOG}
		tar -czvf ${TARGZ_TEMP} ${DIR_MINECRAFT_MAP} >>${LOG}
		gdrive upload -p ${ID_DIR_GDRIVE} --name ${HORARIO}.tar.gz ${TARGZ_TEMP} >>${LOG}
		echo "************************************************BACKUP FINALIZADO**********************************************" >> ${LOG}
		gdrive upload -p ${ID_DIR_GDRIVE} --name ${HORARIO}.log ${LOG} >/dev/null
	fi
}

backup
