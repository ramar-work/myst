/*
* coldmvc.java
* ------------
* 
* @author
* 	Antonio R. Collins II (rc@tubularmodular.com, ramar.collins@gmail.com)
* @end
* 
* @copyright
* 	Copyright 2016-Present, "Tubular Modular"
* 	Original Author Date: Tue Jul 26 07:26:29 2016 -0400
* @end
*
*/

//Maybe run an embedded server	
class CLI
{
	//Copy files
	private static int copy ( String a )
	{

	}

	//CREATE
	public static void create ( String a )
	{
		//mkdir whatever...
		//copy whatever...
		//Maybe add new thing to a list somewhere so you don't lose it
	}

//CREATE FROM JSON
	//parse JSON and do whatever


	//REMOVE (only needed if you have a list)
	public static void remove ( String a )
	{

	}


	//DISPLAY ROUTES
	public static void showRoutes ( String a )S
	{

	}

	//CREATE NEW DATASOURCES
	public static void createDatasource ( String a )
	{

	}
	
	//...
	private static String progname = "coldmvc";

	//Print formatted error messages that stop
	private static void err (String message, int status)
	{
		System.err.println( progname + ": " + message );
		return;
	}


	//Parse arguments and run the program
	public static void main (String[] args)
		throws java.io.IOException
	{
		//Die if no arguments given
		if ( args.length == 0 ) 
		{
			err( "No arguments given.", 1 );
			return;
		}

		//Process arguments otherwise
		for ( int i=0; i < args.length; i++ )
		{
			System.out.println( args[ i ] );
			switch ( args[ i ] )
			{
				case "-c":
				case "--create": 
System.out.println( "create chosen" );
					break;
				case "-d":
				case "--datasource": 
System.out.println( "datasource chosen" );
					break;
				case "-f":
				case "--from-file": 
System.out.println( "file chosen" );
					break;
				case "-r":
				case "--remove": 
System.out.println( "remove chosen" );
					break;
				case "-l":
				case "--list-instances":
System.out.println( "list chosen" );
					break;
				case "-t":
				case "--root-dir":
System.out.println( "root chosen" );
					break;
				case "-v":
				case "--verbose":
System.out.println( "verbose chosen" );
					break;
				case "-h":
				case "--help":
System.out.println( "help chosen" );
					break;
				default:
					break;
			}
		}
		return;
	}

	
}
