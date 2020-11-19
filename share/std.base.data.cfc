/* ------------------------------------------ *
 * data.cfc
 * --------
 * 
 * @summary
 * Example component-based configuration file. 
 * Application routes, datasources and more are 
 * all updated here.
 * ------------------------------------------- */
component accessors="true" {

	//Set a primary author for SEO purposes
	property name="author" type="string" default="";

	//This should probably not be modified by the user 
	property name="cookie" type="string" setter="false";

	//Turn on debugging
	property name="debug" type="boolean" default="false"; 

	//Set a description for this new application
	property name="description" type="string" default="";

	//Default favicon is a file named favicon.ico that sits at the root, can also be a function
	property name="favicon" default="favicon.ico";

	//Locations for alternate serving locations can go here
	property name="hosts" type="string" default="localhost";

	//Select a datasource
	property name="source" type="string" default="";

	//All requests will use this as the base directory
	property name="base" type="string" default="/";

	//This is a symbolic name for the application
	property name="name" type="string" default="";

	//Set a global site title from here for SEO purposes
	property name="title" type="string" default="";

	//Choose a default 404 page
	property name="404" type="string" default="";

	//Choose a a default 500 page
	property name="500" type="string" default="";

	//Set aliases (usually for datasources) 
	property name="aliases" type="object"; 

	//Set routes (hard to do with pure strings)
	property name="routes" type="object" getter="true"; 

	//Return things
	function init( required myst, required struct routes ) {
		setRoutes( routes );
		return this;
	} 
}
