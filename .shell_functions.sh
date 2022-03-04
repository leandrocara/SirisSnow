#!/bin/bash

#### Leandro Cara
#### leandrocara@hotmail.com	
#### Ocutbre 2021

nsidc_downloader()
{
### lo primero que tengo que hacer es tirar una búsqueda para ver cuantas imágenes tengo para descargar

for i in `cat .tiles.txt`
do

var=`cat .var.txt`
echo $var
if [ $var -gt 0 ]

then 
echo $1
echo $2
curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MOD10A1&version=6&format=GeoTIFF&time=$1,$2&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"		
##
curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MYD10A1&version=6&format=GeoTIFF&time=$1,$2&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"
else
curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MOD10A1&version=6&format=GeoTIFF&time=$1,$1&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"		
##
curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MYD10A1&version=6&format=GeoTIFF&time=$1,$1&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"
fi
done

}


#####
nsidc_checker()
{

var=`cat .var.txt`
imgzip=(`find ./ -maxdepth 1 -name "*.zip"`)
imgtif=(`find ./ -maxdepth 1 -name "*.tif"`)

### se entiende que si tengo zip es porque var es 1
if [ ${#imgzip[@]} -gt 0 ]; then 
echo "detectado problema con la descarga de imágenes "
echo "imágenes acopladas en un solo archivo comprimido"
echo 0 > .var.txt
echo $1 > .x.txt
####
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

elif [ ${#imgtif[@]} -eq 0 ] && [ $var -eq 0 ]; then 
echo 1 > .var.txt
 bash .downloader.sh
 else 
 echo "Imágenes descargadas normalmente"

fi 

}

#############
base_builder()
{

### chequeo que existan los directorios de modis
### si no exixten:


#### chequeo si existe el dataset
if [ -d "$dataset" ]
 then
### chequeo que existan imágenes en el área de estudio!
echo "Existe la base de datos"

else
	mkdir $dataset
fi 


for i in "${base[@]}"
do
	if [ -d "$dataset$i" ]
	then 
		echo "fichero $dataset$i existe"
	else
		 mkdir $dataset$i
	fi			
done

### generé los directorios 

### chequeo existencia de imágenes!
local x=$dataset${base[6]}"MOD_TAP.A2000055_snow.tif"

if [[ -f "$x" ]]; then
echo "Existe información dentro de las carpetas!"
 ### información previamente generada!
 ### salgo 
else
echo "########################################"
echo "NO se encuentra información previa en el sistema"
echo "GENERO LA BASE DE LAS IMÁGENES!"

Rscript .tiles_builder.R

local fecha1=2002-04-19
local fecha2=2002-04-20

for i in `cat .tiles.txt`
do
curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MOD10A1&version=6&format=GeoTIFF&time=$fecha1,$fecha2&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"		
done

mv MOD10A1_* $datasets${base[2]}
rm response-header.txt

### acá armo todas las bases en función de esta imágen: 
### le doy nomrbe a las imágenes con un archivo de apoyo

Rscript .armador_bases_img.R

fi

}

####

dataset_build () 
{
# dataset_build
### $1 es la ruta de la lista de las subcarpetas para el data set! 

## $2 es la dirección de donde tiene que buscar el dataset!
### puede ser un enlace duro o suave: por ahora vamos a usar un enlace suave
for i in `cat $1`
do 
	if [ -e $2$i ]
	then  
		echo -n ""
	else
		echo "Folder  $i does not exist" 
		mkdir $2$i
	fi
done
	if [ -e .././tmp/ ]
	then  
	local x=`ls .././tmp/ -p | grep -v /`
	echo ""; echo "Erasing temporal files"
	for i in $x ; do echo -n "" ;  rm -f .././tmp/$i
	 done
		echo -n ""
	else
		echo
		mkdir .././tmp/
	fi
}

# earthdata_usr

earthdata_token () {
##################################### obtiene el token para la descarga
curl -X POST --header	 "Content-Type: application/xml" -d "<token><username>$1</username><password>$2</password><client_id>zurdito</client_id><user_ip_address>192.168.0.1</user_ip_address></token>"  https://cmr.earthdata.nasa.gov/legacy-services/rest/tokens > token.xml
token=` cat token.xml | sed '3q;d'`
token=`echo ${token#*<id>}`;token=`echo ${token%</id>*}`
###########################################

}

earthdata_usr () {																																							# earthdata_usr

if [ -e ./.usr.txt ]
then  
	case $1 in
	-Y|-y)
	autentication=`cat "./.usr.txt"`
	usuario=`echo "$autentication" | sed '1q;d'`
	contra=`echo "$autentication" | sed '2q;d'`
		echo "";;
	*)
		echo "Se ha encontrado un usuario de Earthdata la generación/actualización de esta base de
					datos desea modificarlo?"
		read sino
		case $sino in
		Y|y|s*|S*|t|T)

			echo "Tenga en cuenta que el sistema no hará un chequeo automático, por lo cual asegúrese de ingresar bien sus datos"
			echo "Ingrese por favor el nuevo usr and password"
			echo -n "user:"
			read usuario
			echo ""
			echo -n "password:"
			read -s contra
			echo ""
			echo "$usuario" > ./.usr.txt
			echo "$contra" >> ./.usr.txt ;;
		N*|n*)
		echo "continuando con el procesamiento";;
		esac 
	esac
else
echo "NO se ha encontrado un usuario de Earthdata la generación/actualización de esta base de
datos"
echo "Por favor ingrese un  usuario autorizado por Earthdata. 
(si desea generar un nuevo usuario, diríjase a  www.earthdata.com)" 

echo -n "user:"
read usuario
echo ""
echo -n "password:"
read -s contra
echo ""
echo "$usuario" > ./.usr.txt
echo "$contra" >> ./.usr.txt
fi
	case $2 in
	-s)
		echo -n "";;
	*)
