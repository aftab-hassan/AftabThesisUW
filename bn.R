combinationarray = c()
outputdf = NULL;

#this is the list of medications we're considering, excludes those medications which were not used even once
#basically, these are the medications from train.RDS
df = read.csv("MedicationsColumnsFinalCut.csv")

medicationscols = grep("MED.",names(df))
M = length(medicationscols)
totalcombinations = length(combn(c(1:M), 3))/3;

blacklist = read.csv("blacklistcombinations.csv")
for(j in 0: (totalcombinations-1) )
#for(j in 0: 100 )
{
    sequence = combn(c(1:M), 3)[((j*3)+1) : ((j+1)*3)]
    colscombinations = (grep("MED.",names(df))-1)[1] + sequence

    #initially assume this is a validcombination
    generatedcombination = names(df)[colscombinations]
    validcombination = 1;

    #check if this is a valid combination
    for(k in 1:nrow(blacklist))
    {
        from = blacklist[k,1]
        to = blacklist[k,2]
        if(from %in% generatedcombination && to %in% generatedcombination)
        {
            validcombination = 0;
            break;
        }
    }

    #for reporting
    generatedcombination = paste(generatedcombination, collapse = ':')

    if(validcombination == 1)
    {
            cat(paste("Valid combination : ",generatedcombination,"\n"))
            combinationarray = c(combinationarray,generatedcombination)
    }else
    {
            cat(paste("Not a Valid combination : ",generatedcombination,"\n"))
    }

    cat(paste("\n"))
}

ValidMedicationCombination = combinationarray
serial = c(1:length(ValidMedicationCombination))
outputdf = data.frame(serial,ValidMedicationCombination)

write.csv(outputdf,"ValidMedicationCombinations.csv",row.names=FALSE)
