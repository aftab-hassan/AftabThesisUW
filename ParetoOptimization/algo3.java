package ParetoOptimizationAlgorithms;

import java.util.ArrayList;

/* Glossary
 * 1. ParetoDominant : If an outcome o is at least as good for another agent as another outcome o' and there is some
 * agent who strictly prefers o to o'. Then o pareto-dominates o'
 * 
 * 2. ParetoOptimal : o* is pareto-optimal if it isn't pareto-dominated by anything else
 * 
 * 3. ParetoSolutions(my term in code) : ParetoDominant + ParetoOptimal solutions
 *   */
public class algo3
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
		Option option4 = new Option(30, 30, 34);
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
		int totalagents = 3;
		int agent = 0;
		while(agent < totalagents)
		{
			ArrayList<ArrayList<Integer>> bucket = new ArrayList<ArrayList<Integer>>();
			
			/* made 100 buckets */
			for(int i = 0;i<100;i++)
				bucket.add(new ArrayList<Integer>());
			
			for(int i = 0;i<options.size();i++)
			{
				if(agent == 0)
				{
					bucket.get(options.get(i).MortalityRiskScore).add(i);
				}
				
				if(agent == 1)
				{
					bucket.get(options.get(i).LOSRiskScore).add(i);
				}
				
				if(agent == 2)
				{
					bucket.get(options.get(i).ReadmitRiskScore).add(i);
				}
			}
			
			/* re-arranging the options after this iteration */			
			ArrayList<Option> optionstemp = new ArrayList<Option>();
			for(int i = 0 ;i<100;i++)
			{
				if(bucket.get(i).isEmpty() == false)
				{
					for(int j = 0;j<bucket.get(i).size();j++)
					{
						optionstemp.add(options.get(bucket.get(i).get(j)));
					}	
				}
			}
			
			for(int i = optionstemp.size()-1;i >= 0;i--)
				options.remove(i);
			for(int i = 0;i<optionstemp.size();i++)
				options.add(optionstemp.get(i));
			agent++;
		}
		
		ArrayList<Option> ParetoSolutions = new ArrayList<Option>();
		ParetoSolutions.add(options.get(0));
		Option lastParetoSolution = ParetoSolutions.get(0);
		for(int i = 1;i<options.size();i++)
		{
			Option optionUnderCheck = options.get(i);
			if(isParetoOptimal(lastParetoSolution, optionUnderCheck) == true)
			{
				lastParetoSolution = optionUnderCheck;
				ParetoSolutions.add(optionUnderCheck);
			}
		}
		
		return ParetoSolutions;
	}	
	
	boolean isParetoOptimal(Option lastParetoSolution, Option optionUnderCheck)
	{
		if(optionUnderCheck.ReadmitRiskScore < lastParetoSolution.ReadmitRiskScore || optionUnderCheck.LOSRiskScore < lastParetoSolution.LOSRiskScore || optionUnderCheck.MortalityRiskScore < lastParetoSolution.MortalityRiskScore)
			return true;
		return false;
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