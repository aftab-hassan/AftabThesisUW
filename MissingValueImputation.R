df = readRDS('MHS_CHF.RDS')

majority = c()

for(i in 1:ncol(df))
{
 majority[i] = names(sort(table[,i],decreasing=TRUE)[1])
}

for(i in 1:nco(df))
{
 df[which(is.na(df[,i])),i] = majority[i]
}

saveRDS(df,'MHS_CHF_MAJORITYIMPUTED.RDS')
