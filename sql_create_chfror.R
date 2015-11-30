#this is the script which created the Risk of Readmission
#for CHF dataset used in the Fall of 2015
#run this script via the following terminal command:
#     nohup Rscript sql_create_chfror.R userID 'password' MHS_CHF.RDS > sql_create_chfror.log &
#which will log in userID with password and save data file to MHS_CHF.RDS
#and errors or screen output will be logged to sql_create_chfror.log
#requirements: RODBC installed
#              first argument will be a user ID with access to MHS SQL views:
#                 Cardiovascular.AcuteCareHeartFailureInpatientCoded
#                 Readmissions.ReadmitPatientHeartFailure
#                 Patient.Comorbidity
#              second argument should be corresponding password

#required R package
library(RODBC)
source('merge_admissions.R')

args      <-commandArgs(trailingOnly = TRUE)
user      <-args[1] #user id for user w/ approrpiate permissions
pass      <-args[2] #corresponding password
file.name <-args[3] #where to save file

conn       <-odbcConnect('edwprod',uid=user,pwd=pass)
df         <-sqlQuery(conn, "
                SELECT BMI, hemoglobin, hematocrit, neutrophils, sodium, glucose, nitrogen, creatinine, 
                comp_diabetes, stroke, EJV, hf_primary, second_nonhf_cnt, risk_mortality,severity_ill, followup,
                sys_BP, dia_BP, ave_BP, pulse, resprate, coronary_syn, arrhythmia, cardio_fail, rheumatic,
                vascular_disease, atherosclerosis, other_hdisease, paralysis, renal_fail, copd, fluid_disorder,
                urinary, ulcer, gastro, peptic_ulcer, hematological, nephritis, dementia, solid_tumor, cancer, 
                liver_disease, end_renal, asthma, anemia, pneumonia, drug_alcohol, major_psych, depression,
                other_psych, lung, malnutrition, HIDacute as HID, PIDacute as PID, EIDacute as EID, admitDT,
                dischargeDT, gender, birth, destination, admit_src, admit_type, discharge_sts, marital,
                ethnic, chf, myocardial, cerebro, peripheral, uncomp_diabetes,
                hiv_aids, connect_tissue, deathDT, cost
                FROM
                  (SELECT c.BodyMassIndexNBR as BMI, c.HemoglobinLevelNBR as hemoglobin,
                  c.HematocritLevelNBR as hematocrit, c.NeutrophilsLevelNBR as neutrophils,
                  c.SodiumLevelNBR as sodium, c.GlucoseLevelNBR as glucose,
                  c.BloodUreaNitrogenLevelNBR as nitrogen, c.CreatinineLevelNBR as creatinine,
                  c.DiabetesAndDMComplicationFLG as comp_diabetes, c.StrokeFLG as stroke, c.EjectionFractionVAL as EJV, 
                  c.HFPrimaryICD9DiagnosisFLG hf_primary, c.SecondaryNonHFICD9DiagnosisCNT second_nonhf_cnt,
                  c.DischargeAPRDRGRiskOfMortalityNBR as risk_mortality, c.DischargeAPRDRGSeverityOfIllnessNBR as severity_ill,
                  c.DischargeFollowupCategoryCD as followup, c.LastInpatientBloodPressureSystolicNBR as sys_BP, 
                  c.LastInpatientBloodPressureDiastolicNBR as dia_BP, c.AvgInpatientBloodPressureCategoryCD as ave_BP,                     c.PulseRateNBR as pulse, c.RespirationRateNBR as resprate, c.AcuteCoronarySyndromeFLG as coronary_syn,
                  c.ArrhythmiaFLG as arrhythmia, c.CardioRespiratoryFailureAndShockFLG as cardio_fail,
                  c.ValvularAndRheumaticHeartDiseaseFLG as rheumatic, c.VascularOrCirculatoryDiseaseFLG as vascular_disease,
                  c.ChronicAtherosclerosisFLG as atherosclerosis, c.OtherAndUnspecifiedHeartDiseaseFLG as other_hdisease,
                  c.HemiplegiaParaplegiaParalysisFunctionalDisabilityFLG as paralysis, c.RenalFailureFLG as renal_fail,
                  c.COPDFLG as copd, c.DisordersOfFluidElectrolyteAcidBaseFLG as fluid_disorder,
                  c.OtherUrinaryTractDisorderFLG as urinary, c.DecubitusUlcerOrChronicSkinUlcerFLG as ulcer,
                  c.OtherGastrointestinalDisorderFLG as gastro, c.PepticUlcerHemorrhageOtherSpecifiedGastrointestinalDisorderFLG as peptic_ulcer,
                  c.SevereHematologicalDisorderFLG as hematological, c.NephritisFLG as nephritis,
                  c.DementiaAndSenilityFLG as dementia, c.MetastaticCancerAndAcuteLeukemiaFLG as solid_tumor,
                  c.CancerFLG as cancer, c.LiverAndBiliaryDiseaseFLG as liver_disease,
                  c.EndStageRenalDiseaseOrDialysisFLG as end_renal, c.AsthmaFLG as asthma,
                  c.IronDeficiencyAndOtherUnspecifiedAnemiasAndBloodDiseaseFLG as anemia, c.PneumoniaFLG as pneumonia,
                  c.DrugAlcoholAbuseDependencePsychosisFLG as drug_alcohol, c.MajorPsychDisorderFLG as major_psych,
                  c.DepressionFLG as depression, c.OtherPsychiatricDisorderFLG as other_psych, 
                  c.FibrosisOfLungAndOtherChronicLungDisorderFLG as lung, c.ProteinCalorieMalnutritionFLG as malnutrition, 
                  c.HospitalAccountID as HIDacute, c.EpicPatientID as PIDacute, c.PatientEncounterID as EIDacute, c.AdmitDT as admitDT, 
                  c.DischargeDT as dischargeDT, c.GenderCD as gender, 
                  year(c.BirthDT) as birth, c.DischargeDestinationID as destination, c.AdmitSourceCD as admit_src,
                  c.AdmitTypeCD as admit_type, c.DischargeStatusCD as discharge_sts, c.MaritalStatusDSC as marital, 
                  c.EthnicGroupDSC as ethnic, c.DeathDT as deathDT, f.TotalChargeAMT as cost
                  FROM Cardiovascular.AcuteCareHeartFailureInpatientCoded c
                      
                  LEFT OUTER JOIN
                      
                  Finance.HospitalAccountBASE f
                  ON c.HospitalAccountID=f.HospitalAccountID) as t1
                      
                  LEFT OUTER JOIN
                      
                  (SELECT c.HospitalAccountID as HID2, c.EpicPatientID as PID2, c.DischargeDT as dischargeDT2,
                  MAX(CASE WHEN p.ComorbidityNM='CharlsonDeyoCongestiveHeartFailure' THEN 1
                  WHEN p.ComorbidityNM='ElixhauserCongestiveHeartFailure' THEN 1 ELSE 0 END) as chf,
                  MAX(CASE WHEN p.ComorbidityNM='CharlsonDeyoMyocardialInfarction' THEN 1 ELSE 0 END) as myocardial,
                  MAX(CASE WHEN p.ComorbidityNM='CharlsonDeyoCerebrovascularDisease' THEN 1 ELSE 0 END) as cerebro,
                  MAX(CASE WHEN p.ComorbidityNM='ElixhauserPeripheralVascularDisorders' THEN 1 
                  WHEN p.ComorbidityNM='CharlsonDeyoPeripheralVascularDisease' THEN 1 ELSE 0 END) as peripheral,
                  MAX(CASE WHEN p.ComorbidityNM='ElixhauserDiabetesUncomplicated' THEN 1 
                  WHEN p.ComorbidityNM='CharlsonDeyoDiabetesWithOutChronicComplication' THEN 1 ELSE 0 END) as uncomp_diabetes,
                  MAX(CASE WHEN p.ComorbidityNM='ElixhauserAIDS_HIV' THEN 1 
                  WHEN p.ComorbidityNM='CharlsonDeyoAIDSHIV' THEN 1 ELSE 0 END) as hiv_aids,
                  MAX(CASE WHEN p.ComorbidityNM='ElixhauserRheumatoidArthritisCollagenVascularDiseases' THEN 1 ELSE 0 END) as connect_tissue
                  FROM Cardiovascular.AcuteCareHeartFailureInpatientCoded c

                  LEFT OUTER JOIN

                  Patient.Comorbidity p
                  ON c.EpicPatientID=p.EpicPatientID AND c.DischargeDT>p.InitialDiagnosisDT                      
                  GROUP BY c.HospitalAccountID, c.EpicPatientID, c.DischargeDT) as t2
                ON t1.PIDacute=t2.PID2 AND t1.HIDacute=t2.HID2 AND t1.dischargeDT=t2.dischargeDT2
                ")
#make sure each column is of the desired type
#handle NA situations appropriately (for some columns this requires no action)
df                                              <-df[!is.na(df$PID),]
df$PID                                          <-as.factor(df$PID)
df                                              <-df[!is.na(df$HID),]
df$HID                                          <-as.factor(df$HID)
df                                              <-df[!is.na(df$EID),]
df$EID                                          <-as.factor(df$EID)
df$admit_type                                   <-as.factor(df$admit_type)
df$admit_src                                    <-as.factor(df$admit_src)
df                                              <-df[!is.na(df$dischargeDT),]
df$dischargeDT                                  <-as.Date(df$dischargeDT)
df$destination                                  <-as.factor(df$destination)
df$discharge_sts                                <-as.factor(df$discharge_sts)
df$followup                                     <-as.factor(df$followup)
df                                              <-df[!is.na(df$admitDT),]
df$admitDT                                      <-as.Date(df$admitDT)
df$risk_mortality                               <-as.numeric(df$risk_mortality)
df$severity_ill                                 <-as.numeric(df$severity_ill)
df$gender                                       <-as.factor(df$gender)
df$birth                                        <-as.numeric(df$birth)
df$marital                                      <-as.factor(df$marital)
df$ethnic                                       <-as.factor(df$ethnic)
df$BMI                                          <-as.numeric(df$BMI)
df$EJV                                          <-as.numeric(df$EJV)
df$sys_BP                                       <-as.numeric(df$sys_BP)
df$dia_BP                                       <-as.numeric(df$dia_BP)
df$ave_BP                                       <-as.factor(df$ave_BP)
df$hf_primary[is.na(df$hf_primary)]             <-'N'
df$hf_primary                                   <-as.factor(df$hf_primary)
df$second_nonhf_cnt[is.na(df$second_nonhf_cnt)] <-0
df$second_nonhf_cnt                             <-as.numeric(df$second_nonhf_cnt)
df$hemoglobin                                   <-as.numeric(df$hemoglobin)
df$hematocrit                                   <-as.numeric(df$hematocrit)
df$neutrophils                                  <-as.numeric(df$neutrophils)
df$sodium                                       <-as.numeric(df$sodium)
df$glucose                                      <-as.numeric(df$glucose)
df$nitrogen                                     <-as.numeric(df$nitrogen)
df$creatinine                                   <-as.numeric(df$creatinine)
df$pulse                                        <-as.numeric(df$pulse)
df$resprate                                     <-as.numeric(df$resprate)
df$coronary_syn[is.na(df$coronary_syn)]         <-0
df$coronary_syn                                 <-as.factor(df$coronary_syn)
df$arrhythmia[is.na(df$arrhythmia)]             <-0
df$arrhythmia                                   <-as.factor(df$arrhythmia)
df$cardio_fail[is.na(df$cardio_fail)]           <-0
df$cardio_fail                                  <-as.factor(df$cardio_fail)
df$rheumatic[is.na(df$rheumatic)]               <-0
df$rheumatic                                    <-as.factor(df$rheumatic)
df$vascular_disease[is.na(df$vascular_disease)] <-0
df$vascular_disease                             <-as.factor(df$vascular_disease)
df$atherosclerosis[is.na(df$atherosclerosis)]   <-0
df$atherosclerosis                              <-as.factor(df$atherosclerosis)
df$other_hdisease[is.na(df$other_hdisease)]     <-0
df$other_hdisease                               <-as.factor(df$other_hdisease)
df$paralysis[is.na(df$paralysis)]               <-0
df$paralysis                                    <-as.factor(df$paralysis)
df$renal_fail[is.na(df$renal_fail)]             <-0
df$renal_fail                                   <-as.factor(df$renal_fail)
df$fluid_disorder[is.na(df$fluid_disorder)]     <-0
df$fluid_disorder                               <-as.factor(df$fluid_disorder)
df$urinary[is.na(df$urinary)]                   <-0
df$urinary                                      <-as.factor(df$urinary)
df$ulcer[is.na(df$ulcer)]                       <-0
df$ulcer                                        <-as.factor(df$ulcer)
df$gastro[is.na(df$gastro)]                     <-0
df$gastro                                       <-as.factor(df$gastro)
df$peptic_ulcer[is.na(df$peptic_ulcer)]         <-0
df$peptic_ulcer                                 <-as.factor(df$peptic_ulcer)
df$hematological[is.na(df$hematological)]       <-0
df$hematological                                <-as.factor(df$hematological)
df$nephritis[is.na(df$nephritis)]               <-0
df$nephritis                                    <-as.factor(df$nephritis)
df$end_renal[is.na(df$end_renal)]               <-0
df$end_renal                                    <-as.factor(df$end_renal)
df$asthma[is.na(df$asthma)]                     <-0
df$asthma                                       <-as.factor(df$asthma)
df$anemia[is.na(df$anemia)]                     <-0
df$anemia                                       <-as.factor(df$anemia)
df$lung[is.na(df$lung)]                         <-0
df$lung                                         <-as.factor(df$lung)
df$malnutrition[is.na(df$malnutrition)]         <-0
df$malnutrition                                 <-as.factor(df$malnutrition)
df$other_psych[is.na(df$other_psych)]           <-0
df$other_psych                                  <-as.factor(df$other_psych)
df$depression[is.na(df$depression)]             <-0
df$depression                                   <-as.factor(df$depression)
df$major_psych[is.na(df$major_psych)]           <-0
df$major_psych                                  <-as.factor(df$major_psych)
df$stroke[is.na(df$stroke)]                     <-0
df$stroke                                       <-as.factor(df$stroke)
df$dementia[is.na(df$dementia)]                 <-0
df$dementia                                     <-as.factor(df$dementia)
df$comp_diabetes[is.na(df$comp_diabetes)]       <-0
df$comp_diabetes                                <-as.factor(df$comp_diabetes)
df$copd[is.na(df$copd)]                         <-0
df$copd                                         <-as.factor(df$copd)
df$liver_disease[is.na(df$liver_disease)]       <-0
df$liver_disease                                <-as.factor(df$liver_disease)
df$solid_tumor[is.na(df$solid_tumor)]           <-0
df$solid_tumor                                  <-as.factor(df$solid_tumor)
df$cancer[is.na(df$cancer)]                     <-0
df$cancer                                       <-as.factor(df$cancer)
df$myocardial[is.na(df$myocardial)]             <-0
df$myocardial                                   <-as.factor(df$myocardial)
df$cerebro[is.na(df$cerebro)]                   <-0
df$cerebro                                      <-as.factor(df$cerebro)
df$peripheral[is.na(df$peripheral)]             <-0
df$peripheral                                   <-as.factor(df$peripheral)
df$uncomp_diabetes[is.na(df$uncomp_diabetes)]   <-0
df$uncomp_diabetes                              <-as.factor(df$uncomp_diabetes)
df$hiv_aids[is.na(df$hiv_aids)]                 <-0
df$hiv_aids                                     <-as.factor(df$hiv_aids)
df$connect_tissue[is.na(df$connect_tissue)]     <-0
df$connect_tissue                               <-as.factor(df$connect_tissue)
df$chf[is.na(df$chf)]                           <-0
df$chf                                          <-as.factor(df$chf)
df$pneumonia[is.na(df$pneumonia)]               <-0
df$pneumonia                                    <-as.factor(df$pneumonia)
df$drug_alcohol[is.na(df$drug_alcohol)]         <-0
df$drug_alcohol                                 <-as.factor(df$drug_alcohol)
df$deathDT                                      <-as.Date(df$deathDT)
df$cost[is.na(df$cost)]                         <-0
df$cost                                         <-as.numeric(df$cost)

#merge transfers into one admission
df <-merge(df)

#create certain columns
#nextadmitDT
df$nextadmitDT <-NA
df$nextadmitDT <-as.Date(df$nextadmitDT)
df.relevant    <-df[,which(names(df) %in% c("PID","dischargeDT","admitDT","nextadmitDT"))]
for(i in 1:nrow(df.relevant)) {
  if(i%%1000==0){
    message('working on patient: ',i, ' of ', nrow(df.relevant))
  }
  patient <- df.relevant$PID[i]
  discharge <-df.relevant$dischargeDT[i]
  df.future <-df.relevant$admitDT[df.relevant$PID==patient & (df.relevant$admitDT > discharge)]
  if(length(df.future) > 0) {
    df.relevant$nextadmitDT[i]<-as.Date(min(df.future))
  }
}
df$nextadmitDT <-df.relevant$nextadmitDT
df$nextadmitDT <-as.Date(df$nextadmitDT)
#daystonext
df$daystonext[is.na(df$nextadmitDT)]<-NA
df$daystonext[!is.na(df$nextadmitDT)]<-
  df$nextadmitDT[!is.na(df$nextadmitDT)] - 
  df$dischargeDT[!is.na(df$nextadmitDT)]
df$daystonext[df$daystonext<0]<-NA
df$daystonext <-as.numeric(df$daystonext)
#LOS
df$LOS <-as.numeric(df$dischargeDT - df$admitDT)
df$LOS[df$LOS<0]<-NA
df$LOS <-as.numeric(df$LOS)
#hf_count
df$hf_count <-0
df.relevant <-df[,which(names(df) %in% c("hf_count","PID","admitDT","dischargeDT"))]
for(i in 1:nrow(df.relevant)) {
  if(i%%1000==0){
    message('working on patient: ', i, ' of ',nrow(df.relevant))
  }
  df.relevant$hf_count[i] <-nrow(df.relevant[
    df.relevant$PID==df.relevant$PID[i] &
      df.relevant$hf_primary=='Y' &
      df.relevant$admitDT > df.relevant$dischargeDT[i],])
}
df$hf_count <-df.relevant$hf_count
df$hf_count <-as.numeric(df$hf_count)

#create response variables
#whether patient was readmitted within 30days
df$thirtyday <-0
df$thirtyday[!is.na(df$daystonext)] <-as.numeric(df$daystonext[!is.na(df$daystonext)] <= 30)
df$thirtyday <-as.factor(df$thirtyday)
#thirty_cnt(is a predictor variable, but calculated here due to access to thirtyday column)
df$thirty_cnt <-0
df.relevant <-df[,which(names(df) %in% c("PID","hf_primary","admitDT","dischargeDT","thirtyday"))]
for(i in 1:nrow(df.relevant)) {
  if(i%%1000==0){
    message('working on patient: ', i, ' of ', nrow(df.relevant))
  }
  df.relevant$thirty_cnt[i] <-nrow(df.relevant[
    df.relevant$PID==df.relevant$PID[i] &
      df.relevant$hf_primary=='Y' &
      df.relevant$admitDT > df.relevant$dischargeDT[i] &
      df.relevant$thirtyday==1,])
}
df$thirty_cnt <-df.relevant$thirty_cnt
df$thirty_cnt <-as.numeric(df$thirty_cnt)
#whether patient was readmitted within 60days
df$sixtyday <-0
df$sixtyday[!is.na(df$daystonext)] <-as.numeric(df$daystonext[!is.na(df$daystonext)] <= 60)
df$sixtyday <-as.factor(df$sixtyday)
#whether patient was readmitted within 90days
df$ninetyday <-0
df$ninetyday[!is.na(df$daystonext)] <-as.numeric(df$daystonext[!is.na(df$daystonext)] <= 90)
df$ninetyday <-as.factor(df$ninetyday)
#next admission LOS
df$nextLOS <-NA
df.hasnext <-df[!is.na(df$nextadmitDT),which(names(df) %in% c('PID','nextadmitDT','nextLOS'))]
for(i in 1:nrow(df.hasnext)) {
  if(i%%1000==0){
    message('working on patient: ',i, ' of ',nrow(df.hasnext))
  }
  patient<-df.hasnext$PID[i]
  nextadmit<-df.hasnext$nextadmitDT[i]
  df.hasnext$nextLOS[i] <-df$LOS[df$PID==patient & df$admitDT==nextadmit][1]
}
df$nextLOS[!is.na(df$nextadmitDT)]<-df.hasnext$nextLOS
df$nextLOS <-as.numeric(df$nextLOS)
#next admission cost
df$nextcost <- 0
df.hasnext  <-df[!is.na(df$nextadmitDT),which(names(df) %in% c('PID','nextadmitDT','nextcost'))]
for(i in 1:nrow(df.hasnext)) {
  if(i%%1000==0) {
    message('working on patient ',i,' of ',nrow(df.hasnext))
  }
  patient                <-df.hasnext$PID[i]
  nextadmit              <-df.hasnext$nextadmitDT[i]
  df.hasnext$nextcost[i] <-df$cost[df$PID==patient & df$admitDT==nextadmit][1]
}
df$nextcost[!is.na(df$nextadmitDT)] <-df.hasnext$nextcost
df$nextcost                         <-as.numeric(df$nextcost)
#next LOS is at least x days
df$two_LOS <-0
df$two_LOS[!is.na(df$nextLOS)] <-as.numeric(df$nextLOS[!is.na(df$nextLOS)] >= 2)
df$two_LOS <-as.factor(df$two_LOS)
#next LOS is at least y days
df$four_LOS <-0
df$four_LOS[!is.na(df$nextLOS)] <-as.numeric(df$nextLOS[!is.na(df$nextLOS)] >= 4)
df$four_LOS <-as.factor(df$four_LOS)
#next LOS is at least z days
df$six_LOS <-0
df$six_LOS[!is.na(df$nextLOS)] <-as.numeric(df$nextLOS[!is.na(df$nextLOS)] >= 6)
df$six_LOS <-as.factor(df$six_LOS)
#next LOS is at least 5 days
#talked to the pharmacist from multicare, we are asked to consider 5 day as the period for LOS
df$five_LOS <-0
df$five_LOS[!is.na(df$nextLOS)] <-as.numeric(df$nextLOS[!is.na(df$nextLOS)] >= 5)
df$five_LOS <-as.factor(df$five_LOS)
#mortality within 3 months
df$three_mortality <-0
df$three_mortality[!is.na(df$deathDT)] <-as.numeric(as.numeric(
  df$deathDT[!is.na(df$deathDT)] - df$dischargeDT[!is.na(df$deathDT)]) <= 91)
df$three_mortality <-as.factor(df$three_mortality)
#mortality within 6 months
df$six_mortality <-0
df$six_mortality[!is.na(df$deathDT)] <-as.numeric(as.numeric(
  df$deathDT[!is.na(df$deathDT)] - df$dischargeDT[!is.na(df$deathDT)]) <= 182)
df$six_mortality <-as.factor(df$six_mortality)
#mortality within 9 months
df$nine_mortality <-0
df$nine_mortality[!is.na(df$deathDT)] <-as.numeric(as.numeric(
  df$deathDT[!is.na(df$deathDT)] - df$dischargeDT[!is.na(df$deathDT)]) <= 274)
df$nine_mortality <-as.factor(df$nine_mortality)
#mortality within 12 months
df$twelve_mortality <-0
df$twelve_mortality[!is.na(df$deathDT)] <-as.numeric(as.numeric(
  df$deathDT[!is.na(df$deathDT)] - df$dischargeDT[!is.na(df$deathDT)]) <= 365)
df$twelve_mortality <-as.factor(df$twelve_mortality)
#save data into desired file location
saveRDS(df, file=file.name)
#close connection
close(conn)
