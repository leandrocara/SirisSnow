    
rm(list = ls())
suppressMessages(library(raster))
suppressMessages(library(rgdal))
suppressMessages(library(sp))

############################################
direcciones<- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)
args = commandArgs(trailingOnly=TRUE)
# fecha <- "2000-03-15T00:00:00Z"
fecha <- args[1]
funciones<- list.files(path = "./f_apoyo/",pattern = ".R$",full.names = T)
for (i in 1:length(funciones)) 
  source (chdir =T ,file = funciones[i])

fecha <- date2jd(substr(fecha,1,10))


#mod   ##############################################################
dir.mod.tap  <-   paste0(direcciones[3,2],"/mod_tap/")
#myd   ##############################################################



lmod_tap <- list.files(path = dir.mod.tap,pattern = ".tif$")

### el día siguiente a la última fecha mod-tap procesada
mod_tap <- lmod_tap[length(lmod_tap)]
lmod_tap <- jd2date(corte(lmod_tap[length(lmod_tap)]))
## watch dog (if the next image to procces is less than 4 days to actual date)
wd <-(as.Date(format(Sys.time(), "%Y-%m-%d"))-lmod_tap<=4)
if(wd){
  cat("No hay imágenes cercanas a la fecha actual")
  write("","exit.wd")
  quit(save = "no",status = 1)
}

base<- raster(paste0(dir.mod.tap,"/",mod_tap))

cat("No se ha generado información nueva para crear MOD TAP \n")
cat("Pero hay más de 4 días de información faltante por lo que se genera un a imagen de base\n")
cat(paste0("imagen de base utilizada: ",mod_tap,"\n imagen a generar: ",
"MOD_TAP.A",fecha,"_MISSING_snow\n"))

  writeRaster(base,paste0(dir.mod.tap,"/MOD_TAP.A",fecha,"_MISSING_snow.tif"),
              format="GTiff", overwrite=T,datatype="INT1U")
  

cat("Proceso MOD-TAP Finalizado\n")


