#Purpose
#The Medication data has lots of NA values
#This script does the most basic missing value imputation, which is replacing with the most frequently occuring value for that column

df = readRDS("MHS_CHF_Medications.RDS")

majorityvalues = c()
for(i in 1:ncol(df))
{
	majorityvalues = c(majorityvalues,names(sort(table(df[,i]),decreasing=T)[1]))
}

for(i in 1:ncol(df))
{
	NArows = which(is.na(df[,i]))
	df[NArows,i] = majorityvalues[i]
}

saveRDS(df,"MHS_CHF_Medications_NoNA.RDS")
