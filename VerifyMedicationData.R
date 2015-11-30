#Purpose
#This script verifies data extracted into MHS_CHF_Medications.RDS with SQL data, to make sure that the medications which
#have a boolean 1 against them are indeed the medications that were prescribed to the patient.

#To run the script
#Rscript VerifyMedicationData.R

#Expected output of script
# Serial :  1 EID :  41902891  : Test passed
# Serial :  2 EID :  42462655  : Test passed
# Serial :  3 EID :  42502072  : Test passed
# Serial :  4 EID :  42531602  : Test passed
#..
#..
# Serial :  74006 EID :  108575389  : Test passed
# Serial :  74007 EID :  108581394  : Test passed
# Serial :  74008 EID :  108585785  : Test passed
# Serial :  74009 EID :  108636427  : Test passed
# >
# > #Summary/Report
# > cat(paste0("Tests passed == ",passed, "/",nrow(df)," ,Tests failed == ",failed,"/",nrow(df),"\n"))
# Tests passed == 74009/74009 ,Tests failed == 0/74009
# >
# > #close channel
# > close(channel)

#reading in data
dfmedications = read.csv('MedicationsToConsider.csv')
df = readRDS("MHS_CHF_Medications.RDS")

#RODBC - database connectivity
library("RODBC");
channel = odbcConnect(dsn="edwprod",uid="miner",pwd="m1n3th1$$");

#test counters
passed = 0;
failed = 0;

for(i in 1:nrow(df))
#for(i in 1:100)
{
	#extracted data
	MedicationIDsfromExtracteddata = which(df[i,grep("MED.",names(df))] == 1)
	if(length(MedicationIDsfromExtracteddata) > 0)
	{
		MedicationIDsfromExtracteddata = names(df)[grep("MED.",names(df))][MedicationIDsfromExtracteddata]
		MedicationIDsfromExtracteddata = sort(MedicationIDsfromExtracteddata)
	}
	MedicationIDsfromExtracteddata = as.character(MedicationIDsfromExtracteddata)

	#reading in data from SQL again for verifying
	EID = df[i,"EID"]
	query = paste0("select EpicMedicationID from Encounter.OrderMedication where PatientEncounterID=",EID);
	MedicationIDsfromSQL = as.character(sqlQuery(channel,query)$EpicMedicationID);
	MedicationIDsfromSQL = unique(MedicationIDsfromSQL[which(MedicationIDsfromSQL %in% dfmedications$MedicationIDs)])
	if(length(MedicationIDsfromSQL) > 0)
	{
		MedicationIDsfromSQL = paste0("MED.",MedicationIDsfromSQL)
		MedicationIDsfromSQL = sort(MedicationIDsfromSQL)
	}
	
	#checking if the medications taken are the same in extracted data and in SQL
	if(identical(MedicationIDsfromSQL,MedicationIDsfromExtracteddata) == TRUE)
	{
		cat(paste("Serial : ",i,"EID : ",EID," : Test passed\n"))
		passed = passed + 1;
	}
	else
	{
		failed = failed + 1;
	}
}

#Summary/Report
cat(paste0("Tests passed == ",passed, "/",nrow(df)," ,Tests failed == ",failed,"/",nrow(df),"\n"))

#close channel
close(channel)
