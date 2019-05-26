//base.cfc - should never actually be initialized, but serves as a template for all of the other components
component
name = "base"
accessors = true
{
//The actual name of the component
	property name="realname" type="string"; 
//The endpoint name used by the component
	property name="namespace" type="string"; 
//Debuggable?
	property name="debug" type="boolean" default=0; 
//Datasource used by a component
	property name="datasource" type="string" default="#application.defaultdatasource#"; 
//Prefix for tables used by a component
	property name="dbPrefix" type="string";
//The current Myst instance
	property name="myst";

	//the reference function should probably be here for JS purposes...
	public string function reference ( ) {
		//returns a JSON string with all of the API endpoints (and possibly normal endpoints) used by the component	
		//Find the routes file for the component in question (it's actual name)
	}

	/*
	a setup function should also be here for JS purposes...
	now we have virtual routing, so there is no need to keep it in myst.cfc
	*/
	//Run a setup function, should be accessible remotely to keep it easy
	public string function setup () {
		//put all of your component's setup scripts/files in here

		//more than likely, the datasource needs to be changed to accept multiple queries.
		//then you need to run any SQL statements
		//not sure how hard find and replace is here
		//now change the ddatabase back to it's original OR
		//report any errors via a page

		//TODO: Obviously, anyone being able to call this is a bad idea.
		//A) try 'production mode', where in a user has to explicitly allow updates
		//B) ...? 
	}

	public function init ( mystObject ) {
		//Always tell me what module this is
		var c = getMetadata( this );

		//TODO: Set the "realname" of the component here, so we don't have to use getMetadata over and over again
		//...

		//TODO: Set the rest of the base properties as well (or at least their defaults)
		//...	

		//At least set a reference to Myst before startring, if only there a way to do this from the default key above	
		setMyst( mystObject );

		//TODO: Loop through all of the component's properties, and add something 
		//logging the results of that call...

		//Finally tell me (in a window) which module this is
		writeoutput( "Module #c.name# initialized." );

		return this;
	}

} 
