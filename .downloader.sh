#!/bin/bash	
	### Snow Corver Area and Clouds Cover Area Builder/Updater MODIS Derived data base. 
clear
echo "//////////////////////////////////////////////////////////////////////////////////"
echo "---------------------------------------------------------------------------------"
echo "Snow Cover Area and Clouds Cover Area builder"
echo "Leandro Cara"
echo "leandrocara@hotmail.com"
echo "---------------------------------------------------------------------------------"
echo "/////////////////////////////////////////////////////////////////////////////////"
echo ""
echo ""
##################################################### levanto las rutas a partir de esta carpeta
SCRIPT=`realpath $0`
dirR=`dirname $SCRIPT`

tabdir=`cat $dirR/.dir.txt` # esta debe ser la única ruta importante!
ini="./.finic.txt"
fin="./.ffin.txt"
################### dir mod dataset
# 
dataset=`echo "$tabdir" | sed '5q;d'`; modbase=${dataset#*,}; modbase=${dataset%,*}

################### dir log	
# 
log=`echo "$tabdir" | sed '8q;d'` ; log=${log#*,}; log=${log%,*}
#####################
lf=`date -I` 
cd $dirR
rm *.*
########## traigo las funciones de shell! 
source ./.shell_functions.sh

####
#(2) earthdata_usr
echo "Executing earthdata_usr"
earthdata_usr -y -s

echo "";echo "Obteniendo el token para la descarga del web-server de la nasa";echo ""

earthdata_token $usr $pass  > /dev/null

#### corro la función que arma la estructura ##
base_builder 

echo "Ejecutando el script armador_fechas"; echo "" ; echo "" 
### ojo con esto, hay que cambiarlo para que no borre el README


$ rm -v !("README.MD")

Rscript ./.armador_fechas.R > /dev/null

exit
########################################################################################## 
########################################################################################## 
#### empiezo el ciclo iterativo
########################################################################################## 

echo "Iniciando con la descarga de imágenes"


var=1
m=`cat .ffin.txt | wc -l`	


###
while [  $m -gt 1 ]; do

m=`cat .ffin.txt | wc -l`

#fecha1=`echo $j` ## esta es la fecha del día que voy a descargar
echo "############################################################"
fecha1=`cat $ini | sed "$1q;d"`
fecha2=`cat $fin | sed "$1q;d"`

sed -i '1d' $fin
sed -i '1d' $ini


echo "#############################################################"
echo "INICIO procesamiento para el día: $fecha1 "
date +"%T"
####

nsidc_downloader $fecha1 $fecha2 $var; vv="$(nsidc_checker)"
var=$?

echo "################"


# acá debería acomodarse el prblema! pero eso hay que analizarlo mejor!
#debo sabér que fecha es la que estoy ejecutando para descargar
#########################################


echo "" ;echo "Imágenes descargadas para la fecha $fecha1" 	; echo ""  ; echo "#"  ; ls | grep '.tif'		; echo "#"  ; echo "" 
date +"%T"

x=`ls *.tif | wc -l`

if [ $x -gt 0 ]
then 
	mv MOD10A1_* $modbase
	mv MYD10A1_* $mydbase
else 
	continue
fi

rm response-header.txt
rm *.com
echo "" ;echo "Ejecutando el armador de información combinada para nieve y nubes"; echo "" 

Rscript .mod_nieve_nubes.R
echo "Script 		mod_nieve_nubes.R finalizado"
date +"%T"
########################################################################################################################################

Rscript .mosaic_to_mxd_SCA_CCA.R 
echo "Script  mosaic_to_mxd_SCA_CCA."
date +"%T"
date +"%T"
echo "FIN procesamiento día: $fecha1" 
date +"%T"
echo "#############################################################"

done
################### elimina el token de descarga!
curl -X DELETE --header "Content-Type: application/xml" https://cmr.earthdata.nasa.gov/legacy-services/rest/tokens/$token
################

rm -f *.*



