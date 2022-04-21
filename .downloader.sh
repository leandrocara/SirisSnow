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

### lista de subdirectorios para ir armando la info de base
tabdir=`cat $dirR/.dir.txt` # esta debe ser la única ruta importante!

# Temporales para armar la secuencia de descarga 
ini="./finic.txt"; fin="./ffin.txt"

## Subdirectorios de los subprouctos MODIS
base=("/mod/" "/c_mod/" "/mod10base/" "/myd/" "/c_myd/" "/myd10base/" "/mod_tap/" "/mod_myd/" "/c_mod_myd_max/" "/c_mod_myd_min/" "/mod_fsc/" "/myd_fsc/")

################### dir modis base
dataset=`echo "$tabdir" | sed '3q;d'`; dataset=${dataset#*,}; dataset=${dataset%,*}


lf=`date -I` 
cd $dirR
rm -f *.*

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

rm -rf $dataset${base[2]}
rm -rf $dataset${base[5]}
mkdir $dataset${base[2]}
mkdir $dataset${base[5]}


echo "Ejecutando el script armador_fechas"; echo "" ; echo "" 
### ojo con esto, hay que cambiarlo para que no borre el README
echo $token

Rscript ./.armador_fechas.R > /dev/null
########################################################################################## 
########################################################################################## 
#### empiezo el ciclo iterativo
########################################################################################## 

echo "Iniciando con la descarga de imágenes"
# var es la diferencia en días para fechas, el sistema tiene un error de base que levanta algunas veces dos imágenes
# para un var=1 y una imagen para var=0, y en otras portunidades levanta 1 imágen para var=1 y 0 para var=0
# var debería estar en un archivo para que cuando se ejecute, el script tenga guardado el resultado anterior.  
# debería ser fractal, si corre con var=1 => zip, reescribe var=0 y continua, 
# si  var=0 => img=0, pasa a var 1 y corre de vuelta. 
# si con var 1 no levanta nada, escribe var 0 y sale. 
# por lógica debería arrancar con 0 a menos que se haya abortado

m=`cat ffin.txt | wc -l`	

while [ $m -gt 1 ]; do

m=`cat ffin.txt | wc -l`

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
### acá tendría que poner un chequeo de conexión
### revisar estas dos funciones, porque no debería tener diferencias a partir de ahora!
check_connection --stand-alone
nsidc_downloader $fecha1 $fecha2 $var
nsidc_checker $fecha1

echo "################"


# acá debería acomodarse el prblema! pero eso hay que analizarlo mejor!
#debo sabér que fecha es la que estoy ejecutando para descargar
#########################################


echo "" ;echo "Imágenes descargadas para la fecha $fecha1" 	; echo ""  ; echo "#"  ; ls | grep '.tif'		; echo "#"  ; echo "" 
date +"%T"
		
x=`ls *.tif | wc -l`

if [ $x -gt 0 ]
then 
	mv MOD10A1_* $dataset${base[2]}
	mv MYD10A1_* $dataset${base[5]}
else 
	echo "No se han obtenido imágenes para la fecha $fecha1\n se procede a armar la capa mod_tap de reemplazo"
	Rscript .null_to_mod_tap.R $fecha1	
	x="exit.wd"
	if [[ -f "$x" ]]; then
	echo "dada la cercanía de la fecha de análisis con la fecha actual, se procede a no armar imagen MOD_TAP" 
		exit 1
	else
		continue
	fi

rm response-header.txt
rm *.com
rm *.xml
echo "" ;echo "Ejecutando el armador de información combinada para nieve y nubes"; echo "" 

##################################################################
echo " corro el script mod nieve_nubes"

Rscript .mod_nieve_nubes.R
echo "Script mod_nieve_nubes.R finalizado"
date +"%T"
########################################################################################################################################

Rscript .mosaic_to_mxd_SCA_CCA.R $fecha1 
echo "Script  mosaic_to_mxd_SCA_CCA."
date +"%T"
date +"%T"
echo "FIN procesamiento día: $fecha1" 
date +"%T"
echo "#############################################################"
done
################### elimina el token de descarga!
curl -X DELETE --header "Content-Type: application/xml" https://cmr.earthdata.nasa.gov/legacy-services/rest/tokens/$token
###############
rm -f *.*
exit 0



