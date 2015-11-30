package ParetoOptimizationAlgorithms;

import java.util.ArrayList;
import java.util.Collections;

/* Glossary
 * 1. ParetoDominant : If an outcome o is at least as good for another agent as another outcome o' and there is some
 * agent who strictly prefers o to o'. Then o pareto-dominates o'
 * 
 * 2. ParetoOptimal : o* is pareto-optimal if it isn't pareto-dominated by anything else
 * 
 * 3. ParetoSolutions(my term in code) : ParetoDominant + ParetoOptimal solutions
 *   */
public class algo1
{
	public static void main(String[] args)
	{
		Pareto myPareto = new Pareto();
		
		/* Populating input and printing them */
		System.out.println("Printing input");
		myPareto.PopulateSampleInput();
		myPareto.Print(myPareto.options);
		
		/* Printing the Pareto-Optimal solutions */
		ArrayList<Option> ParetoSolutions = myPareto.FindParetoOptimalSolutions();
		System.out.println("Printing ParetoSolutions : ");
		myPareto.Print(ParetoSolutions);
	}
}

class Pareto
{
	ArrayList<Option> options;
	
	public Pareto()
	{
		options = new ArrayList<Option>();
	}
	
	void PopulateSampleInput()
	{
		Option option1 = new Option(25, 30, 34);
		Option option2 = new Option(15, 31, 21);
		Option option3 = new Option(10, 40, 21);
		Option option4 = new Option(50, 30, 34);
		Option option5 = new Option(25, 30, 10);
		Option option6 = new Option(9, 20, 15);
	
		options.add(option1);
		options.add(option2);
		options.add(option3);
		options.add(option4);
		options.add(option5);
		options.add(option6);
	}
	
	void Print(ArrayList<Option> al)
	{
		for(int i = 0;i< al.size();i++)
		{
			System.out.println(al.get(i).ReadmitRiskScore + "," + al.get(i).LOSRiskScore + "," + al.get(i).MortalityRiskScore);
		}
	}
	
	ArrayList<Option> FindParetoOptimalSolutions()
	{
		/* Initialization : Initialize the ParetoSolutions to be the first option */
		ArrayList<Option> ParetoSolutions = new ArrayList<Option>();
		ParetoSolutions.add(options.get(0));
		
		/* Checking if option(i) is either ParetoDominant or ParetoOptimal */
		for(int i = 1;i<options.size();i++)
		{
			/* list of current ParetoSolutions which will be replaced by the optionUnderCheck */
			ArrayList<Integer> IndicesToRemove = new ArrayList<Integer>();
			Option optionUnderCheck = options.get(i);
			
			/* Checking if optionUnderCheck is ParetoDominant */
			int size = ParetoSolutions.size();
			for(int j = 0; j<size;j++)
			{
				Option existingSolution = ParetoSolutions.get(j);
				if(isParetoDominant(optionUnderCheck, existingSolution) == true)
				{
					IndicesToRemove.add(j);
				}
			}
			
			/* This option is a ParetoDominant solution, going to remove the weaker solution it dominates */
			if(IndicesToRemove.size() > 0)
			{
				Collections.sort(IndicesToRemove, Collections.reverseOrder());
				for(int k = 0;k<IndicesToRemove.size();k++)
				{
					ParetoSolutions.remove(IndicesToRemove.get(k).intValue());
				}
				ParetoSolutions.add(optionUnderCheck);
			}
			
			/* Checking if optionUnderCheck is ParetoOptimal */
			else
			{
				if(isParetoOptimal(optionUnderCheck, ParetoSolutions))
				{
					ParetoSolutions.add(optionUnderCheck);
				}
			}
		}
		
		return ParetoSolutions;
	}
	
	/* all agents */
	boolean isParetoDominant(Option optionUnderCheck, Option existingSolution)
	{
		if(optionUnderCheck.ReadmitRiskScore <= existingSolution.ReadmitRiskScore && optionUnderCheck.LOSRiskScore <= existingSolution.LOSRiskScore && optionUnderCheck.MortalityRiskScore <= existingSolution.MortalityRiskScore)
			return true;
		return false;
	}
	
	/* any one agent */
	boolean isParetoOptimal(Option optionUnderCheck, ArrayList<Option> ParetoSolutions)
	{
		ArrayList<Integer> ReadmitRiskScoreArray = new ArrayList<Integer>();
		ArrayList<Integer> LOSRiskScoreArray = new ArrayList<Integer>();
		ArrayList<Integer> MortalityRiskScoreArray = new ArrayList<Integer>();
		
		for(int i = 0;i<ParetoSolutions.size();i++)
		{
			ReadmitRiskScoreArray.add(ParetoSolutions.get(i).ReadmitRiskScore);
			LOSRiskScoreArray.add(ParetoSolutions.get(i).LOSRiskScore);
			MortalityRiskScoreArray.add(ParetoSolutions.get(i).MortalityRiskScore);
		}
		
		if(minimum(optionUnderCheck.ReadmitRiskScore, ReadmitRiskScoreArray) == true ||
		minimum(optionUnderCheck.LOSRiskScore, LOSRiskScoreArray) == true ||
			minimum(optionUnderCheck.MortalityRiskScore, MortalityRiskScoreArray) == true )
		{
			return true;
		}
		return false;
	}
	
	boolean minimum(int check, ArrayList<Integer> al)
	{
		for(int i = 0;i<al.size();i++)
		{
			if(check >= al.get(i))
				return false;
		}
		return true;
	}
}
 
class Option
{
	int ReadmitRiskScore;
	int LOSRiskScore;
	int MortalityRiskScore;
	
	public Option(int ReadmitRiskScore, int LOSRiskScore, int MortalityRiskScore)
	{
		// TODO Auto-generated constructor stub
		this.ReadmitRiskScore = ReadmitRiskScore;
		this.LOSRiskScore = LOSRiskScore;
		this.MortalityRiskScore = MortalityRiskScore;
	}
}