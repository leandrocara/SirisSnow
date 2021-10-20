#####################
# VAMOS A GENERAR TRES IMÁGENES DE BASE!
# LA PRIMERA VA A SER UN CONTADOR DE NA'S
# LA SEGUNDA VA A SER UN CONTADOR DE 0
# LA TERCERA UN CONTADOR DE UNOS
# UNA VEZ QUE TENGAMOS DESARROLLADO ESTAS IMÁGENES VAMOS A VER CUAL
# ES LA PROBABILIDAD PARA CADA PIXEL DE SER UNA U OTRA COSA

mod.tap.series <- function(){

  t1 <- m()
  bNA<- as.matrix(data.frame(col1=c(2,NA,0,1),col2=c(1,1,0,0)))
  b0<- as.matrix(data.frame(col1=c(0,2,NA,1),col2=c(1,0,0,0)))
  b1<- as.matrix(data.frame(col1=c(1,2,NA,0),col2=c(1,0,0,0)))
  na20 <- as.matrix(data.frame(col1=c(2,NA),col2=c(0,0)))
  cero2na <- as.matrix(data.frame(col1=c(0,NA),col2=c(2,2)))
  na2na <- as.matrix(data.frame(col1=c(NA),col2=c(2)))
  l1 <- list(bNA,b0,b1)
  # para lmod puedo utilizar un subset con la estación del año
  #########################################################################################################
  prob <- list()
  cat("###################################\n")
  cat("###################################\n")
  cat("Procesador imágenes MOD-TAP \n")
  cat("hora de comienzo: ")
  cat(t1)
  cat("\n")
  cat("###################################\n")
  cat("###################################\n")
  cat("\n")
  cat( "Levanto la primer imagen como base\n")
  mcd <- rcl(raster(f.1(lmodmyd[1],dir.mod.myd)),na2na)
  # h <- 1;i <- 1;j <- 1
  # armo tres imágenes de base 
  cat("comienzo a procesar la imagen probabilística de base: NIEVE - SUELO - SIN DATO\n")
  nombres <- c("SIN DATO" ,"SUELO" ,"NIEVE")
  for(h in 1:3){
    cat("\n")
    print(paste("Generando máscara de probabilidad: ",nombres[h]))
    ### probabilidad de NA!
    colector <- rcl(mcd,l1[[h]])
     for( i in 2:length(lmodmyd)){
      col2 <- rcl(raster(f.1(lmodmyd[i],dir.mod.myd)),l1[[h]])
      colector <- col2+colector
      txtProgressBar(min=0,max = length(lmodmyd), initial = i,style = 3)
     }
    cat("\n")
    prob[[h]] <- (colector/length(lmodmyd))*100
  }
  # estos son los porcentajes de probabilidad de si tiene nieve o nubes o suelo
  r1<- do.call(stack,prob)
  writeRaster(r1,paste(dir.otros,"TOTAL.NA_SUELO_NIEVE_PERCENT.tif"),format="GTiff", overwrite=T)
  cat("tiempo transcurrido en generar las máscaras de probabilidad\n")
  t1[2] <- m()
  t1[3]<- f.t2(t1)
cat(t1[3])
cat("\n")
  #############################################################################################
  #############################################################################################
  # TENGO QUE ARMAR ENTONCES LA IMAGEN DE BASE PARA EL PRODUCTO MOD-TAP
  # TENGO MI IMAGEN 1 Y ADEMÁS TRES IMÁGENES DE PROBABILIDADES PARA NA SUELO O NIEVE

  # ENTONCES LA CADENA SERÍA MAS O MENOS ASÍ: P CADA PIXEL SI TENGO DATO BARBARO!,
  # SI NO TENGO DATO,
  # BUSCO EL DATO QUE NO SEA NA MAS CERCANO DENTRO DE LOS 15 DÍAS
  cat("Acotando el área a rellenar por presencia cercana\n")
  for(j in 1:15){
    masc1<- rcl(mcd,l1[[1]])
    masc2<- masc1*raster(f.1(lmod[j],dir.mod.myd))
    mcd[which(getValues(mcd)==2)] <- masc2[which(getValues(mcd)==2)]
    txtProgressBar(min=0,max = 15, initial = j,style = 3)
  }
cat("\n")

  writeRaster(mcd,paste(dir.otros,"mcd"),format="GTiff", overwrite=T)
 
  # En los lugares que no quede info, vamos a agregar info a partir de la combinación de
  # imágenes que obtuvimos de promedio
  # Vamos a hacer un stack para preservar los valores de ocurrencia de toda la imagen para No data,
  #suelo, y nieve.

  cat("Aplicando Iniciador a capa de base según\n")
  
  cat("Para cada píxel:\n # Más de 40% de presencia de nieve = NIEVE \n # Menos de 40% de presencia de nieve = SUELO \n # Mas de 99% de información perdida = SUELO \n")

  prob[[3]][which(getValues(prob[[3]])<=40)] <- 0
  prob[[3]][which(getValues(prob[[3]])>40)] <- 1
  prob[[3]][which(getValues(prob[[1]])>99)] <-0
 
  
   writeRaster(prob[[3]],paste(dir.otros,"mascara_comp"),format="GTiff", overwrite=T)
  
  # tomamos de prob3 solo los que son na de mcd
  base <- prob[[3]]*rcl(mcd,l1[[1]])
cat("Generando cada una de las imágenes MOD-TAP\n")
for( i in 1:length(lmodmyd)){
    x <- raster(f.1(lmodmyd[i],dir.mod.myd))
    y <- rcl(x,l1[[1]])
    base <- ((base*y)+rcl(x,na20))
    writeRaster(base,paste(dir.mod.tap,"/MOD_TAP.A",corte(lmodmyd[i]),".snow.tif"
    ,sep=""),format="GTiff", overwrite=T,datatype="INT1U")
    txtProgressBar(min=0,max = length(lmodmyd), initial = i,style = 3)
  }
t1[2] <- m()
t1[3] <- f.t2(t1)
cat("Proceso Finalizazo:\n Tiempo:\n")
cat(t1[3])
}

