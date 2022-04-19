  ####
#### Genera un archivo tabular con las fechas de las imágenes que deben ser descargadas 
#### Leandro Cara
#### Octubre 2021
#### leandrocara@hotmail.com
# setwd("/home/lean/CONICET/REPOS/SirisSnow/")
############################################
direcciones<- read.table("./.dir.txt",sep = ",",stringsAsFactors = F)

funciones<- list.files(path = "./f_apoyo/",pattern = ".R$",full.names = T)
for (i in 1:length(funciones)) 
  source (chdir =T ,file = funciones[i])


#mod   ##############################################################
dir.mod.tap  <-   paste0(direcciones[3,2],"/mod_tap/")
#myd   ##############################################################

fecha_modtap_last<- tail(corte.x(list.files(dir.mod.tap)),n=1)


fecha_base <- jd2date(fecha_modtap_last) # último día de mod-tap
# seq hasta la actualidad!
fecha1<- paste0(seq.Date(fecha_base+1,as.Date(format(Sys.Date(),"%Y-%m-%d")),by = "day"),"T00:00:00Z") 
# seq +1 hasta la actualidad!
fecha2 <- paste0(seq.Date(fecha_base+2,as.Date(format(Sys.Date(),"%Y-%m-%d")),by = "day"),"T00:00:00Z") 

write.table(as.data.frame(fecha1),"./finic.txt",col.names = F,row.names = F,quote = F)
write.table(as.data.frame(fecha2),"./ffin.txt",col.names = F,row.names = F,quote = F)
