
# cat("Este script contiene funciones útiles para procesar datos de fecha, para transformar \n
#     de julianos a Date a través de la función 'jd2date()' \n
#     y para transformar de Date a julianos a través de la función 'jd2date()'\n
#     En ambos casos solo nececito el vector de entrada donde están alojadas las fechas en uno u otro formato.\n")
# cat("También este Script posee  funciones para rellenar y filtrar series por medias móviles y otros \n")
# cat("Desarrolladas por Leandro Cara.\n")

### Leandro Cara 
### octubre 2018 
### leandrocara@hotmail.com

# La fórmula lógica que se suele usar para establecer 
# si un año es bisiesto sería cuando [p y ¬q] ó [r] es verdadera, 
# pero esta otra p y [¬q ó r] sería más eficiente.
 
############################################################################################################
jd2date <- function(columna=vector()){
t1 <- vector()
    meses<- c(0,31,59,90,120,151,181,212,243,273,304,334,365)
  for( i in 1:length(columna)){
    x <- as.numeric(columna)[i]  
    year<- as.numeric(substr(x,1,4))
    diaj <- as.numeric(substr(x,5,7))
    if((year/4==round(year/4))&((year/100!=round(year/100))|(year/400==round(year/400)))& diaj>59&diaj){
      if(diaj==60){
        dia<- 29
        mes <-2
      }else{
        dia<- (diaj-1)-meses[tail(which((diaj-1)>meses),n=1)]
        mes <-tail(which((diaj-1)>meses),n=1)
        }
    }else{
      dia<- (diaj)-meses[tail(which((diaj)>meses),n=1)]
      mes <-tail(which(diaj>meses),n=1)
    }
  
  t1[i] <- paste(year,sprintf("%02d",mes),sprintf("%02d",dia),sep="-")
  
  }
    
  return(as.Date(t1))
}
############################################################################################################
date2jd <- function(columna=vector(),format="%Y-%m-%d"){
  t1 <- vector()
  meses<- c(0,31,59,90,120,151,181,212,243,273,304,334,365)
  formato <- c("%Y-%m-%d",### año adelante
               "%d-%m-%Y")### año atrás
  
  for( i in 1:length(columna)){
    x <-columna[i]  
    if(which(format==formato)==1){
      year<- as.numeric(substr(x,1,4))
      dia<- as.numeric(substr(x,9,10))
    }else{
      year<- as.numeric(substr(x,1,4))
      dia<- as.numeric(substr(x,9,10))
    }
    mes <- as.numeric(substr(x,6,7))
    x
    if((year/4==round(year/4))&((year/100!=round(year/100))|(year/400==round(year/400)))&((mes>=3))){
      t1[i]<- paste(year,sprintf("%03d",(dia+meses[mes]+1)),sep="")
    }else{
      t1[i]<- paste(year,sprintf("%03d",(dia+meses[mes])),sep="")
    }
  }
  return(t1)
}
############################################################################################################
rcl<- function(x,y){reclassify(x, y, include.lowest=FALSE, right=NA)}
############################################################################################################
