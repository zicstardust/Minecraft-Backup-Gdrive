#!/bin/sh
export HORARIO=$(date +%y-%m-%d.%H.%M)
export ID_DIR_GDRIVE="1M40tz-AjIPcIxEsZOU7mJ9OQm28IoUiR"
export DIR_MINECRAFT_MAP="${HOME}/.minecraft/saves"
export TARGZ_TEMP="/tmp/minebackup.tar.gz"
export PROCESS_NAME="minecraft-launcher"
export LOG="/tmp/${HORARIO}.log"
export RETENCAO_DATA=$(date +%Y-%m-%d --date "7 days ago")
export NAME_DIR_DRIVE=$(gdrive list | awk '$1 == "${ID_DIR_GDRIVE}" {print $2}')
#source ./main.sh

backup(){
	echo "***************************************************INICIANDO BACKUP***************************************************" >> ${LOG}
	if pidof -x "${PROCESS_NAME}" >/dev/null; then
		echo "Game em executação no momento, nao foi possivel realizar backup" >> ${LOG}
	else
		echo "***************************************************COMPACTANDO MAPAS***************************************************" >> ${LOG}
		tar -czvf ${TARGZ_TEMP} ${DIR_MINECRAFT_MAP} >>${LOG}
		echo "***********************************************ENVIANDO PARA GOOGLE DRIVE**********************************************" >> ${LOG}
		gdrive upload -p ${ID_DIR_GDRIVE} --name ${HORARIO}.tar.gz --delete ${TARGZ_TEMP} >>${LOG}
	fi
}

delete_old_backups(){
	echo "***************************************************DELETANDO BACKUPS ANTIGOS***************************************************" >> ${LOG}
	if  gdrive list --absolute | awk '$2 ~ /${NAME_DIR_DRIVE}/ && $3 == "bin" && $6 <= "${RETENCAO_DATA}" {print $1}' >/dev/null; then
		if gdrive list --absolute | awk '$2 ~ /${NAME_DIR_DRIVE}/ && $3 == "bin" && $6 > "${RETENCAO_DATA}" {print $1}' >/dev/null; then
			gdrive list --absolute | awk '$2 ~ /${NAME_DIR_DRIVE}/ && $3 == "bin" && $6 <= "${RETENCAO_DATA}" {print $1}' | xargs gdrive delete >>${LOG}
		else
			echo "Não existem backups mais recentes que ${RETENCAO_DATA}, não serao apagado os backups antigos" >> ${LOG}
		fi
		echo "Não exixtem backups anteriores a ${RETENCAO_DATA} para deletar" >> ${LOG}
	else
	fi
}

#MAIN FUNCTION
backup
delete_old_backups
echo "***************************************************BACKUP FINALIZADO***************************************************" >> ${LOG}
gdrive upload -p ${ID_DIR_GDRIVE} --name ${HORARIO}.log --delete ${LOG}
echo "Backup finalizado"
