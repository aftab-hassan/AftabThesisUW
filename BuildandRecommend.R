###########################################################################
#Purpose : Integrated script which will do the following
#	   1.Train Bayesian Network Model
#	   2.Generate Readmit Risk scores for all 50c3 combinations of medications
#	   3.Generate LOS Risk scores for all 50c3 combinations of medications
#	   4.Generate Mortality Risk scores for all 50c3 combinations of medications

#To run  : Rscript bn.R <inputfile>
###########################################################################
#clear
rm(list=ls())

#start time
start = proc.time()

#turn off warnings
options(warn=-1)

#global variables
riskscorearray = c()
combinationarray = c()
patientidarray = c()
outputdf = NULL

#user-defined functions
lastn <- function(x, n)
{
  substr(x, nchar(x)-n+1, nchar(x))
}

#building bn model
buildModel <- function()
{
cat(paste("Step 1 of 2 initiated : Building models...\n"));

#hcbn = hc(bndf,  whitelist=whitelist,blacklist = blacklist, score='bic',restart = 0)
#hcbn = cextend(gs(bndf, whitelist=whitelist,blacklist = blacklist, optimized=TRUE))
#hcbn = mmhc(bndf, whitelist=whitelist,blacklist = blacklist, optimized=TRUE)

#right now, not using any blacklist or whitelist
hcbn = hc(bndf, score='bic',restart = 0)

hcbn.fitted = bn.fit(hcbn, bndf, method='bayes')
hcbn.grain <<- as.grain(hcbn.fitted)
cat(paste("Step 1 of 2 completed : Building models done\n\n"));
save.image(file = './step1.RData')
}

doRecommendation <- function()
{
	#combinationarray = c()
	#riskscorearray = c()
	#outputdf = NULL;

	#prediction
	cat(paste("Step 2 of 2 initiated : Doing recommendations...\n"));

	#configs
	mypredictors = names(df)[-grep("Readmit",names(df))]
	medicationscols = grep("MED.",names(testdf))
	for(i in 1:length(medicationscols))
	{
		testdf[,medicationscols[i]] = as.numeric(as.character(testdf[,medicationscols[i]]))
		testdf[,medicationscols[i]] = 0;
	}
	M = 50
	totalcombinations = length(combn(c(1:M), 3))/3;

	#19600 recommendations

	#this should be commented
	#doing with a small test set of 5 patients initially
	testdf = testdf[1:5,]

	#index variables
	#i : loop across patientdf
	#j : 0 to 19599
	#k : 1:length(medicationscols), just to convert them to factor
	for(i in 1:nrow(testdf))
	{
		for(j in 0: (totalcombinations-1) )
		#for(j in 0:5)
		{
			mytestrow = data.frame(testdf[i,])

			sequence = combn(c(1:M), 3)[((j*3)+1) : ((j+1)*3)]
			colscombinations = (grep("MED.",names(testdf))-1)[1] + sequence

			cat(paste("j==",j+1))
			print(colscombinations)

			#setting the colscombinations columns to 1, rest all 0
			mytestrow[,colscombinations] = 1

			#converting them to factor for bayesian network
			for(k in 1:length(medicationscols))
			{
				mytestrow[,medicationscols[k]] = as.factor(mytestrow[,medicationscols[k]])
			}

			#doing prediction, probability of getting readmitted==1
			#> riskscore
		              #0       1         NULL
			#[1,] 0.763464 0.1988472 0.03768885
			riskscore = predict(hcbn.grain, response = c("Readmit"), newdata = mytestrow, predictors = mypredictors, type = "distribution")$pred$Readmit[2];

			#saving in output
			combinationarray <<- c(combinationarray,paste(colscombinations,collapse="-"))
			riskscorearray <<- c(riskscorearray,riskscore)
			patientidarray <<- c(patientidarray,i)
		}
	}

	outputdf <<- data.frame(combinationarray,riskscorearray,patientidarray)
	#print(riskscorearray)
	#print(combinationarray)
	cat(paste("Step 2 of 2 completed : Recommendation done\n\n"));
}

#read input
inputfile = "final-table-full.rds"
df = readRDS(inputfile)

#read blacklist and whitelist
#whitelist = read.csv('whitelist.csv')
#blacklist = read.csv('blacklist.csv')

#split data into two types of train data, one for building the model called(bndf) and one for prediction called (testdf)
#use 80% of the data for training., 20% for testing
traindf = df[1:(0.9*nrow(df)),]
testdf = df[((0.9*nrow(df))+1):nrow(df),]

#load necessary packages
suppressMessages(library(bnlearn))
suppressMessages(library(gRain))
suppressMessages(library(foreach))
suppressMessages(library(doMC))

#Build Bayesian Network
buildModel();

#Do Recommendation
doRecommendation();

end = proc.time()
cat(paste("Time taken == ",(end-start)[3]))
