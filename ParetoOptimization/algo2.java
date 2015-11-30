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
public class algo2
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
		Option[] map = new Option[7];
		
		/* Initialization : Initially the best solution for minimizing all objectives is the first solution */
		for(int i = 0;i<map.length;i++)
			map[i] = options.get(0);
		
		for(int i=1;i<options.size();i++)
		{
			/* Fixing {1} */
			if(options.get(i).ReadmitRiskScore < map[0].ReadmitRiskScore)
				map[0] = options.get(i);
			
			/* Fixing {2} */
			if(options.get(i).LOSRiskScore < map[1].LOSRiskScore)
				map[1] = options.get(i);
			
			/* Fixing {3} */
			if(options.get(i).MortalityRiskScore < map[2].MortalityRiskScore)
				map[2] = options.get(i);
			
			/* Fixing {1,2} */
			if(options.get(i).ReadmitRiskScore <= map[3].ReadmitRiskScore && options.get(i).LOSRiskScore <= map[3].LOSRiskScore)
				map[3] = options.get(i);
			
			/* Fixing {1,3} */
			if(options.get(i).ReadmitRiskScore <= map[4].ReadmitRiskScore && options.get(i).MortalityRiskScore <= map[4].MortalityRiskScore)
				map[4] = options.get(i);
			
			/* Fixing {2,3} */
			if(options.get(i).LOSRiskScore <= map[5].LOSRiskScore && options.get(i).MortalityRiskScore <= map[5].MortalityRiskScore)
				map[5] = options.get(i);
			
			/* Fixing {1,2,3} */
			if(options.get(i).ReadmitRiskScore <= map[6].ReadmitRiskScore && options.get(i).LOSRiskScore <= map[6].LOSRiskScore && options.get(i).MortalityRiskScore <= map[6].MortalityRiskScore)
				map[6] = options.get(i);
		}
		
		return findUnique(map);
	}
	
	ArrayList<Option> findUnique(Option[] map)
	{
		ArrayList<Option> ParetoSolutions = new ArrayList<>();
		for(int i = 0;i<map.length;i++)
		{
			if(!ParetoSolutions.contains(map[i]))
				ParetoSolutions.add(map[i]);
		}
		return ParetoSolutions;
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