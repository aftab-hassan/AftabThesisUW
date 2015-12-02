#Run this script from the terminal as
#Rscript generateinput.R <number of inputs> > myinput.txt
#Eg Rscript generateinput.R 1000 > myinput.txt

args<-commandArgs(TRUE)
limit = args[1]

for(i in 1:limit)
{
	cat(sample(1:100,3),"\n")
}
