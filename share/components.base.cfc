/* ---------------------------------------------- *
base.cfc
========

@author
Antonio R. Collins II (ramar@collinsdesign.net)

@copyright
Copyright 2016-Present, "Tubular Modular"
Original Author Date: Tue Jul 26 07:26:29 2016 -0400

@summary
This serves as the base for extensions to Myst.

 * ---------------------------------------------- */
component
name="base"
accessors="true"
{
	//Debuggable
	property name="debug" type="boolean" default="false"; 

	//Datasource used by a component
	property name="datasource" type="string" default="";

	//Prefix for tables used by a component
	property name="dbPrefix" type="string";

	//The current Myst instance
	property name="myst";

	//The endpoint name used by the component
	property name="namespace" type="string"; 

	//The actual name of the component
	property name="realname" type="string"; 

	//Allow the component to use its own routes
	property name="routes" type="boolean" default="true";

	//Return the full asset path w/o using link()	
	public string function getAssetPath( required string type, required string file ) {
		return "#getMyst().getUrlBase()#assets/#type#/#getNamespace()#/#file#";
	}

	//Return the path to what should be an endpoint.
	public string function getPublicPath( required String file ) {
		return "#getMyst().getUrlBase()##getNamespace()#/#file#";
	}
	
	//Return the path to what should be an endpoint.
	public function getPrivatePath( required string file ) {
		return "#getMyst().getUrlBase()#files/#getNamespace()#/#file#";
	}

	public function getPrivatePathAsStatic( required string file ) {
		return getMyst().serveStaticResource([], getPrivatePath( file ), getFileNotFoundError());
	}

	public function getPassivePath() {
		return getPrivatePathAsStatic( route.active );
	}

	function init ( required myst ) {
		//Always tell me what module this is
		var c = getMetadata( this );

		//Set a reference to Myst before starting
		variables.myst = myst;

		//Set the datasource
		variables.datasource = myst.getAppdata().source;

		//Return the object
		return this;
	}
} 
