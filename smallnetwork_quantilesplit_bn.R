###########################################################################
#Purpose : Integrated script which will do the following
#          1.Train Bayesian Network Model
#		   2.Convert continuous data to categorical using quantile split
#          3.Do Recommendation for all three variables
#          4.Write results to results.csv

#To run  : Rscript bn.R <inputfile>
###########################################################################

#clear environment
rm(list=ls())

#turn off warnings
options(warn=-1)

#load necessary packages
suppressMessages(library(bnlearn))
suppressMessages(library(gRain))
suppressMessages(library(foreach))
suppressMessages(library(doMC))

#create folder called 'steps' to save images
currentDir = getwd();
subDir = "steps"
dir.create(file.path(currentDir, subDir), showWarnings = FALSE)

#global variables
riskscorearray = c()
combinationarray = c()
outputdf = NULL

cat(paste("Step 1 of 3 initiated : Reading data and splitting...\n"));

#read command line arguments
inputfile = "MHS_CHF_Medications_NoNA.RDS"
df = readRDS(inputfile)

#response variable
responsehere = 'thirtyday'

#removing certain columns
#1.removing BMI because of the following reasons
 #1.Some of the data is dirty(talked to Peter Jin from multicare)
 #2.Contains 61.94922% NAs
#df = df[which(df$BMI < 1000),]
df$BMI = NULL
#2.removing hf_count : everyone's hf_count = 0
df$hf_count = NULL

#separating columns to integer or factor
#numericcols = c('BMI','hemoglobin','hematocrit','neutrophils','sodium','glucose','nitrogen','creatinine','EJV','second_nonhf_cnt','sys_BP','dia_BP','ave_BP','pulse','resprate','cost','thirty_cnt','LOS','hf_count')
numericcols = c('hemoglobin','hematocrit','neutrophils','sodium','glucose','nitrogen','creatinine','EJV','second_nonhf_cnt','sys_BP','dia_BP','ave_BP','pulse','resprate','cost','thirty_cnt','LOS')
allcols = names(df)
factorcols = colnames(df)[(colnames(df) %in% setdiff(allcols, numericcols))]
df[,numericcols] <- sapply(df[,numericcols],as.numeric)
for(i in 1:length(factorcols))
{
    df[,factorcols[i]] = as.factor(df[,factorcols[i]])
}

##########################################################################
#####################CONVERT NUMERIC TO CATEGORICAL START#################
##########################################################################
#converting numeric columns to factor ; based on Quantiles
for(i in 1:ncol(df))
{
	if((class(df[,i]) == "numeric") == TRUE)
	{
		summaryhere = summary(df[,i])

		#Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
		Q1 = min(df[,i])
		Q2 = summaryhere["Mean"]
		Q3 = summaryhere["3rd Qu."]
		Q4 = max(df[,i])

		Q1rows = which(df[,i] <= Q1)
		Q2rows = which(df[,i] > Q1 & df[,i] <= Q2)
		Q3rows = which(df[,i] > Q2 & df[,i] <= Q3)
		Q4rows = which(df[,i] > Q3 & df[,i] <= Q4)
		Q34rows = which(df[,i] > Q2 & df[,i] <= Q4)

		df[Q1rows,i] = "Q1"
		df[Q2rows,i] = "Q2"

		#the else is required for those columns where the 3rd quartile is less than Mean
		if(Q3 > Q2)
		{
			df[Q3rows,i] = "Q3"	
			df[Q4rows,i] = "Q4"
		}else
		{
			df[Q34rows,i] = "Q34"
		}
	}
}
##########################################################################
#####################CONVERT NUMERIC TO CATEGORICAL STOP##################
##########################################################################

#removing rows which don't have a single medication
dfmed = df[,grep("MED.",names(df))]
for(i in 1:ncol(dfmed))
{
    dfmed[,i] = as.character(dfmed[,i])
    dfmed[,i] = as.numeric(dfmed[,i])
}
AtleastOneMedPatients = which(rowSums(dfmed) > 0)
df = df[AtleastOneMedPatients,]

for(i in 1:ncol(df))
{
    df[,i] = as.factor(df[,i])
}

#use 80% of the data for training., 20% for testing
traindf = df[1:(0.8*nrow(df)),]
testdf = df[((0.8*nrow(df))+1):nrow(df),]
cat(paste("Step 1 of 3 completed : Reading data and splitting...\n"));

#user-defined functions
lastn <- function(x, n)
{
        substr(x, nchar(x)-n+1, nchar(x))
}

buildModel <- function()
{
		#three types of columns, removing certain columns
		responsecols = c('thirtyday','sixtyday','ninetyday','two_LOS','four_LOS','six_LOS','seven_LOS','three_mortality','six_mortality','nine_mortality','twelve_mortality','nextcost')
		futurecols = c('nextadmitDT','daystonext','nextLOS','deathDT')
		admincols = c('HID','PID','EID','admitDT','dischargeDT')
		ignorecols = c(responsecols,futurecols,admincols)
		responsehere = c('thirtyday','seven_LOS','twelve_mortality')
		traindf = traindf[, !(colnames(traindf) %in% setdiff(ignorecols, responsehere))]
	
		#finding columns of data type 'factor' which have only a single level
		dffactor = traindf[,which((sapply(traindf,class) == "factor") == TRUE)]
		SingleFactorColumns = names(dffactor)[which(sapply(dffactor,nlevels) == 1)]
		for(i in 1:length(SingleFactorColumns))
		{
		    traindf[,SingleFactorColumns[i]] = NULL
		}
		testdf = testdf[,names(traindf)]

		#writing this to use for other models(other response variables)
		saveRDS(traindf,'traindf.RDS')
		saveRDS(testdf,'testdf.RDS')

		#read blacklist and whitelist
		#whitelist = read.csv('whitelist.csv')
		blacklist = read.csv('blacklist.csv')

        #building bn model
        cat(paste("Step 2 of 3 initiated : Building models...\n"));
        #hcbn = hc(traindf,  whitelist=whitelist,blacklist = blacklist, score='bic',restart = 0)
        #hcbn = cextend(gs(traindf, whitelist=whitelist,blacklist = blacklist, optimized=TRUE))
        #hcbn = mmhc(traindf, whitelist=whitelist,blacklist = blacklist, optimized=TRUE)
        #hcbn = hc(traindf,score='bic',restart = 0)
        hcbn = hc(traindf,score='bic',blacklist=blacklist,restart = 0)
        hcbn.fitted = bn.fit(hcbn, traindf, method='bayes')
        hcbn.grain <<- as.grain(hcbn.fitted)

        cat(paste("Step 2 of 3 completed : Building models done\n\n"));
        save.image(file = './steps/step2.RData')
}