rm ./.usr.txt;;
esac	
usr=$usuario
pass=$contra
}


index_per_date () {																																																			# index_per_date
existence=0
check_connection $6
	wget --no-check-certificate --user=$1 --password=$2 $5/$3/$4/ -O `echo $4.txt` -o /dev/null 

local data=`cat $4.txt`
local data=`echo -n $data | sed '1q;d' | wc -c`

if [ "$data" -gt 2 ]
 then
echo " Searching availables images for this day" ; echo "" 
	Rscript .././functions/pool_data.R `echo $4.txt`

if test -f "$4.txt"
 then
echo -n ""
existence=1
fi
else
echo " There is no information for this day day in NASA DBs"
echo ""
fi
}


img_downloader() 
{

# img_downloader
check_connection $9
if [ "$existence" -eq 1 ] 
then 
wget --no-check-certificate --user=$1 --password=$2 $8/$3/$4/$5 -O `echo $5` -o /dev/null
# corro el modulo resample para trasnformar los mosaicos
$6/resample -i $5  -o ${5%.hdf}.tif -p .././support/$7 > /dev/null
rm $5
fi
}

mosaicking_nd_resample () 
{
# mosaicking_nd_resample
if [ $4 -ne 0 ]
then 
img=`ls .././tmp | egrep  '*.tif' | head -1 | cut -c 1-16`
python .././functions/gdal_merge.py -o $img.tif -n 255 -a_nodata 255 -init 255 -ot 'Byte' `ls *.tif` 
echo "writting fractional Snow Cover"
Rscript .././functions/fsc_resample.R $img.tif $1 $2 $5

rm *.tif
else
echo "No Images for $3 in this day"
fi
}  
 
sca_cca_builder() {	
# sca_cca_builder
if [ $4 -ne 0 ]
then 
Rscript .././functions/sca_nd_cca.R $1 $2 $3
else
echo ""; echo "Invalid $2 image for $3 date"; echo ""
fi
}

mod_myd_builder () {
# mod_myd_builder
if [ $2 -ne 0 ] ||  [ $3 -ne 0 ]
then 
Rscript .././functions/mod_myd_combination.R $1 $2 $3 $4
else 
echo "" ; echo "Imposible to build a MOD - MYD combination per day $4
 because images inexistence"
fi
}


mod_tap_builder() 
{
	# mod_tap_builder
### este trabaja con una base:
if [ ! -f .././support/modtap_base.tif ]
then 
echo "Building MOD-TAP-base"
Rscript .././functions/mod_tap_base_builder.R $1
fi

Rscript .././functions/mod_tap_builder.R $1 $2

}

######
check_connection () 

{
local prueba=0
local cond="--stand-alone"

while [ $prueba -eq 0 ]
do
wget -q --spider http://google.com
if [ $? -eq 0 ]; then
local prueba=1
else
 if [[ "$1"  ==  "$cond" ]]; then 
echo "Internet connection lost, waiting 1 minute an trying again"
date 
sleep 1m
else 
echo "Internet connection lost, exiting script"
exit 1
fi 
fi
done
}


fileSize() {
  local optChar='c' fmtString='%s'
  [[ $(uname) =~ Darwin|BSD ]] && { optChar='f'; fmtString='%z'; }
  stat -$optChar "$fmtString" "$@"
}


img_checker() {
wdimg=$6/$1
while test -f "$wdimg"; do
echo "Se detectaron errores en una imagen, chequeando.."
#### vamos a probar de descargar nuevamente la imagen y correr again el script de R 
local x=`cat $wdimg` 
local y=${x%;*}
local z=${x#*;}
#### tengo que enconrtar el boundingbox 
local z=`cat .tiles.txt | sed "$z q;d"`
local x=${z#*;}
local z=${z%;*}

curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=$y&version=6&format=GeoTIFF&time=$2,$2&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$x&token=$3&email=name@domain.com"
x2=`find ./ \( -name "$y*" -and -name "*$z*" \)`

if [ `find $4/ \( -name "$y*" -and -name "*$z*" \) | wc -l` -eq 1 ]; then 

	echo "MOD10A1"
	x=`find $4/ \( -name "$y*" -and -name "*$z*" \)`
	if (( $(fileSize $x) != $(fileSize $x2) )); then
		echo "Error posible generado en la descarga"
		mv $x2 $4
	else 
		echo "Error posible en la imagen original, por lo cual se descarta"
		rm $x 
		rm $x2
	fi
else
	x=`find $5/ \( -name "$y*" -and -name "*$z*" \)`
	echo "MTD10A1"
	if (( $(fileSize $x) != $(fileSize $x2) )); then
		echo "Error posible generado en la descarga"
		mv $x2 $5
	else 
		echo "Error posible en la imagen original, por lo cual se descarta"
		rm $x 
		rm $x2
	fi
fi
Rscript .mod_nieve_nubes.R $6
done
}
#### la dejo al final porque me cambia el color de todo el texto!

dates_builder () 																																																	# dates_builder
{
check_connection $7
wget --no-check-certificate --user=$1 --password=$2 $3/$4 -o /dev/null 
echo > ./dates.csv
local cond=\[DIR\]
while read -r line; do 
if [[ "$line" == *"$cond"* ]]
then 
local x=`echo $line` 
local x=`echo ${x#*[0-9]/\"\>*}` 
local x=`echo ${x#*[0-9]/\"\>*}` 
local x=`echo ${x%/\</a\>*}` 
echo $x >> dates.csv
fi
done < index.html
Rscript .././functions/dates_sequence.R $5 $6 
}



