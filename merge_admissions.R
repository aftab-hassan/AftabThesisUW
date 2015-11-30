merge  <-function(data.full) {
  message('total of ',nrow(data.full),' rows in full dataset')
  data <-data.full
  i    <-1
  rows <-which(data$PID==data$PID[i] &
    data$admitDT >= data$admitDT[i] &
    data$admitDT <= data$dischargeDT[i])
  while(i <= nrow(data)) {
    if(length(rows) > 1) {
      message('working on row ', i, ' with ', length(rows)-1,' conflicts')
      data.current             <-data[rows,]
      nonna                    <-data.current[!is.na(data.current$BMI),]
      data$BMI[i]              <-if(nrow(nonna)>0) nonna$BMI[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$hemoglobin),]
      data$hemoglobin[i]       <-if(nrow(nonna)>0)nonna$hemoglobin[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$hematocrit),]
      data$hematocrit[i]       <-if(nrow(nonna)>0)nonna$hematocrit[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$neutrophils),]
      data$neutrophils[i]      <-if(nrow(nonna)>0)nonna$neutrophils[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$sodium),]
      data$sodium[i]           <-if(nrow(nonna)>0)nonna$sodium[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$glucose),]
      data$glucose[i]          <-if(nrow(nonna)>0)nonna$glucose[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$nitrogen),]
      data$nitrogen[i]         <-if(nrow(nonna)>0)nonna$nitrogen[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$creatinine),]
      data$creatinine[i]       <-if(nrow(nonna)>0)nonna$creatinine[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      data$comp_diabetes[i]    <-if(nrow(data.current[data.current$comp_diabetes==1,])>0) 1 else 0
      data$stroke[i]           <-if(nrow(data.current[data.current$stroke==1,])>0) 1 else 0
      data$EJV[i]              <-if(nrow(data.current[data.current$EJV==1,])>0) 1 else 0
      data$hf_primary[i]       <-if(nrow(data.current[data.current$hf_primary==1,])>0) 1 else 0
      nonna                    <-data.current[!is.na(data.current$second_nonhf_cnt),]
      data$second_nonhf_cnt[i] <-if(nrow(nonna)>0) max(nonna$second_nonhf_cnt) else NA
      nonna                    <-data.current[!is.na(data.current$risk_mortality),]
      data$risk_mortality[i]   <-if(nrow(nonna)>0) nonna$risk_mortality[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$severity_ill),]
      data$severity_ill[i]     <-if(nrow(nonna)>0) nonna$severity_ill[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$followup),]
      data$followup[i]         <-if(nrow(nonna)>0) nonna$followup[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$sys_BP),]
      data$sys_BP[i]           <-if(nrow(nonna)>0) nonna$sys_BP[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$dia_BP),]
      data$dia_BP[i]           <-if(nrow(nonna)>0) nonna$dia_BP[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$ave_BP),]
      data$ave_BP[i]           <-if(nrow(nonna)>0) nonna$ave_BP[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$pulse),]
      data$pulse[i]            <-if(nrow(nonna)>0) nonna$pulse[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$resprate),]
      data$resprate[i]         <-if(nrow(nonna)>0) nonna$resprate[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      data$coronary_syn[i]     <-if(nrow(data.current[data.current$coronary_syn==1,])>0) 1 else 0
      data$arrhythmia[i]       <-if(nrow(data.current[data.current$arrhythmia==1,])>0) 1 else 0
      data$cardio_fail[i]      <-if(nrow(data.current[data.current$cardio_fail==1,])>0) 1 else 0
      data$rheumatic[i]        <-if(nrow(data.current[data.current$rheumatic==1,])>0) 1 else 0
      data$vascular_disease[i] <-if(nrow(data.current[data.current$vascular_disease==1,])>0) 1 else 0
      data$atherosclerosis[i]  <-if(nrow(data.current[data.current$atherosclerosis==1,])>0) 1 else 0
      data$other_hdisease[i]   <-if(nrow(data.current[data.current$other_hdisease==1,])>0) 1 else 0
      data$paralysis[i]        <-if(nrow(data.current[data.current$paralysis==1,])>0) 1 else 0
      data$renal_fail[i]       <-if(nrow(data.current[data.current$renal_fail==1,])>0) 1 else 0
      data$copd[i]             <-if(nrow(data.current[data.current$copd==1,])>0) 1 else 0
      data$fluid_disorder[i]   <-if(nrow(data.current[data.current$fluid_disorder==1,])>0) 1 else 0
      data$urinary[i]          <-if(nrow(data.current[data.current$urinary==1,])>0) 1 else 0
      data$ulcer[i]            <-if(nrow(data.current[data.current$ulcer==1,])>0) 1 else 0
      data$gastro[i]           <-if(nrow(data.current[data.current$gastro==1,])>0) 1 else 0
      data$peptic_ulcer[i]     <-if(nrow(data.current[data.current$peptic_ulcer==1,])>0) 1 else 0
      data$hematological[i]    <-if(nrow(data.current[data.current$hematological==1,])>0) 1 else 0
      data$nephritis[i]        <-if(nrow(data.current[data.current$nephritis==1,])>0) 1 else 0
      data$dementia[i]         <-if(nrow(data.current[data.current$dementia==1,])>0) 1 else 0
      data$solid_tumor[i]      <-if(nrow(data.current[data.current$solid_tumor==1,])>0) 1 else 0
      data$cancer[i]           <-if(nrow(data.current[data.current$cancer==1,])>0) 1 else 0
      data$liver_disease[i]    <-if(nrow(data.current[data.current$liver_disease==1,])>0) 1 else 0
      data$end_renal[i]        <-if(nrow(data.current[data.current$end_renal==1,])>0) 1 else 0
      data$asthma[i]           <-if(nrow(data.current[data.current$asthma==1,])>0) 1 else 0
      data$anemia[i]           <-if(nrow(data.current[data.current$anemia==1,])>0) 1 else 0
      data$pneumonia[i]        <-if(nrow(data.current[data.current$pneumonia==1,])>0) 1 else 0
      data$drug_alcohol[i]     <-if(nrow(data.current[data.current$drug_alcohol==1,])>0) 1 else 0
      data$major_psych[i]      <-if(nrow(data.current[data.current$major_psych==1,])>0) 1 else 0
      data$depression[i]       <-if(nrow(data.current[data.current$depression==1,])>0) 1 else 0
      data$other_psych[i]      <-if(nrow(data.current[data.current$other_psych==1,])>0) 1 else 0
      data$lung[i]             <-if(nrow(data.current[data.current$lung==1,])>0) 1 else 0
      data$malnutrition[i]     <-if(nrow(data.current[data.current$malnutrition==1,])>0) 1 else 0
      data$HID[i]              <-data.current$HID[which(data.current$admitDT == min(data.current$admitDT))]
      data$PID[i]              <-data.current$PID[1]
      data$admitDT[i]          <-min(data.current$admitDT)
      data$dischargeDT[i]      <-max(data.current$dischargeDT)
      nonna                    <-data.current[!is.na(data.current$gender),]
      data$gender[i]           <-if(nrow(nonna)>0) nonna$gender[1] else NA
      nonna                    <-data.current[!is.na(data.current$birth)]
      data$birth[i]            <-if(nrow(nonna)>0) nonna$birth[1]
      nonna                    <-data.current[!is.na(data.current$destination),]
      data$destination[i]      <-if(nrow(nonna)>0) nonna$destination[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$admit_src),]
      data$admit_src[i]        <-if(nrow(nonna)>0) nonna$admit_src[which(nonna$admitDT == min(nonna$admitDT))] else NA
      nonna                    <-data.current[!is.na(data.current$admit_type),]
      data$admit_type[i]       <-if(nrow(nonna)>0) nonna$admit_type[which(nonna$admitDT == min(nonna$admitDT))] else NA
      nonna                    <-data.current[!is.na(data.current$discharge_sts),]
      data$discharge_sts[i]    <-if(nrow(nonna)>0) nonna$dia_BP[which(nonna$dischargeDT == max(nonna$dischargeDT))] else NA
      nonna                    <-data.current[!is.na(data.current$marital),]
      data$marital[i]          <-if(nrow(nonna)>0) nonna$marital[1] else NA
      nonna                    <-data.current[!is.na(data.current$ethnic),]
      data$ethnic[i]           <-if(nrow(nonna)>0) nonna$ethnic[1] else NA
      data$chf[i]              <-if(nrow(data.current[data.current$chf==1,])>0) 1 else 0
      data$myocardial[i]       <-if(nrow(data.current[data.current$myocardial==1,])>0) 1 else 0
      data$cerebro[i]          <-if(nrow(data.current[data.current$cerebro==1,])>0) 1 else 0
      data$peripheral[i]       <-if(nrow(data.current[data.current$peripheral==1,])>0) 1 else 0
      data$uncomp_diabetes[i]  <-if(nrow(data.current[data.current$uncomp_diabetes==1,])>0) 1 else 0
      data$hiv_aids[i]         <-if(nrow(data.current[data.current$hiv_aids==1,])>0) 1 else 0
      data$connect_tissue[i]   <-if(nrow(data.current[data.current$connect_tissue==1,])>0) 1 else 0
      nonna                    <-data.current[!is.na(data.current$deatDT),]
      data$deathDT[i]          <-if(nrow(nonna)>0) nonna$deathDT[1] else NA
      lvl.one                  <- data[1:i,]
      if(length(which((1:i) %in% rows)) > 0) {
        lvl.one                <-lvl.one[-which((1:i) %in% rows),]
      }
      lvl.two                  <- data[(i+1):nrow(data),]
      if(length(which((i+1):nrow(data) %in% rows)) > 0) {
        lvl.two                <-lvl.two[-which(((i+1):nrow(data)) %in% rows),]
      }
      data <-rbind(lvl.one, data[i,], lvl.two)
    } else {
      i = i + 1
    }
    rows <-which(data$PID==data$PID[i] &
      data$admitDT >= data$admitDT[i] &
      data$admitDT <= data$dischargeDT[i])
  }  
  message('finished with ', nrow(data), ' rows of data')
  message('removed ',nrow(data.full) - nrow(data),' conflicts')
  return(data)
}
