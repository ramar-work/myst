//base.cfc - should never actually be initialized, but serves as a template for all of the other components
component
name="base"
accessors="true"
{
	//The current Myst instance
	property name="myst";

	//The actual name of the component
	property name="realname" type="string"; 

	//The endpoint name used by the component
	property name="namespace" type="string"; 

	//Debuggable?
	property name="debug" type="boolean" default=0; 

	//Datasource used by a component
	property name="datasource" type="string" default="";

	//Prefix for tables used by a component
	property name="dbPrefix" type="string";

	//Prefix for tables used by a component
	property name="fileNotFoundError" type="string" default="";

	//the reference function should probably be here for JS purposes...
	public string function reference () {
		//returns a JSON string with all of the API endpoints 
		//(and possibly normal endpoints) used by the component	
		//Find the routes file for the component in question (it's actual name)
		return "";
	}

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
		return "";
	}

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

	//Inject dependencies (setters should automatically be done)
	//A dynamic property could be added within this method...
	public void function inject () {}

	public function init ( required mystObject, string realname, string namespace, string dbPrefix, Boolean debuggable, Boolean showInitialization ) {
		//Always tell me what module this is
		var c = getMetadata( this );

		//Set a reference to Myst before starting
		setMyst( mystObject );
		variables.myst = mystObject;

		//Set all of the things...
		if ( StructKeyExists( arguments, "realname" ) )
			variables.realname = arguments.realname ;	
		if ( StructKeyExists( arguments, "namespace" ) )
			variables.namespace = arguments.namespace ;	
		if ( StructKeyExists( arguments, "dbPrefix" ) )
			variables.DBPrefix = arguments.dbPrefix ;	
		if ( StructKeyExists( arguments, "debuggable" ) )
			variables.debug = arguments.debuggable ;	

		//Set the datasource
		variables.datasource = myst.getAppdata().source;
		return this;
	}

} 
