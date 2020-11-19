/* ---------------------------------------------- *
 * default.cfc
 * ===========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * Original Author Date: Tue Jul 26 07:26:29 2016 -0400
 * 
 * @summary
 * Example model file	
 * 
 * ---------------------------------------------- */
component extends="std.base.model" {
	function init( myst ) {
		Super.init( myst );
		var data = myst.getAppdata(); 
		return {
			greeting = "Hello, there!"
		,	addText = "and Welcome to Myst!"
		,	site = {
				name = data.getTitle()
			,	dir = myst.getRootdir()
			}
		}
	}
}
