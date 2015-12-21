df = readRDS('MHS_CHF_Medications.RDS')

output = c()

for(i in 1:ncol(df))
{
	numNA = round((length(which(is.na(df[,i])))/nrow(df)) * 100)

	if(numNA > 0)
	{
		cat(paste("Percentage of NAs for",names(df)[i],"==",numNA,"percent\n"))
  		output = c(output,numNA)
	}
}

