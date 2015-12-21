traindf = readRDS('traindf.RDS')

layer1 = c('EJV','hf_primary','second_nonhf_cnt','risk_mortality','severity_ill','followup','sys_BP','dia_BP','ave_BP','pulse','resprate','birth','destination','admit_src','admit_type','discharge_sts','marital','ethnic','chf','thirty_cnt')
layer2 = c('hemoglobin','hematocrit','neutrophils','sodium','glucose','nitrogen','creatinine','comp_diabetes','stroke','coronary_syn','arrhythmia','cardio_fail','rheumatic','vascular_disease','atherosclerosis','other_hdisease','paralysis','renal_fail','copd','fluid_disorder','urinary','ulcer','gastro','peptic_ulcer','hematological','nephritis','dementia','solid_tumor','cancer','liver_disease','end_renal','asthma','anemia','pneumonia','drug_alcohol','major_psych','depression','other_psych','lung','malnutrition','gender','myocardial','cerebro','peripheral','uncomp_diabetes','hiv_aids','connect_tissue','cost','LOS')
layer3 = names(traindf)[grep("MED.",names(traindf))]
layer4 = c('thirtyday','seven_LOS','twelve_mortality')

fromarray = c()
toarray = c()

#within same level
for(i in 1:4)
{
        if(i == 1)
                layerhere = layer1
        else if(i == 2)
                layerhere = layer2
        else if(i == 3)
                layerhere = layer3
        else if(i == 3)
                layerhere = layer4

        for(j in 1:length(layerhere))
        {
                from = layerhere[j]

                for(k in 1:length(layerhere))
                {
                        to = layerhere[k]

                        if(from != to)
                        {
                                fromarray = c(fromarray,from)
                                toarray = c(toarray,to)
                        }
                }
        }
}

#downwards
#1 to 3
for(i in 1:length(layer1))
{
        from = layer1[i]

        for(j in 1:length(layer3))
        {
                to = layer3[j]

                if(from != to)
                {
                        fromarray = c(fromarray,from)
                        toarray = c(toarray,to)
                }
        }
}

#1 to 4
for(i in 1:length(layer1))
{
        from = layer1[i]

        for(j in 1:length(layer4))
        {
                to = layer4[j]

                if(from != to)
                {
                        fromarray = c(fromarray,from)
                        toarray = c(toarray,to)
                }
        }
}

#2 to 4
for(i in 1:length(layer2))
{
        from = layer2[i]

        for(j in 1:length(layer4))
        {
                to = layer4[j]

                if(from != to)
                {
                        fromarray = c(fromarray,from)
                        toarray = c(toarray,to)
                }
        }
}

#upwards
#2 to 1
for(i in 1:length(layer2))
{
        from = layer2[i]

        for(j in 1:length(layer1))
        {
                to = layer1[j]

                if(from != to)
                {
                        fromarray = c(fromarray,from)
                        toarray = c(toarray,to)
                }
        }
}

#3 to 1 
for(i in 1:length(layer3))
{
        from = layer3[i]

        for(j in 1:length(layer1))
        {
                to = layer1[j]

                if(from != to)
                {
                        fromarray = c(fromarray,from)
                        toarray = c(toarray,to)
                }
        }
}

#3 to 2
for(i in 1:length(layer3))
{
        from = layer3[i]

        for(j in 1:length(layer2))
        {
                to = layer2[j]

                if(from != to)
                {
                        fromarray = c(fromarray,from)
                        toarray = c(toarray,to)
                }
        }
}

#4 to 1
for(i in 1:length(layer4))
{
        from = layer4[i]

        for(j in 1:length(layer1))
        {
                to = layer1[j]

                if(from != to)
                {
                        fromarray = c(fromarray,from)
                        toarray = c(toarray,to)
                }
        }
}

#4 to 2
for(i in 1:length(layer4))
{
        from = layer4[i]

        for(j in 1:length(layer2))
        {
                to = layer2[j]

                if(from != to)
                {
                        fromarray = c(fromarray,from)
                        toarray = c(toarray,to)
                }
        }
}


#4 to 3
for(i in 1:length(layer4))
{
        from = layer4[i]

        for(j in 1:length(layer3))
        {
                to = layer3[j]

                if(from != to)
                {
                        fromarray = c(fromarray,from)
                        toarray = c(toarray,to)
                }
        }
}

from = fromarray
to = toarray
outputdf = data.frame(from,to)

write.csv(outputdf,'blacklist_bayesiannetwork.csv',row.names=FALSE)
