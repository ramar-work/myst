<!---
/* ---------------------------------------------- *
Application.cfc
===============

Author
------
Antonio R. Collins II (rc@tubularmodular.com, ramar.collins@gmail.com)

Copyright
---------
Copyright 2016-Present, "Tubular Modular"
Original Author Date: Tue Jul 26 07:26:29 2016 -0400

Summary
-------
All Application.cfc rules are specified here.

 * ---------------------------------------------- */
 --->
component {

	function onApplicationStart() {
		application.defaultdatasource = "__DATASOURCE__";
		application.sessionManagement = true;
		return true;
	}


	function onRequestStart (string Page) {
		if (structKeyExists(url, "reload")) {
			onApplicationStart();
		}
	}


	function onRequest (string targetPage) {
		try {
			include "index.cfm";
		} 
		catch (any e) {
			writedump( e ); 
			abort;
		}
	}


	function onMissingTemplate (string Page) {
		include "index.cfm";
	}


	/*
	function onError (required any Exception, required string EventName) {
		e = Exception;
		//...
		if ( StructKeyExists( e, "TagContext" ) ) {
			//Short note the tag with the information.
			av = e.TagContext[ 0 ];

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
			include "std/5xx-view.cfm";
		}
	
		//abort;
		include "failure.cfm";
	}
	*/
}
