#!/bin/sh

#VARIABLES
BUCKET_NAME="s3://qubiq-test/agroholistic/"
BUCKET_LATEST="s3://qubiq-test/latest/"
BD_NAME="prod"


DIRECTORIO_DESTINO="/tmp/odoo"
[ -d $DIRECTORIO_DESTINO ] || mkdir ${DIRECTORIO_DESTINO}



# Afijo fecha (cadena variable en funciÃ³n de la fecha a incluir en el nombre de los archivos)
AFIJO_FECHA=`date "+%F-%H%M%S"`


echo "db:*:*:odoo:odoopassword" > $HOME/.pgpass
echo "` chmod 0600 $HOME/.pgpass `"



# ------------------------------------------------------------------------------
# Cuerpo del script
# ------------------------------------------------------------------------------

# Copia de seguridad de la base de datos
FECHA=`date "+%F-%H%M%S"`
echo "[" $FECHA "] " "Exportando bases de datos..."


nice pg_dump -h db -U odoo --no-owner $BD_NAME   --file=$DIRECTORIO_DESTINO/dump.sql

mkdir $DIRECTORIO_DESTINO/filestore
chmod 777 $DIRECTORIO_DESTINO
chmod 777 $DIRECTORIO_DESTINO/filestore
cp -R /var/lib/odoo/filestore/$BD_NAME/* $DIRECTORIO_DESTINO/filestore

cd $DIRECTORIO_DESTINO
zip -r /tmp/$BD_NAME.$AFIJO_FECHA.zip .
echo "Subiendo backups al S3..."
FECHA=`date "+%F-%H%M%S"`
s3cmd put /tmp/$BD_NAME.$AFIJO_FECHA.zip $BUCKET_NAME
mv /tmp/$BD_NAME.$AFIJO_FECHA.zip /tmp/$BD_NAME.latest.zip
s3cmd put /tmp/$BD_NAME.latest.zip $BUCKET_LATEST
echo "Eliminando Archivos"
rm -R $DIRECTORIO_DESTINO/*
rm /tmp/$BD_NAME.latest.zip
