/* ---------------------------------------------- *
 * ctx.cfc
 * ========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Methods for dealing with myst context.
 * 
 * ---------------------------------------------- */
component name="ctx" accessors="true" {

	//Accepts certain types (can be a list too, since that makes it easier)
	property name="accepts" type="string" default="";

	//Code that runs before everything (can be whatever)
	property name="before"; //type="query";

	//Components loaded during the lifetime of the current thread go here...
	property name="components" type="struct";

	//Each context should have an expected content type
	property name="contentType" type="string" default="text/html";

	//Variables expected to be in a request 
	property name="expects" type="string" default="";

	//Custom headers to set during the life of an response 
	property name="headers" type="struct";

	//The model (all of that wrapping takes place here)
	property name="model" type="struct";

	//A query
	property name="query" type="query";

	//The active route goes here	
	property name="route" type="struct";

	//Variables and content passed in after execution go here...
	property name="scope" type="struct";

	//Custom status to set somewhere
	property name="status" type="numeric" default=200;

	//The view data
	property name="view" type="string" default="";

	function init() {
		return this;
	}

}
