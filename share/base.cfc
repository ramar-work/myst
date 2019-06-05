//base.cfc - should never actually be initialized, but serves as a template for all of the other components
component
name="base"
accessors=true
{
	//The actual name of the component
	property name="realname" type="string"; 

	//The endpoint name used by the component
	property name="namespace" type="string"; 

	//Be extra verbose and let the developer know everything that is going on.
	property name="debuggable" type="boolean" default=0; 

	//Tell me everything
	property name="verbose" type="boolean" default=0; 

	//Datasource used by a component
	property name="datasource" type="string" default="#application.defaultdatasource#"; 

	//Prefix for tables used by a component
	property name="dbPrefix" type="string";

	//The current Myst instance
	property name="myst";

	//Run a setup function, should be accessible remotely to keep it easy
	public string function setup ( string datasource ) {
		//All of your component's setup scripts/files go here
		var ds = getDatasource(); var ns = getNamespace();

		//if this is part of a module, handle that, setupfiles can be an array
		var fname = "#getMyst().getRootDir()#setup/#ns#/setup.sql";

		//check for the file
		if ( !FileExists( fname ) )
			getMyst().sendAsJson(status=500, mime="text/html", content="Couldn't find setup file for #ns#");
			 
		//choose a datasource
		if ( StructKeyExists( arguments, "datasource" ) )
			ds = arguments.datasource;
		else {
			//Instantiate Application just to see where things are
			//TODO: There must be a way to just get the ds name...
			var a = createObject("component","Application" );

			//check in application scope for ds, then other places
			if ( StructKeyExists( a, "datasource" ) )
				getMyst().sendAsJson(status=200,mime="text/html",content="application.datasource = #a.datasource#" );
			else if ( StructKeyExists( a, "defaultdatasource" ) )
				getMyst().sendAsJson(status=200,mime="text/html",content="application.defaultdatasource = #a.defaultdatasource#" );
			else if ( StructKeyExists( a, "datasources" ) ) {
				//unless myst has run, if there is only one ds there...
				//this should probably use it...
				//load application.datasources and if only one member, 
				//use that....
				if ( StructCount( a.datasources ) gt 1 ) {
					getMyst().sendAsJson(status=500,mime="text/html",content="No default datasource was found.  Additionally, there is more than one datasource specified for this instance.  Please explicitly denote which one to use when setting up." );
				}

				//crudely loop to get the first index	
				for ( var tds in a.datasources ) {
					ds = tds;
					break;
				}
			}
		}

		//open it and read it's content
		var fbuf = FileRead( fname );

		//execute as a query (I guess a big ass string)
		var res = getMyst().dbExec(
			string = fbuf
		, datasource = ds 
		);
	
		//return a status
		if ( !res.status ) 
			getMyst().sendAsJson( status=500, mime="text/html", content="Failed to create data tables for #ns# in database '#getDatasource()#'" );	
		else {
			getMyst().sendAsJson( status=200, mime="text/html", content="All is well" );	
		}
	}

	//Return the component's full asset path w/o using link()	
	public string function getAssetPath( required String type, required String file ) {
		return "#getMyst().getUrlBase()#assets/#arguments.type#/#getNamespace()#/#arguments.file#";
	}

	//Return the component's endpoint path
	public string function getPublicPath( required String file ) {
		return "#getMyst().getUrlBase()##getNamespace()#/#arguments.file#";
	}
	
	//Return the component's private file path
	public string function getPrivatePath( required String file ) {
		return "#getMyst().getUrlBase()#files/#getNamespace()#/#arguments.file#";
	}

	//TODO: Get CSS image path (??? not sure if this should be a base method or not)
	/*
	public string function getCssImagePath( Required string img ) {
		return "background-image:url( #getAssetPath('img',img)# ); background-size: 100%;";	
	}
	*/

	//TODO: Get JS image path (??? not sure if this should be a base method or not)
	/*
	public string function getJsPath( Required string img ) {
		return "background-image:url( #getAssetPath('img',img)# ); background-size: 100%;";	
	}
	*/

	//TODO: Inject dependencies here (setters should automatically be done)
	public void function inject ( ) {

	}

	//TODO: Return a JSON string with all of the API endpoints 
	public string function reference ( ) {
		//TODO: Locate routes and anything under routes that is under the 
		//current component's namespace
	}

	public Base function init ( required mystObject, string realname, string namespace, string datasource, Boolean debuggable, Boolean verbose ) {
		//Always tell me what module this is
		var c = getMetadata( this );

		//Set myst object and all other base properties. 
		setMyst( mystObject );
		//variables.myst = mystObject;

		//Set all other base properties
		for ( var vv in ListToArray("realname,namespace,debuggable,datasource")) {
			if ( /*!StructKeyExists(variables,vv) && */StructKeyExists(arguments, vv) && arguments[vv] neq "" ) variables[vv] = arguments[vv];
		}

		//Finally tell me (in a window) which module this is
		if ( StructKeyExists( arguments, "verbose" ) && arguments.verbose ) { 
			writeoutput( "Module #c.name# initialized.<br />" );
		}
		return this;
	}
} 
