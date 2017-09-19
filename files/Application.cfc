/*
 * All Application.cfc rules should go before the next line.
 * DO NOT DELETE THE NEXT LINE
 *
 */
component {
	this.sessionManagement = true;
	function onRequestStart (string Page) {
		//application.data = DeserializeJSON(FileRead(this.jsonManifest, "utf-8"));
		if (structKeyExists(url, "reload")) {
			onApplicationStart();
		}
	}

	function onRequest (string targetPage) {
		try {
			//include arguments.targetPage;
			include "index.cfm";
		} 
		catch (any e) 
		{ //This bypasses onError
			//You can open CMVC and do something here...
			if ( StructKeyExists( e, "TagContext" ) )
			{
				//Short note the tag with the information.
				av = e.TagContext[ 1 ];

				//Better exception handling is needed here....
				status_code    = 500;
				status_message = 
					"<ul>" &
					"<li>Page '" & arguments.targetPage & "' does not exist.<li>" &
					"<li>At line " & av.line & "</li>" &
					"<li><pre>" & av.codePrintHTML & "</pre></li>" &
					"</ul>";
					av.codePrintHTML &
					"Page '" & arguments.targetPage & "' does not exist."
				;

				//error...
				err = {
					statusCode     = 500
					//This would overwrite the original thing...
					,statusMessage = "Page '" & arguments.targetPage & "' does not exist."
					,message       = "Page '" & arguments.targetPage & "' does not exist."
					,statusLine    = av.line
					,statusPre     = av.codePrintHTML
					,exception     = e
				};

				include "std/5xx-view.cfm";
				abort;
			}

			//What is this?	
			abort;
			
			//Better exception handling is needed here....
			status_code    = 500;
			status_message = 
				"Page '" & arguments.targetPage & "' does not exist.";
			include "std/4xx-view.cfm";
		}
	}

	function onError (required any Exception, required string EventName) 
	{
		writedump(Exception);
		e = Exception;

		//These shouldn't be needed
		//abort;

		if ( StructKeyExists( e, "TagContext" ) )
		{
			//Short note the tag with the information.
			av = e.TagContext[ 0 ];
			//writeoutput( e.TagContext.line );

			//Better exception handling is needed here....
			status_code    = 500;
			status_message = 
				"<ul>" &
				"<li>Page '" & arguments.targetPage & "' does not exist.<li>" &
				"<li>At line " & av.line & "</li>" &
				"<li><pre>" & av.codePrintHTML & "</pre></li>" &
				"</ul>";
				av.codePrintHTML &

				"Page '" & arguments.targetPage & "' does not exist.";
			include "std/5xx-view.cfm";
		}
	
		//abort;
		include "failure.cfm";
	}

	function onMissingTemplate (string Page) {
		include "index.cfm";
	}
}