doRecommendation <- function()
{
	testdf = readRDS('testdf.RDS')

	responsecols = c("thirtyday","seven_LOS","twelve_mortality")
	mypredictors = setdiff(names(testdf),responsecols)

    MedicationCombinationArray = c()
    ReadmitRiskScoreArray = c()
    LOSRiskScoreArray = c()
    MortalityRiskScoreArray = c()
    outputdf = NULL;

    #prediction
    cat(paste("Step 3 of 3 initiated : Doing recommendations...\n"));

    #this should be commented
    testdf = testdf[1,]

    #initially setting the medicationscols to 0 for all test data, going to incrementally add 1s as per valid combinations 
    #in the next code block.
    medicationscols = grep("MED.",names(testdf))
    for(i in 1:length(medicationscols))
    {
            testdf[,medicationscols[i]] = as.numeric(as.character(testdf[,medicationscols[i]]))
            testdf[,medicationscols[i]] = 0;
    }
    
    #reading valid MedicationCombinations file
    ValidMedicationCombinations = read.csv("ValidMedicationCombinations.csv")
    for(i in 1:ncol(ValidMedicationCombinations))
    {
    	ValidMedicationCombinations[,i] = as.character(ValidMedicationCombinations[,i])
    }

    #riskscore = predict(hcbn.grain, response = c("thirtyday"), newdata = mytestrow, predictors = mypredictors, type = "distribution")$pred$thirtyday[2];
    #i : iterates through each patient in test data
    #j : iterates through each ValidMedicationCombinations
	for(i in 1:nrow(testdf))
	#for(i in 1:1)
	{
		#mytestrow = data.frame(testdf[i,])
		mytestrow = testdf[i,]

		for(j in 1:nrow(ValidMedicationCombinations))
		#for(j in 1:1)
		#for(j in 1:10)
		{
			print(j)
			
			combination = ValidMedicationCombinations[j,"ValidMedicationCombination"]
			#print(combination)
			medicationshere = unlist(strsplit(combination, split=":"))
			#print(medicationshere)
			testdf[i,medicationshere] = 1

			 #converting them to factor for bayesian network
            for(k in 1:length(medicationscols))
            {
                    mytestrow[,medicationscols[k]] = as.factor(mytestrow[,medicationscols[k]])
            }

            #doing prediction, probability of getting readmitted==1
            #> riskscore
		    #0         1       NULL
            #[1,] 0.763464 0.1988472 0.03768885
            ReadmitRiskScore = round(predict(hcbn.grain, response = c("thirtyday"), newdata = mytestrow, predictors = mypredictors, type = "distribution")$pred$thirtyday[2] * 100);
            LOSRiskScore = round(predict(hcbn.grain, response = c("seven_LOS"), newdata = mytestrow, predictors = mypredictors, type = "distribution")$pred$seven_LOS[2] * 100);
            MortalityRiskScore = round(predict(hcbn.grain, response = c("twelve_mortality"), newdata = mytestrow, predictors = mypredictors, type = "distribution")$pred$twelve_mortality[2] * 100);

		#print(ReadmitRiskScore)
		#print(LOSRiskScore)
		#print(MortalityRiskScore)

            #saving in output
            MedicationCombinationArray = c(MedicationCombinationArray,paste(medicationshere,collapse="-"))
            ReadmitRiskScoreArray = c(ReadmitRiskScoreArray,ReadmitRiskScore)
            LOSRiskScoreArray = c(LOSRiskScoreArray,LOSRiskScore)
            MortalityRiskScoreArray = c(MortalityRiskScoreArray,MortalityRiskScore)
		}			
	}        

	#print(MedicationCombinationArray)
	#print(ReadmitRiskScoreArray)
	#print(LOSRiskScoreArray)
	#print(MortalityRiskScoreArray)

	MedicationCombination = MedicationCombinationArray
	ReadmitRiskScore = ReadmitRiskScoreArray
	LOSRiskScore = LOSRiskScoreArray
	MortalityRiskScore = MortalityRiskScoreArray

	#debug
	#print(MedicationCombination)
	#print(ReadmitRiskScore)
	#print(LOSRiskScore)
	#print(MortalityRiskScore)

	outputdf = data.frame(MedicationCombination,ReadmitRiskScore,LOSRiskScoreArray,MortalityRiskScoreArray)

	write.csv(outputdf,"ParetoInput.csv",row.names=FALSE)

    cat(paste("Step 3 of 3 completed : Recommendations done\n\n"));
}

#calling user-defined functions
buildModel();
doRecommendation();
