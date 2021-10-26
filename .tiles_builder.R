###### crea la lista de tiles que vamos a descargar para armar luego la serie de imágenes
### se ejecuta desde el directorio de base de los scripts
### depende de un archivo de entrada, que lo toma desde .dir
### Leandro Cara 
## leandrocara@hotmail.com  
### 20 de Octubre de 2021
library(raster)
##############################################################
d1<- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)
x <- d1[20,2]#"/home/servermod/modis/mod/"
y <- shapefile("./apoyo/grilla_modis_sudam.shp")
tabla <- read.csv("./modis/apoyo/corners_sudam.csv",header = F)
z<- intersect(x,y)
tabla <- tabla[grepl(paste(z@data$name,collapse = "|"),tabla[,1]),]
write.table(tabla,"./.tiles.txt",sep=",",col.names = F,row.names = F)
