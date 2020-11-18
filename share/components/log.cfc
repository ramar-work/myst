/* ---------------------------------------------- *
 * log.cfc
 * =======
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Handles logging.
 * 
 * ---------------------------------------------- */
component extends="base" {

	//Directory to use when writing to file.
	property name="directory" type="string" default="log.txt";

	//Where the file should be written out
	property name="file" type="string" default="log.txt";

	//...
	property name="format" type="string" default="EEEE mmmm d, yyyy HH:NN:SS tt";

	//...
	property name="runId" type="string"; 

	//...
	property name="style" type="string" default="standard";

	//Choose either db logging, plaintext logging or custom logging through a function
	property name="type" type="string" default="plaintext";


	/**
	 * Write out log to file using $format mask
 	 *
	 **/
	private string function format( required string message ) {
		var d = DateTimeFormat( Now(), this.getFormat() );
		var id = this.getRunId() 
		return "#id#: [#d# EST] #arguments.message#" & Chr(10) & Chr(13);
	}


	/** 
	 * Perform logging.
	 *
	 * @param message        String message to write to log.
	 */
	public void function report( required String message ) {
		try {
			if ( getLogStyle() eq "standard" ) { 
				//Do a verbose log
				var id = getRunId();
				var d = DateTimeFormat( Now(), "EEEE mmmm d, yyyy HH:NN:SS tt" );
				var logMessage = "#id#: [#d# EST] #arguments.message#" & Chr(10) & Chr(13);
				var m = FileAppend( getLogFile(), logMessage );
				//writeoutput( logMessage );
				//writedump(m); abort;
			//'127.0.0.1 - - [#DateFormat()#] "#cgi.request_method# #cgi.path_info# HTTP/1.1" status content-size'
			}
			else {
				//Error out if this is a developement server.
				0;
			}

		//Append the line number to whatever text is being written
		//this.logstring = ( StructKeyExists( this, "addLogLine") && this.addLogLine ) ? "<li>At line " & line & " in template '" & template & "': " & message & "</li>" : "<li>" & message & "</li>";
		//(StructKeyExists(this, "verboseLog") && this.verboseLog) ? writeoutput( this.logString ) : 0;
		}
		catch (any e) {
			//TODO: Obviously, this should pretty much always run
			//Simply catching and throwing an error isn't a good solution...
			writedump(e);
			abort;
		}
	}


	function init(){
		return this;
	}
}
