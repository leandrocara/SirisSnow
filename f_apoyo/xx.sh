!#/bin/bash

if [ -e"*.zip" ]  
then 
 echo "Houston tenemos un problema!!"
fecha1="2019-06-19"
 echo $fecha1 > .x.txt
 Rscript ./.apoyo.R 
cat ".x.txt"
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

