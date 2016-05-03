#!/bin/bash

USER="admin_user"
PASS="superman22"
BASE="musicdb_test"
DIR="/home/sophia/uasb_DBA-master"
FECHA=`date +%d-%m-%Y`

echo "Hora del backup: `date +%H:%M:%S`" >> $DIR/musicdb_test[$FECHA].log

ESPACIO_OCUPADO=`df /$DIR | awk '{print $5}' | grep -a %
ESPACIO_OCUPADO=`expr match “$ESPACIO_OCUPADO” '\([0-9]*[0-9]\)'`

if [ $ESPACIO_OCUPADO -le 85 ];
then
	for BASE in $BASE
do
	mysqldump -u $USER -p$PASS $BASE --opt > $DIR/musicdb_test_$indice[$FECHA].sql
	((indice++))
done

indice=1
for indice in 1 2
do
	tar -czvf $DIR/musicdb_test_$indice[$FECHA].sql.tar.gz $DIR/musicdb_test_$indice[$FECHA].sql >> $DIR/musicdb_test[$FECHA].log
done

for indice in 1 2
do
	if [ -f $DIR/musicdb_test_$indice[$FECHA].sql ]; #verificamos si se realizo la copia de respaldo
	then
		if [ -f $DIR/musicdb_test_$indice[$FECHA].sql.tar.gz ]; #verificamos si se comprimió.
		then
			find $DIR/musicdb_test* -mtime +15 -exec rm -r -f {} \;
		else
			echo "Compresión de la copia de respaldo realizado $FECHA no se ha podido realizar. Se mantiene almacenado la compresión de la anterior copia de respaldo" >> $DIR/musicdb_test[$FECHA].log
	fi
	else
		echo "La copia de respaldo del día $FECHA no se ha podido llevar a cabo, por algún problema. Se
mantiene almacenado la copia de respaldo anterior" >> $DIR/musicdb_test[$FECHA].log
	fi
done
echo "Hora de finalización de la copia de respaldo: `date +%H:%M:%S`" >> $DIR/base_datos[$FECHA].log
