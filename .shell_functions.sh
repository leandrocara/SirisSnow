#!/bin/bash

#### Leandro Cara
#### leandrocara@hotmail.com	
#### Ocutbre 2021

nsidc_downloader()
{
### lo primero que tengo que hacer es tirar una búsqueda para ver cuantas imágenes tengo para descargar
echo "Downloading MOD10A1 and MYD10A1" 
echo "From $1 to $2"

for i in `cat .tiles.txt`
do

var=`cat .var.txt`
if [ $var -gt 0 ]
then 
echo "Ingresando con VAR == $var " 
echo "Intervalo de descarga: $1 a $2"
curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MOD10A1&version=6&format=GeoTIFF&time=$1,$2&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"		

curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MYD10A1&version=6&format=GeoTIFF&time=$1,$2&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"
	
else
echo "Ingresando con VAR == $var " 
echo "Intervalo de descarga: $1 a $1"
curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MOD10A1&version=6&format=GeoTIFF&time=$1,$1&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"		

curl -O -J --dump-header response-header.txt "https://n5eil02u.ecs.nsidc.org/egi/request?short_name=MYD10A1&version=6&format=GeoTIFF&time=$1,$1&Subset_Data_layers=/MOD_Grid_Snow_500m/NDSI_Snow_Cover&projection=Geographic&bounding_box=$i&token=$token&email=name@domain.com"
fi
done
}


#####
nsidc_checker()
{
### IMG Downloading problem checker

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

# tomo base del global!
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

mv MOD10A1_* $dataset${base[2]}
rm response-header.txt

### acá armo todas las bases en función de esta imágen: 
### le doy nomrbe a las imágenes con un archivo de apoyo

Rscript .armador_bases_img.R

fi

}

########
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

####
earthdata_token () {
##################################### obtiene el token para la descarga
curl -X POST --header	 "Content-Type: application/xml" -d "<token><username>$1</username><password>$2</password><client_id>zurdito</client_id><user_ip_address>192.168.0.1</user_ip_address></token>"  https://cmr.earthdata.nasa.gov/legacy-services/rest/tokens > token.xml
token=` cat token.xml | sed '3q;d'`
token=`echo ${token#*<id>}`;token=`echo ${token%</id>*}`
###########################################

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
echo "internet works"
else
 if [[ "$1"  ==  "$cond" ]]; then 
echo "Internet connection lost, waiting 1 minute and trying again"
date 
sleep 1m
else 
echo "Internet connection lost, exiting script"
exit 1
fi 
fi
done
}




