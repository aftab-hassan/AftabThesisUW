###########################################################################
#Purpose : Integrated script which will do the following
#	   1.Train Bayesian Network Model
#	   2.Do Prediction
#	   3.Write results to results.csv

#To run  : Rscript bn.R <inputfile>
###########################################################################

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

#three types of columns
response = c('thirtyday','sixtyday','ninetyday','nextLOS','two_LOS','four_LOS','six_LOS','seven_LOS','nextcost','three_mortality','six_mortality','nine_mortality','twelve_mortality')
ignore = c('HID','PID','EID','admitDT','dischargeDT','nextadmitDT','daystonext')
responsehere = 'thirtyday'
df$sixtyday = NULL
df$ninetyday = NULL
df$nextLOS = NULL
df$two_LOS = NULL
df$four_LOS = NULL
df$six_LOS = NULL
df$seven_LOS = NULL
df$nextcost = NULL
df$three_mortality = NULL
df$six_mortality = NULL
df$nine_mortality = NULL
df$twelve_mortality = NULL
df$HID = NULL
df$PID = NULL
df$EID = NULL
df$admitDT = NULL
df$dischargeDT = NULL
df$nextadmitDT = NULL
df$daystonext = NULL
df$hf_count = NULL
for(i in 1:ncol(df))
{
    df[,i] = as.factor(df[,i])
}

#removing rows which don't have a single medication
dfmed = df[,grep("MED.",names(df))]
for(i in 1:ncol(dfmed))
{
    dfmed[,i] = as.character(dfmed[,i])
    dfmed[,i] = as.numeric(dfmed[,i])
}
AtleastOneMedPatients = which(rowSums(dfmed) > 0)
AtleastOnceUsedMedications = which(colSums(dfmed) > 0)
NonMedicationsColumns = setdiff(names(df),names(df)[grep("MED.",names(df))])
df = df[AtleastOneMedPatients,c(NonMedicationsColumns,names(AtleastOnceUsedMedications))]

#use 80% of the data for training., 20% for testing
traindf = df[1:(0.8*nrow(df)),]
testdf = df[((0.8*nrow(df))+1):nrow(df),]
cat(paste("Step 1 of 3 completed : Reading data and splitting...\n"));

#read blacklist and whitelist
#whitelist = read.csv('whitelist.csv')
#blacklist = read.csv('blacklist.csv')
#user-defined functions
lastn <- function(x, n)
{
 	substr(x, nchar(x)-n+1, nchar(x))
}

buildModel <- function()
{
	#building bn model
	cat(paste("Step 2 of 3 initiated : Building models...\n"));
	#hcbn = hc(traindf,  whitelist=whitelist,blacklist = blacklist, score='bic',restart = 0)
	#hcbn = cextend(gs(traindf, whitelist=whitelist,blacklist = blacklist, optimized=TRUE))
	#hcbn = mmhc(traindf, whitelist=whitelist,blacklist = blacklist, optimized=TRUE)
	hcbn = hc(traindf,score='bic',restart = 0)
	hcbn.fitted = bn.fit(hcbn, traindf, method='bayes')
	hcbn.grain <<- as.grain(hcbn.fitted)
	cat(paste("Step 2 of 3 completed : Building models done\n\n"));
	save.image(file = './steps/step2.RData')
}

doRecommendation <- function()
{
	combinationarray = c()
	riskscorearray = c()
	outputdf = NULL;

	#prediction
	cat(paste("Step 3 of 3 initiated : Doing recommendations...\n"));

	#configs
	mypredictors = names(df)[-grep("thirtyday",names(df))]
	medicationscols = grep("MED.",names(testdf))
	for(i in 1:length(medicationscols))
	{
		testdf[,medicationscols[i]] = as.numeric(as.character(testdf[,medicationscols[i]]))
		testdf[,medicationscols[i]] = 0;
	}
	M = length(medicationscols)
	totalcombinations = length(combn(c(1:M), 3))/3;

	#this should be commented
	testdf = testdf[1,]

	#index variables
	#i : loop across patientdf
	#j : 0 to 19599
	#k : 1:length(medicationscols), just to convert them to factor
	blacklist = read.csv("blacklistcombinations.csv")
	for(i in 1:nrow(testdf))
	{
		count = 0;
		for(j in 0: (totalcombinations-1) )
		#for(j in 0:2)
		{
			cat(paste("j==",j,"\n"))

			mytestrow = data.frame(testdf[i,])

			sequence = combn(c(1:M), 3)[((j*3)+1) : ((j+1)*3)]
			colscombinations = (grep("MED.",names(testdf))-1)[1] + sequence

			#initially assume this is a validcombination
			generatedcombination = names(df)[colscombinations]
			validcombination = 1;

			print(generatedcombination)

			for(k in 1:nrow(blacklist))
			{
				from = blacklist[k,1]
				to = blacklist[k,2]
			    if(from %in% generatedcombination && to %in% generatedcombination)
			    {
			    	validcombination = 0;
			        cat(paste("from==",from,"to==",to,"not a valid combination, blacklist file index == ",k,"\n"))
			        break;
			    }
			}

			if(validcombination == 1)
			{	
				count = count + 1;

				#setting the colscombinations columns to 1, rest all 0
				mytestrow[,colscombinations] = 1

				#converting them to factor for bayesian network
				for(l in 1:length(medicationscols))
				{
					mytestrow[,medicationscols[l]] = as.factor(mytestrow[,medicationscols[l]])
				}

				#doing prediction, probability of getting readmitted==1
				#> riskscore
	            #0         1       NULL
				#[1,] 0.763464 0.1988472 0.03768885
				riskscore = predict(hcbn.grain, response = c("thirtyday"), newdata = mytestrow, predictors = mypredictors, type = "distribution")$pred$thirtyday[2];

				#saving in output
				combinationarray <<- c(combinationarray,paste(colscombinations,collapse="-"))
				riskscorearray <<- c(riskscorearray,riskscore)			
			}
		}
	}
	print(count)

	outputdf <<- data.frame(combinationarray,riskscorearray)
	print(riskscorearray)
	print(combinationarray)
	cat(paste("Step 3 of 3 completed : Building models done\n\n"));
}

#calling user-defined functions
buildModel();
doRecommendation();
