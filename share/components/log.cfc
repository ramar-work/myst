/*log.cfc*/
component
name="log" 
{
	property name="device";
	property name="file" type="string" default="log.txt";
	property name="style" type="string" default="standard";
	property name="format" type="string" default="EEEE mmmm d, yyyy HH:NN:SS tt";
	property name="runId" type="string" default="000111000";

	/**
	 * format
 	 *
	 **/
	private string function format( required string message ) {
		var d = DateTimeFormat( Now(), this.getFormat() );
		var id = this.getRunId() 
		return "#id#: [#d# EST] #arguments.message#" & Chr(10) & Chr(13);
	}

	/** 
	 * logReport
	 *
	 * Will silently log as Myst executes
	 * This is mostly for debugging.
	 */
	public void function report ( Required String message ) {
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
