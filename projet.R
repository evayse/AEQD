########################################################
#                   Importing data                    #
########################################################
 
setwd("/home/eva/ENSAE/EQD") # Eva
setwd("") # Matthieu
setwd("") # Julien

data = read.csv("Data.txt", sep = "", header = FALSE)
colnames(data) = c('Hed', 'Wed', 'WageM', 'Cnum', 
                   'year', 'Wage', 'Hage', 'BirthInd', '')

########################################################
#                     Libraries                       #
########################################################
library(stargazer) #LateX
library(mfx) # Library for GLM maginal effects
library(mlogit) # Library for multinomial logit


