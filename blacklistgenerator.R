#Reading the MedicationsToConsider for the DESCRIPTION to CODE mapping
MedicationsToConsider = read.csv("MedicationsToConsider.csv")
for(i in 1:ncol(MedicationsToConsider))
{
	MedicationsToConsider[,i] = as.character(MedicationsToConsider[,i])
}

#Making the actual blacklist
blacklistenglish = read.csv("blacklistcombinations_english.csv")
for(i in 1:ncol(blacklistenglish))
{
	blacklistenglish[,i] = as.character(blacklistenglish[,i])
}

fromarray = c()
toarray = c()
for(i in 1:nrow(blacklistenglish))
#for(i in 1:1)
{
	from = blacklistenglish[i,1]
	to = blacklistenglish[i,2]

	from = MedicationsToConsider[grep(from,MedicationsToConsider$DESCRIPTION),"CODE"]
	to = MedicationsToConsider[grep(to,MedicationsToConsider$DESCRIPTION),"CODE"]

	for(j in 1:length(from))
	{
		for(k in 1:length(to))	
		{
			fromarray = c(fromarray,from[j])
			toarray = c(toarray,to[k])
		}
	}
}
outputdf = data.frame(fromarray,toarray)
write.csv(outputdf,"blacklistcombinations.csv",row.names=FALSE)
