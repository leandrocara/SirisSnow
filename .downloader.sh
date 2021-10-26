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
################### dir mod base
# 
modbase=`echo "$tabdir" | sed '7q;d'`; modbase=${modbase#*,}; modbase=${modbase%,*}

################### dir myd base
# Ruta para los ffin.txt
mydbase=`echo "$tabdir" | sed '10q;d'`; mydbase=${mydbase#*,}; mydbase=${mydbase%,*}

################### dir log
# 
log=`echo "$tabdir" | sed '17q;d'` ; log=${log#*,}; log=${log%,*}
#####################
lf=`date -I` 
cd $dirR
##########
source ./.shell_functions.sh

####
#(2) earthdata_usr
echo "Executing earthdata_usr"
earthdata_usr -y -s

echo "";echo "Obteniendo el token para la descarga del web-server de la nasa";echo ""
earthdata_token $usr $pass  > /dev/null

#### corro la función que arma la estructura
base_builder() $token


echo "Ejecutando el script armador_fechas"; echo "" ; echo "" 
### ojo con esto, hay que cambiarlo para que no borre el README
rm -f *.*
Rscript ./.armador_fechas.R > /dev/null

# j="2020-02-25"

for j in `cat $ini`
	do

fecha1=`echo $j` ## esta es la fecha del día que voy a descargar
echo "Fecha de inicio"
echo $fecha1
# fecha1=`cat $ini | sed "1q;d"`
# fecha2=`cat $fin | sed "1q;d"`

### borra la línea que ya utilizó del registro de $fin
# sed -i '1d' $fin

#echo "Fecha de fin"
#echo $fecha2
echo "#############################################################"
echo "INICIO procesamiento día: $fecha1 "
date +"%T"

# esto debo revisarlo para agregar las nuevas áreas
#h11v11#   -73,-25,-72,-24
#h12v11#   -62,-26,-61,-25
#h11v12#   -79,-36,-78,-35 	  
#h12v12#   -68,-35,-67,-34
#h12v13#   -79,-45,-78,-44
#h13v13#   -63,-45,-62,-44 
#h13v14#   -80,-56,-79,-55 
#h14v14#   -63,-56,-62,-55

#i="h11v11;-73,-25,-72,-24"
for i in `cat .tiles2.txt`
# i=`cat .tiles2.txt | sed "1q;d"`
do
i=${i#*;}

curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MOD10A1&version=6&format=GeoTIFF&time=$fecha1,$fecha1&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"		

curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MYD10A1&version=6&format=GeoTIFF&time=$fecha1,$fecha1&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"

done

##### acá ha surgido un problema que hay que resolver
if [ -e "*.zip" ]   
then 
 echo "Houston tenemos un problema!!"
 echo $fecha1 > .x.txt
 Rscript ./.apoyo.R 
 mkdir temporal
 mv *.zip ./temporal
 find . -name "*.zip" | while read filename
                         do unzip -o -d "`dirname "$filename"`" "$filename"
                        done 
 find . -print | grep -i `cat .x.txt` |  while read filename
                                          do cp -a "$filename" . 
                                         done 
 rm -R ./temporal
else 
 echo "Todo normal después de descargar las imágenes"
fi 

##### acá debería acomodarse el prblema! pero eso hay que analizarlo mejor!
#debo sabér que fecha es la que estoy ejecutando para descargar
#########################################

echo "" ;echo "Imágenes descargadas para la fecha $fecha1" 	; echo ""  ; echo "#"  ; ls | grep '.tif'		; echo "#"  ; echo "" 

x=`ls *.tif | wc -l`

if [ $x -gt 0 ]
then 
	mv MOD10A1_* $modbase
	mv MYD10A1_* $mydbase
else 
	continue
fi

rm response-header.txt

#############################################

##################################################################################################

##################################################################################################
					Hasta acá!!!!!
##################################################################################################

##################################################################################################

##################################################################################################

echo "" ;echo "Ejecutando el armador de información combinada para nieve y nubes"; echo "" 

Rscript .mod_nieve_nubes.R $dirR


######################### van un par de func acá 
img_checker wdimg.txt $fecha1 $token $modbase $mydbase $dirR	

### habría que ver de redescargar la imágen que necesito y falló. Si falla de vuelta, se descarta del mosaico!


	
########################################################################################################################################
#break
########################################################################################################################################
	########################################################################################################################################
########################################################################################################################################
########################################################################################################################################

Rscript $dirR/.mosaic_to_mxd_SCA_CCA.R 


echo "FIN procesamiento día: $fecha1" 
date +"%T"
echo "#############################################################"

done
################### elimina el token de descarga!
curl -X DELETE --header "Content-Type: application/xml" https://cmr.earthdata.nasa.gov/legacy-services/rest/tokens/$token
################

rm -f *.*



