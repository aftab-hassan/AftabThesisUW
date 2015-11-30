#Purpose
#Appends Medication Information to the output of sql_create_chfror.R script which extracts
#socio-demographic and other clinical information
#So, run sql_create_chfror.R first and then run this script

#dsn - data source name
library("RODBC");
channel = odbcConnect(dsn="edwprod",uid="miner",pwd="m1n3th1$$");

#medications we are considering
#dfmedications = readRDS('MedicationsToConsider.RDS')
#MedicationsToConsider.csv is the final list of medications to be considered. It's got by looking at the mail from Jenny(Multicare pharmacist) and deleting certain dosages of medications that were not mentioned.
dfmedications = read.csv('MedicationsToConsider.csv')

#read MHS_CHF data, has everything except for medications
df = readRDS('MHS_CHF.RDS')

#creating columns for the medications, and setting them as 0 initially
allmedications = as.character(dfmedications$MedicationIDs)
for(i in 1:length(allmedications))
{
	columnname = paste0("MED.",allmedications[i])
	print(columnname)
	df[1:nrow(df),columnname] = 0
}

for(i in 1:nrow(df) )
#for(i in 1:100)
{
	EID = df[i,"EID"]
	cat(paste(i,".PatientEncounterID==",EID,"\n"))

	#select MedicationDSC from Encounter.OrderMedication where PatientEncounterID='42716684'
	query = paste0("select EpicMedicationID from Encounter.OrderMedication where PatientEncounterID=",EID);
	medicationIDs = as.character(sqlQuery(channel,query)$EpicMedicationID);
	medicationIDs = unique(medicationIDs[which(medicationIDs %in% dfmedications$MedicationIDs)])
	#print(medicationIDs)

	if(length(medicationIDs) > 0)
	{
		df[i,paste0("MED.",medicationIDs)] = 1;	
	}
}

#saving image, surely this has to crash
save.image("imageMedicationFlatten.RData")

#saving Medication Data set
saveRDS(df,"MHS_CHF_Medications.RDS")

#close channel
close(channel);
