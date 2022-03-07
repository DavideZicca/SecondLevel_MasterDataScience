setwd("C:/Davide/MASTER IN DATA SCIENCE/Materiale del Master/Data Analysis &
      Statistical Learning/Progetto/Progetto_in_R/Project/Airplane_Crashes_and_Fatalities_Since_1908.csv")
# DATA----> https://www.kaggle.com/saurograndi/airplane-crashes-since-1908

library(tidyverse)
library(lubridate)
library(rapportools)
library(ggplot2)
library(repr)
library(RColorBrewer)
library(factoextra)
library(gridExtra)
library(cluster)
library(plyr)

AirCrash <- read.csv('Airplane_Crashes_and_Fatalities_Since_1908.csv')
# Verifica dati duplicati
print(paste('Totale righe duplicate: ',nrow(AirCrash[duplicated(AirCrash),])))
# Verifica valori 'NA'
print(paste("Totale valori 'NA': ",sum(is.na(AirCrash))))
# Lista valori Null
Null_Values <- (sapply(AirCrash,function(x) sum(is.na(x))))
t(data.frame(Null_Values))

# Verifico i velivoli in cui non figurano valori in 'Aboard'
AirCrash[is.empty(AirCrash$Aboard),c(1,4,5,7,10,11,12)]

# Mantengo tutti i dati relarivi ai valori 'Aboard' che non sono 'NA'
AirCrash <- AirCrash[!is.empty(AirCrash$Aboard),]
# Converto i valori 'Ground NA' in 0
AirCrash$Ground[is.na(AirCrash$Ground)] <- 0

# Verifico spazi vuoti ""
Missing_Values <- (sapply(AirCrash,function(x) sum(x=="")))
(data.frame(Missing_Values))

# Converto i campi 'Date' in valori 'date'
AirCrash$Date <- as.Date(AirCrash$Date, format = "%m/%d/%Y")
# Converto i campti 'Time' in valori 'time'
AirCrash$LocalTime <- as.POSIXct(AirCrash$Time, format = "%H:%M")

# Aggiungo la colonna 'LocalHour' che è rappresentata in formato numerico
AirCrash$LocalHour <- as.numeric(format(AirCrash$LocalTime,"%H"))

# Sostituisco temporaneamente 'Local Hour NA's' con 25 per poter utilizzare la
# funzione cut
AirCrash$LocalHour <- ifelse(is.na(AirCrash$LocalHour), 25, AirCrash$LocalHour)
# Add discretized dayparts based on Local Hour
AirCrash$Daypart <- cut(AirCrash$LocalHour, breaks = c(-1,5,11,17,24,25),
                        labels = c("Notturno", "Mattina","Pomeriggio","Sera", 
                                   "Sconosciuto"))
# Reset 'NA's' in 'Local Hour'
AirCrash$LocalHour <- ifelse(AirCrash$LocalHour == 25,NA,AirCrash$LocalHour)

# Aggiungo le colonne Anno e Mese
# Il pacchetto 'lubridate' estrae 'Year' e 'Month' da 'Date' come colonne
AirCrash$Year <- (year(AirCrash$Date))
AirCrash$Month <- (month(ymd(AirCrash$Date), label = TRUE))

# Aggiungo due variabili
# Survivors: 'Aboard' - 'Fatalities'
# SurvivalRate: 'Survivors'/'Aboard'

AirCrash$Survivors <- AirCrash$Aboard - AirCrash$Fatalities
AirCrash$SurvivalRate <- AirCrash$Survivors/AirCrash$Aboard
summary(AirCrash)

fig <- function(width, heigth){
  options(repr.plot.width = width, repr.plot.height = heigth)
}

ATheme <- theme(title = element_text(size = 12, face = 'bold'),
                axis.title = element_text(size = 12),
                axis.text = element_text(size = 10),
                legend.text = element_text(size = 10))

# Grafico che mostra il numero di incidenti per anno
fig(16,10)
CrashesPerYear = ggplot(AirCrash, aes(x=Year)) + geom_bar (colour = "mediumorchid4") + 
  xlab("Anno") + ylab("Incidenti Aerei") + ggtitle("Incidenti Aerei Per Anno") + ATheme
CrashesPerYear


AC <- rbind(Survivors = aggregate(AirCrash$Survivors,by=list(AirCrash$Year),FUN =sum),
            Aboard = aggregate(AirCrash$Aboard,by=list(AirCrash$Year),FUN =sum),
            Fatalities = aggregate(AirCrash$Fatalities, by = list(AirCrash$Year), 
                                   FUN = sum))


AC$Travelers <- rownames(AC)
AC$Travelers <- gsub("[.].*","",AC$Travelers)
AC <- AC %>% dplyr::rename(Year = Group.1, Count = x)

# Grafico che mostra il numero di viaggiatori a bordo, sopravvissuti e 
# morti per anno
fig(16,10)
TravelersPerYear = ggplot(AC, aes(x=Year, y=Count, group = Travelers )) +
  geom_line(aes(colour=Travelers))  + geom_point(size = 0.2) +
  scale_colour_brewer (palette = "Dark2", labels = c("A bordo", "Vittime", 
                                                     "Sopravvissuti"))+
  xlab("Anno") + ylab("Viaggiatori") + ATheme +
  ggtitle("Incidenti Aerei con sopravvissuti e morti Per Anno")

TravelersPerYear

# Il numero totale di viaggiatori a bordo di incidenti aerei è diminuito nell'
# ultimo ventennio. Nello stesso periodo, anche le vittime sono diminuite. 

# Sopravvissuti per Anno
AC2 <- cbind(Survivors = aggregate(AirCrash$Survivors,by=list(AirCrash$Year),FUN =sum),
             Aboard = aggregate(AirCrash$Aboard,by=list(AirCrash$Year),FUN =sum))

fig(16,10)
SurvivorsPerYear = ggplot(AC2, aes(x=Survivors.Group.1, y=Survivors.x/Aboard.x)) +  
  geom_col(colour = "darkolivegreen4") + 
  xlab("Mese") + ylab("Tasso di sopravvivenza") + 
  ggtitle("Tasso di sopravvivenza annuale") + ATheme +
  scale_y_continuous(labels = scales::percent)
SurvivorsPerYear

AllAirCrash <- AirCrash

# Rimuovi incidenti in cui il 'Summary' corrispondente è vuoto
AirCrash <- AirCrash[!AirCrash$Summary == "",]

# Creo un data frame "AirClust" per contenere le variabili da usare nel
# k-means clustering

# Estraggo le variabili di interesse da 'AirCrash' in un data frame 'AirClust'
AirClustx <- AirCrash[,c(10,11,19,20)] 
# Creo valori binomiali
AirScore <- data.frame(Year = AirCrash$Year)
AirScore$Y1908_Y1929 <- ifelse(AirScore$Year > 1929,0,1)
AirScore$Y1930_Y1949 <- ifelse(between(AirScore$Year,1930,1949), 1,0 )
AirScore$Y1950_Y1969 <- ifelse(between(AirScore$Year,1950,1969), 1,0 )
AirScore$Y1970_Y1989 <- ifelse(between(AirScore$Year,1970,1989), 1,0 )
AirScore$Y1990_Y2009 <- ifelse(AirScore$Year > 1989 ,1,0)
# Li unisco ad 'AirClust'
AirClust <- data.frame(AirClustx,AirScore[,-1])
head(AirClust)

# Comincio a testare il numero di cluster con k = (3, 4, 5, 6)
set.seed(23)
k1 <- kmeans(AirClust, centers = 3, nstart = 25)
k2 <- kmeans(AirClust, centers = 4, nstart = 25)
k3 <- kmeans(AirClust, centers = 5, nstart = 25)
k4 <- kmeans(AirClust, centers = 6, nstart = 25)

# Visualizzo i risultati dei cluster
p1 <- fviz_cluster(k1, geom = "point", data = AirClust) + ggtitle("K means k=3")
p2 <- fviz_cluster(k2, geom = "point", data = AirClust) + ggtitle("K means k=4")
p3 <- fviz_cluster(k3, geom = "point", data = AirClust) + ggtitle("K means k=5")
p4 <- fviz_cluster(k4, geom = "point", data = AirClust) + ggtitle("K means k=6")

grid.arrange(p1,p2,p3,p4)

# utilizzo il kmeans e scelgo k con il 'elbow method'
fviz_nbclust(AirClust, kmeans, method = "wss") +labs(subtitle = "Elbow method")+
  geom_vline(xintercept = 3, linetype = 2) + ATheme
# Il numero ottimale di cluster è 3, secondo questo metodo

library(factoextra)
library(NbClust)

#non scalando ottengo k=4 con elbow e k=2 con silhouette 
fviz_nbclust(AirClust, kmeans, method = "silhouette")+
  labs(subtitle = "Silhouette method")
# Il numero ottimale di cluster è 2, secondo questo metodo

AirCrash <- data.frame(AirCrash,Cluster = k1$cluster)

AboardClust <- aggregate(AirCrash$Aboard, by=list(Cluster = AirCrash$Cluster),
                         FUN = mean)
AboardClustx <- aggregate(AirCrash$Aboard, by=list(Cluster = AirCrash$Cluster),
                          FUN = max)
AboardClustm <- aggregate(AirCrash$Aboard, by=list(Cluster = AirCrash$Cluster),
                          FUN = min)
DeathClust <- aggregate(AirCrash$Fatalities, by=list(AirCrash$Cluster), 
                        FUN = mean)
SurviveClust <- aggregate(AirCrash$Survivors, by = list(AirCrash$Cluster), 
                          FUN = mean)
SRateClust <- aggregate(AirCrash$SurvivalRate, by = list(AirCrash$Cluster), 
                        FUN = mean)

# Creo un data frame
PCluster <- data.frame(cbind(Cluster =AboardClust$Cluster,
                             Plane_Crashes = k1$size,Max_Aboard = AboardClustx$x,
                             Min_Aboard =AboardClustm$x, Mean_Aboard = AboardClust$x,
                             Mean_Fatalities = DeathClust$x, 
                             Mean_Survivors = SurviveClust$x, 
                             Mean_SurvivalRate = SRateClust$x))

PCluster

# uso la gap statistic
set.seed(123)
fviz_nbclust(AirClust, kmeans, nstart = 25, method = "gap_stat", nboot = 25)+
  geom_vline(xintercept = 5, linetype = 2)+
  labs(subtitle = "Gap statistic method") 
# valore basso di nboot causa eccessivo carico computazionale
# k=5 usando gap statistic