package ParetoOptimizationAlgorithms;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.nio.file.Paths;
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
public class algo4
{
	public static void main(String[] args)
	{
		Pareto myPareto = new Pareto();
		
		/* Populating input and printing them */
		System.out.println("Printing input");
		//myPareto.PopulateSampleInput();
		myPareto.PopulateSampleInputFromFile();
		myPareto.Print(myPareto.options);
		System.out.println("Number of inputs read=="+myPareto.options.size());
		
		/* Printing the Pareto-Optimal solutions */
		final long startTime = System.currentTimeMillis();
		ArrayList<Option> ParetoSolutions = myPareto.FindParetoOptimalSolutions();
		final long endTime = System.currentTimeMillis();
	
		System.out.println("Printing ParetoSolutions : ");
		myPareto.Print(ParetoSolutions);
		
		System.out.println("Total execution time: " + (endTime - startTime) + " milliseconds" );
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
	
	void PopulateSampleInputFromFile()
	{
		try
		{
			String pwd = Paths.get(".").toAbsolutePath().normalize().toString();
			String inputpath = pwd + "/src/ParetoOptimizationAlgorithms/myinput.txt";
			
			FileInputStream fstream = new FileInputStream(inputpath);
			DataInputStream in = new DataInputStream(fstream);
			BufferedReader br = new BufferedReader(new InputStreamReader(in));
			String strLine;
			while ((strLine = br.readLine()) != null)
			{
				String[] tokens = strLine.split(" ");
				Option myoption = new Option(Integer.parseInt(tokens[0]),Integer.parseInt(tokens[1]),Integer.parseInt(tokens[2]));//process record , etc
				options.add(myoption);
			}
			in.close();
		}
		catch (Exception e)
		{
			System.err.println("Error: " + e.getMessage());
		}
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
		
		/* looping across input */
		for(int i = 1;i<options.size();i++)
		{
			boolean ParetoDominant = false;
			boolean ParetoOptimal = true;
			Option optionUnderCheck = options.get(i);
			ArrayList<Integer> IndicesToRemove = new ArrayList<Integer>();
			
			/* looping across ParetoSolutions */
			for(int j = 0;j<ParetoSolutions.size();j++)
			{
				if(isParetoDominant(optionUnderCheck, ParetoSolutions.get(j)) == true)
				{
					ParetoDominant = true;
					IndicesToRemove.add(j);
				}
				
				if(IsParetoDominatedBy(optionUnderCheck, ParetoSolutions.get(j)) == true)
				{
					ParetoOptimal = false;
				}
			}
			
			/* the weaker solutions have to be removed */
			if(ParetoDominant == true)
			{
				Collections.sort(IndicesToRemove, Collections.reverseOrder());
				for(int k = 0;k<IndicesToRemove.size();k++)
				{
					ParetoSolutions.remove(IndicesToRemove.get(k).intValue());
				}
			}
			
			if(ParetoDominant == true || ParetoOptimal == true)
				ParetoSolutions.add(optionUnderCheck);
		}
		
		return ParetoSolutions;
	}
	
	boolean isParetoDominant(Option optionUnderCheck, Option existingSolution)
	{
		if(optionUnderCheck.ReadmitRiskScore <= existingSolution.ReadmitRiskScore && optionUnderCheck.LOSRiskScore <= existingSolution.LOSRiskScore && optionUnderCheck.MortalityRiskScore <= existingSolution.MortalityRiskScore)
			return true;
		return false;
	}
	
	boolean IsParetoDominatedBy(Option optionUnderCheck, Option existingSolution)
	{
		if(optionUnderCheck.ReadmitRiskScore >= existingSolution.ReadmitRiskScore && optionUnderCheck.LOSRiskScore >= existingSolution.LOSRiskScore && optionUnderCheck.MortalityRiskScore >= existingSolution.MortalityRiskScore)
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
