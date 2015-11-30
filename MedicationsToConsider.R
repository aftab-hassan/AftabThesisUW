#Purpose
#This script looks at the medications recommended by the Pharmacist and finds out
#medicationIDs for those medications.
#A script was required for two reasons
#1. The medication names that were given do not exactly match the names of medications in the Multicare table,
#so have to find the closest matching string
#2. The same medication name has multiple medication IDs logged against, it, so I 
#sort the frequencies in descending order and take the most frequently logged ID.
#Eg."LISINOPRIL 10 MG OR TABS" is logged with the following IDs with the following frequencies.
#12248    28360    28361    28362    35162  3001039 10099900 
#97   172493       22       69        1        5        3 

#read data
df = readRDS("EncounterOrderMedications.RDS")

#this is needed when, given a medication along with dosage, you want to find the medicationID most relevant to it
#unique won't work, since we need the frequency with which a certain ID is related to a medication name.
df = df[,c("EpicMedicationID","MedicationDSC")]

#type cast
df$MedicationDSC = as.character(tolower(df$MedicationDSC))
df$EpicMedicationID = as.character(df$EpicMedicationID)

#this is good for finding the exact name which is a combination of the {basename of medication + dosage level} 
dfunique = unique(df[,c("EpicMedicationID","MedicationDSC")])

#bases
basemedications = tolower(c('lisinopril','losartan','metoprolol tartrate','metoprolol succinate','carvedilol','furosemide','bumetanide','torsemide','metolazone','potassium chloride','spironolactone','digoxin','hydralazine','isosorbide mononitrate','isosorbide dinitrate','dobutamine','milrinone'))
dosagelevels = c('2.5 mg','10 mg','25 mg','100 mg','12.5 mg','50 mg','150 mg','200 mg','400 mg','3.125 mg','6.25 mg','20 mg','120 mg','140 mg','160 mg','1 mg','2 mg','4 mg','5 mg','30 mg','60 mg','70 mg','0.0625 mg','0.125 mg','0.25 mg','0.5 mg','75 mg','40 mg','80 mg','10meq','20meq','30meq','40meq','50meq','60meq','70meq','80meq')

#finding the exact name which is a combination of the {basename of medication + dosage level}
#df[grep("metoprolol tartrate",df$MedicationDSC)[which(grep("metoprolol tartrate",df$MedicationDSC) %in% grep("10",df$MedicationDSC))[1]],"MedicationDSC"]
MedicationIDs = c()
MedicationNames = c()

for(i in 1:length(basemedications))
{
 basemedication = basemedications[i]

 for(j in 1:length(dosagelevels))
 {
  dosagelevel = dosagelevels[j]

  MedicationWithDosage = dfunique[grep(basemedication,dfunique$MedicationDSC)[which(grep(basemedication,dfunique$MedicationDSC) %in% grep(dosagelevel,dfunique$MedicationDSC))[1]],"MedicationDSC"]
 
  if(!is.na(MedicationWithDosage))
  {
   #print(MedicationWithDosage)
 
   #given a medication with dosage, finding the medicationID most relevant to it
   MedicationID = names(sort(table(df[grep(MedicationWithDosage,df$MedicationDSC),"EpicMedicationID"]),decreasing=T))[1]
   #print(MedicationID)

   #hate this check, doesn't make sense
   #doing it since MedicationID is null here
   #wish I could just do a if(MedicationID != NULL), but R doesn't allow me.
   if(length(MedicationID) == 1)
   {
    MedicationIDs = c(MedicationIDs,MedicationID)
    MedicationNames = c(MedicationNames,MedicationWithDosage)
    cat(paste("i==",i,"j==",j,"length(MedicationIDs)==",length(MedicationIDs),"length(MedicationNames)==",length(MedicationNames),"\n"))
   }
  }
 }
}

save.image("image.RData")

#form outputdf
outputdf = data.frame(MedicationIDs,MedicationNames)
outputdf = unique(outputdf)

#save output
saveRDS(outputdf,"MedicationsToConsider.RDS")

#Please note that certain dosages of medications are removed from MedicationsToConsider.RDS by hand by looking at the mail from Jenny(pharmacist) and removing dosages that were not mentioned in mail
#The final list is saved in MedicationsToConsider.csv
