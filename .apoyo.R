####
#### Genera un archivo tabular con las fechas de las imágenes que deben ser descargadas 
#### Leandro Cara
#### Octubre 2018
#### leandrocara@hotmail.com

############################################
# d1<- read.table("/home/leandro/server/servermod/dir.txt",sep = ",",stringsAsFactors = F)
d1<- read.table("./.x.txt",sep = ",",stringsAsFactors = F)

funciones<- list.files(path = "./f_apoyo/",pattern = ".R$",full.names = T)
for (i in 1:length(funciones)) 
  source (chdir =T ,file = funciones[i])

write.table(paste0("A",date2jd(d1)),file = ".x.txt",col.names = F,row.names = F,quote = F)

