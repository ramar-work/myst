/* ---------------------------------------------- *
Application.cfc
===============

@author
Antonio R. Collins II (ramar@collinsdesign.net)

@copyright
Copyright 2016-Present, "Tubular Modular"
Original Author Date: Tue Jul 26 07:26:29 2016 -0400

@summary
All Application.cfc rules are specified here.

 * ---------------------------------------------- */
component {

	property name="applicationname";

	function onApplicationStart() {
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
			new myst( targetPage );	
		} 
		catch (any e) {
			writedump( e ); 
			abort;
		}
		return false;
	}


	function onMissingTemplate (string Page) {
		include "_.cfm";
	}
}
