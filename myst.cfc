/* --------------------------------------------------
myst.cfc
========

Author
------
Antonio R. Collins II 
(ramar@collinsdesign.net, ramar.collins@gmail.com)

Copyright
---------
Copyright 2016 - Present, "Tubular Modular, Inc."
Original Author Date: Tue Jul 26 07:26:29 2016 -0400

Summary
-------
An MVC like structure for handling CFML pages.

Usage
-----
Drop this file into your application's web root and
call it using index.cfm or Application.cfc.

TODO
----
- Add a 'test' directory for tests
	In this folder have tests for functions
	Have another folder for mock views and apps
	When you deploy, these can be deleted or moved (or simply ignored)

- Add a mock function: 
	mock(..., { abc="string", def="numeric", ... })

- Look into adding a task to the Makefile to automate adding notes to the CHANGELOG below

- Add the ability to select different views depending on some condition in the model

- Add the ability to redirect on failure depending on some condition in the model

- Complete the ability to log to other outputs (database, web storage, etc)

- What kind of task system would work best?

- Create app scopes as the same name of the file that vars are declared in.  
	I'm thinking that this would make it easy to follow variables throughout 
	more complex modules.

- Add an option for mock/static data (it goes in db and can be queried)

- how to add a jar to a project?

- step 1 - must figure out how to use embedded databases...

- add one of the embedded database to cmvc tooling

- add logExcept (certain statements, you might want to stop at)

- log (always built in, should always work regardless of backend)	

- db (space for static data models)

- middleware (stubs of functionality that really don't belong in app)

- routes (stubs that define routes placed by middleware or something else)

- settings (static data that does not change, also placed by middleware)

- sql (technically, middleware can drop here too)

- orm, the built-in works fine, but so does other stuff...

- parse JSON at application

- make sure application refresh works...

- parsing of JSON and creation

- 404 pages need to be pretty and customizable

- 500 pages need to be pretty and customizable

- need a way to take things down for maintenance

- maybe add a way to enable tags? ( a tags folder )

 * -------------------------------------------------- */
component 
name="Myst" 
accessors=true 
{

	//TODO: This should be a property accessible by everything
	property name="compName" type="string" default="Myst";

	//The resource name that's been loaded
	property name="rname" type="string";

	//Test mode
	property name="apiAutodie" type="boolean" default=1;

	//The datasource that will be used during the life of the app.
	property name="datasource" type="string";

	//The 'manifest' value that is loaded at the beginning of starting a Myst app
	property name="appdata"; 

	//Set all http headers once at the top or something...
	property name="httpHeaders" type="struct"; 

	//....
	property name="mimeToFileMap" type="struct"; 

	//....
	property name="fileToMimeMap" type="struct"; 

	//Set post functions
	property name="postMap"; 

	//Set pre functions
	property name="preMap"; 

	//The root directory
	property name="rootDir" type="string"; 

	//The current directory as Myst navigates through the framework directories.
	property name="currentDir" type="string"; 

	//List of app folder names that should always be disallowed by an HTTP client
	property name="arrayConstantMap" type="array"; 

	//Choose a path seperator depending on system.
	property name="pathSep" type="string" default="/";  

	//Relative path maps for framework directories
	property name="constantMap" type="struct"; 

	//Relative path maps for framework directories
	property name="routingKeys" type="string"
		default="before,after,accepts,expects,filter,returns,scope";
		//default="before,after,accepts,expects,returns,scope,query";

	//Relative path maps for framework directories
	property name="urlBase" type="string" default="/"; 

	/*New as of 11/27*/
	//Allow methods to reference the current content-type
	//NOTE: An enum would be safer here, but you'll just want to use a custom setter...
	property name="selectedContentType" type="string" default="text/html"; 
	property name="contentOn404" type="string" default="File not found."; 
	property name="contentOn410" type="string" default="Authentication denied."; 
	property name="contentOn500" type="string" default="Error occurred."; 
	property name="selectedContentType" type="string" default="text/html"; 

	//property name="logString" type="struct";
	property name="logStyle" type="string" default="standard"; //combined, common,
	property name="logType" type="string" default="file";
	property name="logFile" type="string" default="log.txt";
	property name="logFormatCommon" type="string" default="";
	property name="logFormatCombined" type="string" default="";
	property name="logFormat" type="string" default="log.txt";
	property name="runId" type="string" default="";

	//
	property name="pageStatus" type="number" default=200;
	property name="pageStatusMessage" type="string" default="";
	property name="pageMessage" type="string" default="";
	property name="pageError" default="";
	property name="pageErrorExtractors" default="detail,message,type"; /*tagContext,stackTrace*/

	/*DEPRECATE THESE?*/
	//Structs that might be loaded from elsewhere go here (and should really be done at startup)
	property name="objects" type="struct";

	//property name="pageScope" type="struct"; //setter=false getter=false;
	variables.pageScope = {}; //setter=false getter=false;

	//Defines a list of resources that we can reference without naming static resources
	this.action  = {};

	//Struct for pre and post functions when generating webpages
	this.functions  = StructNew();

	/*VARIABLES - None of these get a docblock. You really don't need to worry with these*/
	this.logString = "";

	this.dumpload = 1;


	/** DEBUGGING **
 * --------------------------------------------------------------------- */

	/** 
	 * dump_routes 
	 *
	 * Dump all routes.
	 */
	public String function dump_routes () {
		savecontent variable="cms.routeInfo" { 
			_include ( "std", "dump-view" ); 
		}
		return cms.routeInfo;
	}

	
	//Log messages and return true
	private Boolean function plog ( String message, String loc ) {
		//Open the log file (or database if there is one)
		if ( 0 ) {
			if ( !StructKeyExists( data, "logTo" ) )
				data.logstream = 2; // 2 = stderr, but will realistically write elsewhere...
			else if ( StructKeyExists( data, "logTo" ) ) { 
				//If logTo exists and is a string, then it's a file
				//If logTo exists and is a struct, then check the members and roll from there
				//type can be either "db" or "file", maybe "web" in the future...
				//path is the next parameter, 
				//and datasource should also be there, since cf can't do much without them...
				data.logstream = 3;
			}
			abort;
		}
		
		writeoutput( message ); 
		return true;	
	}


	//Create parameters
	private string function crparam( ) {
		//string
		urll = "";

		//All of these should be key value structs
		for ( var k in arguments ) {
			for ( kk in arguments[ k ] ) {
				urll = urll & "v" & hash( kk, "SHA-384", "UTF-8"/*, 1000*/ ) & "=";
				urll = urll & arguments[ k ][ kk ];
			}
		}

		urll = Left( urll, Len(urll) - 1 );
		return urll;
	}


	/** 
	 * hashp
	 *	
	 * Hash function for text strings
	 */
	private Struct function hashp( p ) {
		//Hash pass.username
		puser = hash( p.user, "SHA-384", "UTF-8"/*, 1000*/ );
		//writeoutput( "<br />" & puser );

		//key
		key = generateSecretKey( "AES", 256 );
		//writeoutput( "<br />" & key );

		//Hash password
		ppwd = "";
		ppwd = hash( p.password, "SHA-384", "UTF-8"/*, 1000*/ );

		return {
			user = puser,
			password = ppwd
		};	
	}

	
	/** 
	 * logReport
	 *
	 * Will silently log as Myst executes
	 * This is mostly for debugging.
	 */
	private function logReport ( Required String message ) {
		if ( getLogStyle() eq "standard" ) { 
			//Do a verbose log
			var id = getRunId();
			var d = DateTimeFormat( Now(), "EEEE mmmm d, yyyy HH:NN:SS tt" );
			var m = FileAppend( getLogFile(), "#id#: [#d# EST] #arguments.message#" & Chr(10) & Chr(13) );
			//writedump(m); abort;
		//'127.0.0.1 - - [#DateFormat()#] "#cgi.request_method# #cgi.path_info# HTTP/1.1" status content-size'
		}
		else {
			//Error out if this is a developement server.
			0;
		}

		//Append the line number to whatever text is being written
		//this.logstring = ( StructKeyExists( this, "addLogLine") && this.addLogLine ) ? "<li>At line " & line & " in template '" & template & "': " & message & "</li>" : "<li>" & message & "</li>";
		//(StructKeyExists(this, "verboseLog") && this.verboseLog) ? writeoutput( this.logString ) : 0;
	}



	/** FORMATTING/HTML **
 * --------------------------------------------------------------------- */

	/**
	 * link( ... )
	 *
	 * Generate links relative to the current application and its basedir if it
	 * exists.
	 */
	public string function link () {
		//Define spot for link text
		var linkText = "";

		//Base and stuff
		if ( Len( data.base ) > 1 || data.base neq "/" )
			linkText = ( Right(data.base, 1) == "/" ) ? Left( data.base, Len( data.base ) - 1 ) : data.base;

		//Concatenate all arguments into some kind of hypertext ref
		for ( x in arguments ) {
			linkText = linkText & "/" & ToString( arguments[ x ] );
		}

		//Figure out what to do...
		if ( Len( linkText ) > 1 ) { 
			var f = Find( "?", linkText );
			if ( StructKeyExists( data, "autoSuffix" ) && Right( linkText, 4 ) != ".cfm" ) {
				if ( f == 0 ) 
					linkText &= ".cfm";
				else {
					var p = ListToArray( linkText, "?" );
					linkText = "#p[1]#.cfm?#p[2]#";
				}
			}
		}
		return linkText;
	}


	/**
	 * href( ... )
	 *
	 * Generate links relative to the current application and its basedir if it
	 * exists.
	 */
/*
	public string function href ( ) {
		//Define spot for link text
		var ltx = "";

		//Base and stuff
		if ( Len(data.base) > 1 || data.base neq "/" )
			ltx = ( Right(data.base, 1) == "/" ) ? Left( data.base, Len(data.base) - 1 ) : data.base;

		//Concatenate all arguments into some kind of hypertext ref
		for ( var x in arguments )
			ltx = ltx & "/" & ToString( arguments[ x ] );

		//Check data.cfm for the autoSuffix key
		if ( StructKeyExists( data, "autoSuffix" ) ) {
			if ( Len( ltx ) > 1 && Right( ltx, 4 ) != ".cfm" ) {
				ltx &= ".cfm";
			}
		}

		return ltx;
	}
*/

	/**
	 * crumbs( ... )
	 *
	 * Create "breadcrumb" link for really deep pages within a webapp. 
	 */
	public function crumbs () {
		throw "EXPERIMENTAL";
		var a = ListToArray(cgi.path_info, "/");
		//writedump (a);
		/*Retrieve, list and something else needs breadcrumbs*/
		for (var i = ArrayLen(a); i>1; i--) {
			/*If it's a retrieve page, have it jump back to the category*/
			writedump(a[i]);
		}
	}



	/** FORMS **
 * --------------------------------------------------------------------- */

	/**
	 *  upload_file 
	 *
	 * 	Handles file uploads args
	 */	
	public Struct function upload_file ( String formField, String mimetype ) {
		//Create a file name on the fly.
		var a;
		var cm = getConstantMap();
		var fp = cm[ "files" ]; 
		fp = ToString(Left(fp, Len(fp) - 1)); 
		
		//Upload it.
		try {
			a = FileUpload(
				fp,           /*destination*/
				formField,    /*Element from form to write*/
				mimetype,     /*No mimetype limit*/
				"MakeUnique"  /*file name overwrite function*/
			);

			a.fullpath = a.serverdirectory & getPathsep() & a.serverfile;
			return { status = true, results = a };
		}
		//Perhaps this only throws an error on certain file types...
		catch ( coldfusion.tagext.io.FileUtils$InvalidUploadTypeException e ) {
			return {
				status = false,
				results = e 
			};
		}
		catch ( any e ) {
			return {
				status = false,
				results = e.message
			};
		}
		
		//Return a big struct full of all file data.
		return a;
	}


	/** INTERNAL UTILITIES **
 * --------------------------------------------------------------------- */

	/**
	 * check_deep_key 
 	 *
	 * Check in structs for elements
	 */
	public Boolean function check_deep_key (Struct Item, String list) {
		var thisMember=Item;
		var nextMember=Item;

		//Loop through each string in the argument list. 
		for ( var i=2; i <=	ArrayLen(Arguments); i++ ) {
			//Check if the struct is a struct and if it contains a matching key.
			if (!isStruct(thisMember) || !StructKeyExists(thisMember, Arguments[i])) return 0;
			thisMember = thisMember[Arguments[i]];	
		}
		return 1;
	}


	/**
	 * check_file
 	 *
	 * Check that a file exists?
	 */
	private Boolean function check_file ( Required String mapping, Required String file ) {
		var cm = getConstantMap();
		return ( FileExists( cm[ ToString("/" & mapping) ] & file & ".cfm") ) ? 1 : 0;
	}


	/** 
	 * getType
	 *
	 * ...
	 *
	 */
	public Struct function getType ( Required sCheck ) {
		//Get the type name
		var t = getMetadata( sCheck );
		var typename;

		//TODO: Sloppily relying on an exception being thrown is NOT the way to go about this.
		try {
			typename = LCase( t.getName() );
			if ( Find( "string", typename ) ) 
				return { status=true, type="string", value=sCheck }; 
			if ( Find( "number", typename ) || Find( "double", typename ) ) 
				return { status=true, type="numeric", value=sCheck }; 
			else if ( Find( "struct", typename ) ) 
				return { status=true, type="struct", value=sCheck }; 
			else if ( Find( "array", typename ) ) {
				return { status=true, type="array", value=sCheck }; 
			}
		}
		catch (any e) {
			//the non-basic types (query, closure, etc) are handled here
			typename = "unknown type";
			try {
				if ( StructKeyExists( t, "access" ) ) {
					typename = "closure";
					return { status=true, type="closure", value=sCheck }; 
				}
			}
			catch (any de) {
				//This should catch either truly unknown or badly wrapped types (like queries)
				return { status=false, type="unknown", value={} };
			}
		}

		//We should never get here...
		return { status=false,type="nil",value={} };
	}


	/**
	 * _include
	 *
	 * A wrapper around cfinclude to work with the framework's structure.
 	 */
	private function _include (Required String where, Required String name) {
		//Define some variables important to this function
		var match = false;
		var ref;
		logReport( "Running _include on path #where#/#name#" );

		//Search for a valid path within our framework	
		for ( var x in getArrayConstantMap() ) {
			if ( x == where ) { 
				match = true;
				break;
			}
		}

		//Return a status of false and a full message if the file was not found.
		if ( !match ) {
			return {
				status = false
			, message = "Requested inclusion of a file not in the web directory."
			, errors = {}
			, ref = ""
			};
		}

		//Set ref here, I'm not sure about scope.
		ref = ToString( where & getPathsep() & name & ".cfm" );
		
		//Include the page and make it work
		try {
			include ref; 
		}
		catch (any e) {
			//define the type of exception here and wrap that.  or just return it and
			//wrap it from the calling function
			//writeoutput( e.type );	
			//writedump( e );
			//abort;

			return {
				status = false
			 ,message = "#getCompName()# caught a '#e.type#' exception."
			 ,errors = e
			 ,ref = ref 
			}
		}

		return {
			status = true
		 ,message = "SUCCESS"
		 ,errors = {}
		 ,ref = ref 
		}
	}


	/** QUERY/DATABASE **
 * --------------------------------------------------------------------- */

	/**
	 * assimilate
	 *
	 * Add query content into model
	 */
	public Struct function assimilate ( Required Struct model, Required Query query ) {
		var _columnNames=ListToArray(query.columnList);
		if ( query.recordCount eq 1 ) {
			for ( var mi=1; mi lte ArrayLen(_columnNames); mi++ ) {
				StructInsert( model, LCase(_columnNames[mi]), query[_columnNames[mi]][1], "false" );
			}
		}
		return model;
	}


	/**
	 * isSetNull 
	 *
	 * Check if a result set is composed of all nulls
	 */
	public Boolean function isSetNull ( Required Query q ) {
		var columnNames = ListToArray( q.columnList );
		if ( q.recordCount gt 1 )
			return false;
		else if ( q.recordCount eq 1 ) { 
			//Check that the first (and only) row is not blank.
			for ( var ci=1; ci lte ArrayLen(columnNames); ci++ ) {
				if ( q[columnNames[ci]][1] neq "" ) {
					return false;	
				}
			}
		}
		return true;
	}


	/**
	 * get_column_names
	 *
	 * Retrieve the column names from a database query.
	 */
	public String function get_column_names ( Required String table, String dbname ) {
	/*
		fake_name = randStr( 5 );
		noop = "";

		//Save column names to a variable titled 'cn'
		dbinfo datasource=data.source	type="columns" name="cn" table=table;
		writedump( cn );	

		//This should be just one of the many ways to control column name output
		for ( name in cn )
			noop &= cn.column_name;

		return noop;
	*/
	}


	/**
	 * setQueryField 
	 *
	 * Add fields to a query very easily
	 */
	public function setQueryField (Required Query query, Required String columnName, Required Any fillValue, String columnType ) {
		var type = (!StructKeyExists(Arguments, "columnType")) ? "varchar" : Arguments.columnType;
		QueryAddColumn(query, columnName, type, ArrayNew(1));

		/*Add callback support in fillValue...*/
		for (i=1; i <= query.recordCount; i++) {
			QuerySetCell(query, columnName, fillValue, i);
		}
	}


	/**
	 * dynQuery
	 *
	 * Run a query using file path or text, returning the query via a variable
	 */	
	public Struct function dynquery ( 
		Optional queryPath,                     //Path to file containing SQL code
		Optional queryText,                     //Send a query via text
		Optional queryDatasource = data.source, //Define a datasource for the new query, default is #data.source#
		Optional debuggable = false,            //Output dumps
		Optional timeout = 100,                 //Stop trying if the query takes longer than this many milliseconds
		Optional timeoutInSeconds = 10,         //Stop trying if the query takes longer than this many seconds
		Optional params                         //Struct or collection of parameters to use when processing query
	 )
	{
		//TODO: This ought to be some kind of template...
		if ( debuggable ) {
			writedump( queryPath );
			writedump( queryDatasource );
		}

		//Define the new query
		var qd = new Query();
		qd.name = "__results";
		qd.result = "__object";
		qd.datasource = queryDatasource;	

		//...
		try {
			//Include file
			include queryPath; 
			//Then try a text query...
		}
		catch ( any e ) {
			//Save the contents of the error message and send that back
			savecontent variable="errMessage" {
				err = cfcatch.TagContext[ 1 ];
				logReport( 
					"SQL execution error at file " & 
					err.template & ", line " & err.Line & "." &
					cfcatch.message
				); 
			}

			return {
				status = 0,
				error  = errMessage,
				object = QueryNew( "nothing" ),
				results= QueryNew( "nothing" )
			};
		}
		
		return {
			status = 1,
			error  = "",
			object = __object,
			results= __results
		};
	}


	/**
 	 * execQuery
	 *
	 * Hash function for text strings.  Function returns a query.  NULL if nothing...
	 */
	public function execQuery (String qf, Boolean dump) {
		/*Check for the existence of the file we're asking for*/
		var template = qf & ".cfm";

		/*Debugging info*/
		//writeoutput("<br />" & template);
		//writeoutput("<br />" & expandPath(template));

		/*
		// Check that the file exists.
		if (!FileExists(expandPath(template))) {
			var a = QueryNew("File_does_not_exist");
			return a;
			// use struct and return it ...
		}
		*/

		/*A function can move through each of the Arguments and tell you what was passed*/
		if (dump == true) {
			for (x in Arguments) 
				writeoutput("<li>" & x & " => " & Arguments[x] & "</li>");
		}
		
		/*Run the query and cache any failures*/
		var sql = dynquery(template, Arguments);
		//Include template; writeDump(#__query#);writeDump(#__results#);

		/*Most of the errors have been handled.  You just need to let the user know it failed*/
		if (sql.status == False) { ; }
		if (dump == True)
			writedump(sql);
		
		return sql;
	}


	/**
 	 * dbExec 
	 *
	 * Execute queries cleanly and easily.
	 */
	public function dbExec ( String datasource="#data.source#", String filename, String string, bindArgs, Query query ) {
		//Set some basic things
		var Name = "query";
		var SQLContents = "";
		var cm = getConstantMap();
		var Period;
		var fp;
		var rr;
		var Base;
		var q;
		var resultSet;

		//Check for either string or filename
		var cFilename = StructKeyExists( arguments, "filename" );
		var cString = StructKeyExists( arguments, "string" );
		var cQuery = StructKeyExists( arguments, "query" );

		if ( !cFilename && !cString ) {
			return { 
				status= false, 
				message= "Either 'filename' or 'string' must be present as an argument to this function."
			};
		}

		//Make sure data source is a string
		if ( !cQuery ) {
			if ( !IsSimpleValue( arguments.datasource ) ) {
				return { status= false, message= "The datasource argument is not a string." };
			}

			if ( arguments.datasource eq "" ) {
				return { status= false, message= "The datasource argument is blank."};
			}
		}

		//Then check and process the SQL statement
		if ( StructKeyExists( arguments, "string" ) ) {
			if ( !IsSimpleValue( arguments.string ) ) {
				return { status= false, message= "The 'string' argument is neither a string or number." };
			}

			Name = "_anonymous";
			SQLContents = arguments.string;
		}
		else {
			//Make sure filename is a string (or something similar)
			if ( !IsSimpleValue( arguments.filename ) )
				return { status= false, message= "The 'filename' argument is neither a string or number." };

			//Get the file path.	
			fp = cm[ "/sql" ] & "/" & arguments.filename;
			//return { status= false, message= "#current# and #root_dir#" };

			//Check for the filename
			if ( !FileExists( fp ) )
				return { status= false, message= "File " & fp & " does not exist." };

			//Get the basename of the file
			Base = find( "/", arguments.filename );
			if ( Base ) {
				0;	
			}

			//Then get the name of the file sans extension
			Period = Find( ".", arguments.filename );
			Name = ( Period ) ? Left(arguments.filename, Period - 1 ) : "query";

			//Read the contents
			SQLContents = FileRead( fp );
/*
			//Finally, CFML code could be in there.  Evaluate it.
			try {
			SQLContents = Evaluate( SQLContents );
			}
			catch (any ee) {
				return { 
					status = false
				 ,message = "#ee#"
				 ,results = {}
				};
			}
			writedump( SQLContents ); abort;
*/
		}

		//Set up a new Query
		if ( !cQuery )
			q = new Query( name="#Name#", datasource="#arguments.datasource#" );	
		else {
			q = new Query( name="#Name#", dbtype = "query" );
			q.setAttributes( _mem_ = arguments.query );
		}

		//q.setName = "#Name#";

		//If binds exist, do the binding dance 
		if ( StructKeyExists( arguments, "bindArgs" ) ) {
			if ( !IsStruct( arguments.bindArgs ) ) {
				return { status= false, message= "Argument 'bindArgs' is not a struct." };
			}

			for ( var n in arguments.bindArgs ) {
				var value = arguments.bindArgs[n];
				var type = "varchar";

				if ( IsSimpleValue( value ) ) {
					try {__ = value + 1; type = "integer";}
					catch (any e) { type="varchar";}
				}
				else if ( IsStruct( value ) ) {
					v = value;
					if ( !StructKeyExists( v, "type" ) || !IsSimpleValue( v["type"] ) )
						return { status = false, message = "Key 'type' does not exist in 'bindArgs' struct key '#n#'" };	
					if ( !StructKeyExists( v, "value" ) || !IsSimpleValue( v["value"] ) ) 
						return { status = false, message = "Key 'value' does not exist in 'bindArgs' struct key '#n#'" };	
					type  = v.type;
					value = v.value;
				}
				else {
					return { 
						status = false, 
						message = "Each key-value pair in bindArgs must be composed of structs."
					};
				}
				q.addParam( name=LCase(n), value=value, cfsqltype=type );
			}
		}

		//Execute the query
		try { 
			rr = q.execute( sql = SQLContents ); 
		}
		catch (any e) {
			return { 
				status  = false,
			  message = "Query failed. #e.message# - #e.detail#."
			};
		}

		//Put results somewhere.
		resultSet = rr.getResult();

		//Return a status
		return {
			status  = true
		 ,message = "SUCCESS"
		 ,results = ( !IsDefined("resultSet") ) ? {} : resultSet
		 ,prefix  = rr.getPrefix()
		};
	}


	/** UTILITIES **
 * --------------------------------------------------------------------- */
	/**
	 * randstr( n )
	 *
	 * Generates random letters.
	 */
	public String function randstr ( Numeric n ) {
		// make an array instead, and join it...
		var str="abcdefghijklmnoqrstuvwxyzABCDEFGHIJKLMNOQRSTUVWXYZ0123456789";
		var tr="";
		for ( var x=1; x<n+1; x++) tr = tr & Mid(str, RandRange(1, len(str) - 1), 1);
		return tr;
	}


	/**
	 * randnum( n )
	 *
	 * Generates random numbers.
	 */
	public String function randnum ( Numeric n ) {
		// make an array instead, and join it...
		var str="0123456789";
		var tr="";
		for ( var x=1; x<n+1; x++ ) tr = tr & Mid(str, RandRange(1, len(str) - 1), 1);
		return tr;
	}

	//Return pretty JSON with the correct casing from one place...
	public String function queryToJSON ( Required Query arg ) {
		var ar = ArrayNew(1);
		for ( var v in arg ) ArrayAppend( ar, v );
		return SerializeJSON( ar );
	}

	//Return pretty JSON with the correct casing from one place...
	//NOTE: This is for one row
	public String function structToJSON ( Required Struct arg ) {
		function lowerStruct( Struct t ) {
			var nnStruct = {};
			for ( var v in t ) {
				if ( getType( t[ v ] ).type eq "struct" )
					nnStruct[ LCase(v) ] = lowerStruct( t[ v ] );
				else {
					nnStruct[ LCase(v) ] = t[ v ];
				}
			}
			return nnStruct;
		}

		var nStruct = {};
		for ( var v in arg ) {
			if ( getType( arg[ v ] ).type eq "struct" )
				nStruct[ LCase(v) ] = lowerStruct( arg[ v ] );
			else {
				nStruct[ LCase(v) ] = arg[ v ];	
			}
		}
		//writedump( nStruct );	writeoutput( SerializeJSON( nStruct ) ); abort;
		return SerializeJSON( nStruct );
	}

	/*
	public String function TESTstructToJSON ( Struct arg ) {
		//Single-level
		var x = { butter = "is tasty", guns = "are not" };	
		writedump( getMyst().structToJSON( x ) ); abort;

		//Try w/ bi-level struct	
		var y = { butter = "is tasty", guns = "are not", icon = { bop = "wop" } };	
		writedump( getMyst().structToJSON( y ) ); abort;

		//Try w/ 3+-level struct	
		var z = { 
			butter = "is tasty"
		, guns = "are not" 
		, icons = {
				instagram = "are not" 
			,	facebook = "are not" 
			,	array = [ "asdf", "back", 0, 1 ]
			,	struct = {
					first_name = "John"
				,	last_name = "Salley"
				} 
			}
		};	
		writedump( getMyst().structToJSON( z ) ); abort;
	}
	*/

	public String function queryToXML ( Query arg ) {

	}

	public String function structToXML ( Struct arg ) {

	}

	/** RESPONSE **
 * --------------------------------------------------------------------- */
	//This one includes pages in paths
	private function pageHandler ( Required content, Required String pgPath , String rtHref, Required Numeric status ) {
		/*
		var r = getPageContext().getResponse();
		var w = r.getWriter();
		r.setContentType( "text/html" );
		w.print( arguments.content );
		r.flush();
		*/
	}


	/**
	 * sendResponse
	 *
	 * Send...
	 */
	private function sendResponse ( Required status, Required mime, Required content, Struct headers, Boolean abort ) {
		var r = getPageContext().getResponse();
		var w = r.getWriter();
		//TODO: Why is this not setting the status message...
		//w.flush(); //this is a function... thing needs to shut de fuk up
		r.setStatus( arguments.status, getHttpHeaders()[ arguments.status ] );
		r.setContentType( arguments.mime );
		w.print( arguments.content );
		if ( !StructKeyExists( arguments, "abort" ) || arguments.abort eq true ) {
		 abort;
		}
	}


	/**
	 * contentHandler 
	 *
	 * Send a 200 along with whatever was asked for.
	 */
	private function contentHandler ( Required String mime, Required content ) {
		sendResponse( status=200, mime=arguments.mime, content=arguments.content );
	} 
	
	
	/**
	 * renderPage
	 *
	 * Generates a page to send to stdout
	 */
	private function renderPage( Required Numeric status, Required content, Struct err, Boolean abort ) {
		var errStruct = {};
		var a = arguments;
		var b = false;
		var h = getHttpHeaders();
		var t = getType( arguments.content ).type;
		var tt = getSelectedContentType();
	
		//TODO: Why is this here?
		if ( ( !arguments.status || arguments.status == 200 ) && t eq "string" )
			sendResponse( 200, tt, arguments.content );
		else if ( arguments.status eq 200 && t eq "struct" ) {
			//...
			if ( StructKeyExists( arguments.content, "type" )) {  
				if ( arguments.content.type eq "struct" && tt eq "application/json" )
					sendResponse( arguments.status, tt, structToJSON( arguments.content.value ) ); 
				else if ( arguments.content.type eq "query" && tt eq "application/json" )
					sendResponse( arguments.status, tt, queryToJSON( arguments.content.value ) ); 
				else {
					sendResponse( arguments.status, tt, structToJSON( { message = "Invalid return type requested." } ) ); 
				} 	
			}
			else if ( /*arguments.content.type eq "struct" &&*/ tt eq "application/json" )
				sendResponse( arguments.status, tt, structToJSON( arguments.content ) ); 
			else {
				var e = { message = "application/json is the only other format supported." };
				sendResponse( 500, tt, structToJSON( e ) ); 
			}
		}  
		else if ( arguments.status eq 200 && t eq "query" ) {
			if ( /*arguments.content.type eq "struct" &&*/ tt eq "application/json" )
				sendResponse( arguments.status, tt, queryoToJSON( arguments.content ) ); 
			else {
				var e = { message = "application/json is the only other format supported." };
				sendResponse( 500, tt, structToJSON( e ) ); 
			}
		}  

		//If an error struct is given and it has something in it, do...
		if ( !StructKeyExists( arguments, "err" ) || StructIsEmpty( arguments.err ) ) {
			setPageStatus( arguments.status );
			setPageStatusMessage( getHttpHeaders()[arguments.status] );
			if ( getPageStatus() eq 401 )
				setPageMessage( "The client asked for access to a page it does not have access to." );
			else if ( getPageStatus() eq 404 )
				setPageMessage( "The client made a request for " &
					"<u>#cgi.script_name# and it was not found on this server." );
			else {
				setPageMessage( "Unspecified error occurred." );
			}
			for ( var k in getPageErrorExtractors() ) {
				err[ k ] = "";
			}
		}
		else {
			//What if it's a 200?
			setPageError( arguments.err );
			if ( arguments.status > 499 ) {
				setPageStatus( arguments.status );
				setPageStatusMessage( getHttpHeaders()[arguments.status] );
				//Handle errors of different exception types
				if ( !StructKeyExists( arguments.err, "type" ) )
					setPageMessage( "An undefined error has occurred." );
				else if ( err.type eq "Application" )
					setPageMessage( "An '#err.type#' error has occurred." );
				else if ( err.type eq "Database" )
					setPageMessage( "An '#err.type#' error has occurred." );
				else if ( err.type eq "Template" )
					setPageMessage( "An '#err.type#' error has occurred." );
				else if ( err.type eq "Object" )
					setPageMessage( "An '#err.type#' error has occurred." );
				else if ( err.type eq "Expression" )
					setPageMessage( "An '#err.type#' error has occurred." );
				else if ( err.type eq "Security" )
					setPageMessage( "An '#err.type#' error has occurred." );
				else if ( err.type eq "Lock" )
					setPageMessage( "An '#err.type#' error has occurred." );
				else if ( err.type eq "Any" )
					setPageMessage( "An '#err.type#' error has occurred." );
				else if ( err.type eq "MissingInclude" ) {
					setPageMessage( "An '#err.type#' error has occurred. " &
					"#err.MissingFileName# was not found in the application structure" );
				}
				else {
					setPageMessage( "A '#err.type#' error has occurred." );
				}
			} 
		}

		//...
		var c = getSelectedContentType();
		if ( c == "application/json" || c == "json" ) {
			var e = {};
			for ( var k in getPageErrorExtractors() ) e[ k ] = err[ k ];
			sendResponse( arguments.status, getSelectedContentType(), structToJSON( e ) ); 
		}
		else if ( c == "text/plain" ) {
			abort;
		}
		else if ( c == "text/xml" || c == "xml" ) {
			sendResponse( 500, getSelectedContentType(), "Myst does not support text/xml mimetype returns yet." );
			abort;
		}
		else if ( c == "text/html" ) {
			var f = ( arguments.status > 399 && arguments.status < 500 ) ? 4 : 5;
			//_include the chosen view page
			var a; 
			savecontent variable="content" {
				a = _include( where="std", name="#f#xx-view" );
			}

			if ( !a.status ) {
				setPageMessage( a.message );
				sendResponse( 500, getSelectedContentType(), a.message );
			}

			sendResponse( arguments.status, getSelectedContentType(), content );
		}
		else {
			//You might need a default handler or a custom handler for certain types... 
		}

		//If err is present and not empty, then this is an error and is streamed and handled by me
		//Jump and die
		if ( StructKeyExists( arguments, "abort" ) && arguments.abort eq true )
			abort;
		else {
			return { status = true, message = "SUCCESS" }
		}
	}


	/**
	 * sendAsJson (t)
	 *
	 * Send a struct back wrapped as a JSON object.
	 */
	public string function sendAsJson ( ) {
		var a = structToJSON( arguments );
		if ( !getApiAutodie() )
			writeoutput( a );
		else {
			pc = getpagecontext().getResponse();
			pc.setContentType( "application/json" );
			writeoutput( a );
			abort;
		}
		return a;
	}

	/**
	 * sendAsJson (t)
	 *
	 * Send a query back wrapped as a JSON object.
	 */
	public string function sendQueryAsJson ( Query q ) {
		var a = queryToJSON( q );
		if ( !getApiAutodie() )
			writeoutput( a );
		else {
			pc = getpagecontext().getResponse();
			pc.setContentType( "application/json" );
			writeoutput( a );
			abort;
		}
		return a;
	}


	private function evalBefore( Required Struct r ) {

	}

	private function evalAfter( Required Struct r ) {

	}

	//Intended to be called inside cfm files....
	//kind of a quick and dirty way to do typeless models... 
	public function setScope ( Required String name, Required value, String type ) {
		if ( StructKeyExists( arguments, "type" ) )
			variables.pageScope[ name ] = { type = type, value = value };
		else {
			//Infer the type if possible... Query does not work so...
			var t = getType( value ).type;
			variables.pageScope[ name ] = { type = t, value = value };
		}
	}

	private function evalHook( Required rd, Struct scope ) {
		var t = getType( rd );
		if ( t.type eq "closure" )
			rd( scope );	
		else if ( t.type eq "struct" ) {
			//Could evaluate model and view here as default
			if ( StructKeyExists( rd, "model" ) ) {
				evalModel( rd );
			}
			if ( StructKeyExists( rd, "view" ) ) {
				evalView( rd );
			}
		} 
		else {
			//Throw an error because right now, no other types are supported.
		}
	}

	//This can fail out if the type does not match... maybe...
	public function getScope ( Required String name, String type ) {
		if ( StructKeyExists( variables.pageScope, name ) ) {
			return variables.pageScope[ name ][ "value" ];
		}
		else if ( name eq "*" ) {
			return variables.pageScope;
		}
		//The type will probably be stored, so a default value can be used
		return null;  //This should return some kind of type
	}

	//
	private function evalModel( Required Struct rd ) {
		//Evaluate model 
		try {
			//Get the original scope before running anything
			//var oScope = ListSort( StructKeyList( variables ), "textNoCase" );

			//Log what's happening	
			logReport( "Evaluating models @ /#data.page#..." );
//renderPage( 401, "Some content." ); abort;
			//Model
			if ( StructKeyExists( rd, "model" ) ) {
				//Check the type's value 
				var ev = getType( rd.model );
				var pgArray = [];
			
				//...
				if ( ev.type != 'array' && ev.type != 'struct' ) 
					ArrayAppend(pgArray, {type=ev.type,value=ev.value});
				else if ( ev.type == 'struct' ) {
					//check for 'exec' and just save that string, only exec is allowed right now
					if ( StructKeyExists( ev.value, "exec" ) ) 
						ArrayAppend(pgArray, {type="execution",value=ev.value.exec});
					else {
						renderPage( 
							status=500
						, err={}
						, content="Model struct does not contain 'exec' key (check key at #rd.file#)"
						);
					}
				}
				else {
					for ( var ind=1; ind<=ArrayLen(ev.value); ind++ ) {
						var ee = ev.value[ ind ]; 
						var ey = getType( ee );	
						if ( ey.type == "string" || ey.type == "closure" )
							ArrayAppend(pgArray, {type=ey.type,value=ey.value});
						else if ( ey.type == "struct" ) {
							if ( StructKeyExists( ey.value, "exec" ) )
								ArrayAppend(pgArray, {type="execution",value=ey.value.exec});
							else {
								renderPage( 
									status=500
								, err={}
								, content="Model struct does not contain 'exec' key (check key at #rd.file#)"
								);
							}
						}
						else {
							renderPage( 
								status=500
							, content="Error loading model reference at #ind# at key '#rd.file#'"
							, err={}
							);
						}
					}
				}

				//Now load each model, should probably put these in a scope
				for ( var page in pgArray ) {
					var callStat;
					if ( page.type == "string" ) {
						callStat = _include( where="app", name=page.value );
						if ( !callStat.status ) {
							renderPage( 
								status=500
							, content="Error executing model file '#page.value#'"
							, err=callStat.errors 
							);
						}
					}
					else if ( page.type == "execution" ) {
						//there is nothing really to do here...
					}
					else {
						try {
							page.value( /*Passing something in makes things easy*/ );
						}
						catch (any e) {
							renderPage( 
								status=500
							, content="Error executing model closure at #rd.file#"
							, err=e
							);
						}
					}
				}
			}
		}
		catch (any e) {
			//Manually wrap the error template here.
			renderPage(status=500, err=e, content="Error executing models at: '#rd.file#'" );
		}
	}



	/**
	 * private String function evalView ( Required struct rd )
	 *
	 * Evaluates a view.
	 */
	private String function evalView( Required Struct rd ) {
		//Evaluate view
		try {
			logReport( "Evaluating views..." );
			if ( !StructKeyExists( rd, "view" ) ) {
				renderPage( 
					status=500
				, content="View was requested, but there are no views specified for the endpoint at '#rd.file#'"
				, err={ 
						type="framework",
						message= "View was requested, but there are no views specified for the endpoint at '#rd.file#'"
					}
				);
			}

			var the_page_content;
			savecontent variable="the_page_content" {
				//Get the type name
				var ev = getType( rd.view );
				//Custom message is needed here somewhere...
				if ( ev.type != "string" && ev.type != "array" ) {
					renderPage( 
						status=500
					, err={} 
					, content="View value for '#rd.file#' was not a string or array."
					);
				}

				//Set pageArray if it's string or array
				var pageArray = (ev.type == 'string') ? [ ev.value ] : ev.value;

				//Now load each model, should probably put these in a scope
				for ( var x in pageArray ) {
					var callStat = _include( where="views", name=x );
					if ( !callStat.status ) {
						renderPage( 
							status=500
						, err=callStat.errors 
						, content="Error loading view at page '#x#'."
						);
					}
				}
			}
		} 
		catch (any e) {
			//Manually wrap the error template here.
			renderPage( status=500, err=e, content="Error in parsing view." );
		}

		return the_page_content;
	}

	/**
	 * makeIndex( Myst mystInstance )
	 *
	 * Generate a page through the page generation cycle.
	 */
	public function makeIndex (Myst MystInstance) {
		//Define some local things
		//var oScope;
		//var nScope;
		//var resName;

		//TODO: Change these from global scope when full object conversion happens.
		variables.coldmvc = MystInstance;
		variables.myst = MystInstance;
		variables.data = MystInstance.app;
		//variables.db = MystInstance.app.data;

		//Load all the components should have been loaded...
		try {
			//Go through all the components in the components directory
			logReport( "Loading components..." );
			var dir = "components";
			var dirQuery = DirectoryList( "components", false, "query", "*.cfc" );

			//Choose a datasource for each of our modules to use here.
			var dds = "";
			if ( StructKeyExists( data, "source" ) )
				dds = data.source;
			else if ( StructKeyExists( application, "datasource" ) )
				dds = application.datasource;
			else if ( StructKeyExists( application, "defaultdatasource" ) ) {
				dds = application.defaultdatasource;
			}

			//Initialize each component with common properties
			for ( var q in dirQuery ) {
				logReport( "Loading component '#q.name#'..." );
				if ( q.name neq "Application.cfc" && q.name neq "base.cfc" ) {
					var vv = Replace( q.name, ".cfc", "" );
					var m = MystInstance;
					var cname = Replace( q.name, ".cfc", "" );
					var cmp 
					= variables[ vv ]
					= g[cname] 
					= createObject( "component", "components.#vv#" ).init(
							mystObject = m 
						, realname = cname
						, namespace = cname
						, datasource = dds
						, debuggable = 0
						, verbose = 0
					);
				}
				logReport("SUCCESS!");
			}
			logReport("SUCCESS - All components loaded!");
		}
		catch (any e) {
			renderPage( status=500, content="Component load failed.", err=e );
		}
		
		//Route injection should happen here.
		try {
			//Add more to logging
			logReport("Evaluating routes...");
			var dirQuery = DirectoryList( "routes", false, "query", "*.cfm" );
			var callstat = 0;
			for ( var q in dirQuery ) {
				var n = Replace( q.name, ".cfm", "" );
				callstat = _include( where = "routes", name = n );
				if ( !callstat.status ) {
					renderPage( 
						status=500
					, err=callstat.errors
					, content="Syntax error at routes/#n#"
					);
				}
			}
			logReport("SUCCESS - All routes loaded!");
		}
		catch (any e) {
			renderPage( status=500, content="Route injection failed.", err=e );
		}

		//Build "full" routing table by adding inherited keys and whatnot...
		try {
			logReport("Re-building routing table...");
			function passLevelDown( Required Struct arg, Struct found ) {
				//If found is not blank, loop through each of those and add them...
				if ( !StructIsEmpty( found ) ) {
					for ( var f in found ) arg[ f ] = found[ f ];
				}

				//Check the struct for any keys, apply them to whatever struct
				var nStruct = {};
				for ( var k in ListToArray( getRoutingKeys() ) ) {
					if ( StructKeyExists( arg, k ) ) nStruct[ k ] = arg[ k ];
				}

				//Finally, loop through...gin.cfm
				for ( var vv in arg ) {
					if ( ArrayContains( ListToArray( getRoutingKeys() ), vv ) ) {
						continue;
						//writeoutput( "Skip key '#vv#' at ...<br />"  );
					}

					if ( getType( arg[ vv ] ).type eq 'struct' ) {
						passLevelDown( arg[ vv ], nStruct );
					}
				}
			}

			//Use recursion and find each key in each part
			passLevelDown( appdata.routes, {} );
			logReport("SUCCESS!");
		}
		catch (any e) {
			renderPage( status=500, content="Error rebuilding route index.", err=e );
		}

		//Find the right resource.
		try {
			//Add more to logging
			logReport( "Evaluating URL route..." );

			//TODO: All aliasing needs to be handled here.	
			var ses_path = (check_deep_key( appdata, "settings", "ses" )) 
				? cgi.path_info : cgi.script_name;

			//Set some short names in case we need to access the page name for routing purposes
			var rd = findResource( name=cgi.script_name, rl=appdata );
			setRname( rd.file /*resourceIndex( name=cgi.script_name, rl=appdata )*/ );
			variables.data.loaded = variables.data.page = resName = getRname();

			//Send a 404 page and be done if this resource was not specified in data.cfm
			if ( rd.status eq 404 ) {
				renderPage( status=404, content="Resource not found.", err={} ); 
			}
			logReport( "SUCCESS!" );
		}
		catch (any e) {
			renderPage( status=500, content="Locating resource mapping failed.", err=e );
		}

		//With this new system in place, some things have higher precedence...
		//'before' is always first
		//'accepts', 'expects', and possibly 'scope' really should be run...
		//'query' should come before model (if implemented)
		//'model' ought to be next
		//'returns' does little good right now..., models can be done..., I suppose
		//'view(s)' next
		//'after' should always be final 

		//The scope should carry things over...
		var scope = {};  
		if ( StructKeyExists( rd, "scope" ) ) {
			logReport( "Evaluating key 'scope' @ /#data.page#..." );
			scope = rd.scope;	
			logReport( "SUCCESS!" );
		}

		if ( StructKeyExists( rd, "returns" ) ) {
			logReport( "Evaluating key 'returns' @ /#data.page#..." );
			//Check if it's supported
			if ( getType( rd.returns ).type neq "string" ) {
				renderPage( 500, "Value at key 'returns' in struct associated with '#data.page#' is not a string." );
			}	
			if ( !StructKeyExists( getMimeToFileMap(), rd.returns ) ) {
				renderPage( 500, "Unsupported return type '#rd.returns#' was selected." );
			}
			setSelectedContentType( rd.returns );	
			logReport( "SUCCESS!" );
		}

		//Run something before every request to this endpoint
		if ( StructKeyExists( rd, "before" ) ) {
			logReport( "Evaluating key 'returns' @ /#data.page#..." );
			evalHook( rd.before, scope );
			//Get the type of rd.before
			logReport( "SUCCESS!" );
		}

		//Checks the actual method
		if ( StructKeyExists( rd, "accepts" ) ) {
			logReport( "Evaluating key 'accepts' @ /#data.page#..." );
			//If the method is NOT a member of rd.accepts, die...
			if ( ArrayFind( ListToArray( rd.accepts ), cgi.request_method ) == 0 ) {
				renderPage( status=405, content="This endpoint does not accept method '#cgi.request_method#'" ); 
			}
			logReport( "SUCCESS!" );
		}

		//Checks the values within a particular scope 
		if ( StructKeyExists( rd, "expects" ) ) {
			logReport( "Evaluating key 'expects' @ /#data.page#..." );
			var allowed = ( StructKeyExists( rd, "accepts" ) ) ? rd.accepts : ListToArray("GET,POST");
			rd.expects = ListToArray( rd.expects );
			//Build a list of scopes from the above (if thrown)
			//Otherwise, we ought to assume that the variables could be anywhere 
			var s = { GET=url, POST=form };
			var kFind = {};
			for ( var k in rd.expects ) {
				kFind[ k ] = { found = false };
				for ( var methodStruct in s ) {
					if ( StructKeyExists( s[methodStruct], k ) ) {
						//Add the found key here.  We can eventually take it a step further and add validation
						kFind[ k ] = { found = true, value = s[methodStruct][k] };
					}	
				}
			}
			//If kFind has anything false, we die here
			for ( var f in kFind ) {
				if ( !kFind[ f ].found ) {
					writeoutput( "<h2>This endpoint expected variables it did not receive.</h2>" );
					abort;
					renderPage( status=412, content="This endpoint expected variables it did not receive." );
				}
			}
			logReport( "SUCCESS!" );
		}

		//Query SHOULD be higher precedence than model
		if ( StructKeyExists( rd, "query" ) ) {
			logReport( "Evaluating key 'query' @ /#data.page#..." );
			//rd.query = "";
			logReport( "SUCCESS!" );
			//Queries ARE supposed to be automatically brought back as things...
		}

		//This is where rethinking things could help, scope should be another argument.
		if ( StructKeyExists( rd, "model" ) ) {
			//The status should return here, and errors handled
			evalModel( rd );	
		}

		//Filter out the scope when returning JSON
		if ( StructKeyExists( rd, "filter" ) ) {
			//Get the right variable from the scope and stop
			//Break the line at '.' and run a loop for each time	
			//Filter is expected to be used with JSON and XML (other interchange is fine too, but needs help)
			//Keep going through the scope until the element is found...
			//Hard to say whether or not it should be an exception...
			rd.filter = ListToArray( rd.filter, "." );
			for ( var n in rd.filter ) {
				if ( StructKeyExists( variables.pageScope, n ) ) {
					variables.pageScope = variables.pageScope[ n ];
				}
			}
		}

		//Run a view
		var the_page_content;
		if ( StructKeyExists( rd, "view" ) ) {
			//Check the type and serialize...
			logReport( "Evaluating views @ /#data.page#..." );
			the_page_content = evalView( rd );
		}
		else {
			//getScope and search for type of what was wanted
			the_page_content = getScope( "*" );
		}

		if ( StructKeyExists( rd, "after" ) ) {
			logReport( "Evaluating key 'after' @ /#data.page#..." );
			evalHook( rd.after );
			//writedump( t );
			logReport( "SUCCESS!" );
		}

//writedump( the_page_content );writedump( getScope("model") );abort;
		var rp = renderPage( status=200, content=the_page_content );
		if ( rp.status )
			return 1;
		else {
			return 0;
		}
	}


	/*
	private struct function findResource ( Required String name, Required Struct rl ) {

	why not return with some smart things from here?
	404 is if something can't be found

	- combine the path as you go down, b/c you need to check for files later on, 

	status = 200, 404, etc
	path = path as we go through the thing
	*/
	private struct function findResource ( Required String name, Required Struct rl ) {
		//Define a base here
		var base = "default";
		var localName;
		var tt;

		//Handle situations where no routes are defined.
		if ( !structKeyExists( rl, "routes" ) || StructIsEmpty( rl.routes ) ) {
			//return base;
			return { model="default", view="default", file="", path="", status=200 }
		}

		//Modify model and view include paths if there is a basedir present.
		if ( StructKeyExists( rl, "base" ) ) {
			if ( Len( rl.base ) > 1 )
				base = rl.base;	
			else if ( Len(rl.base) == 1 && rl.base == "/" )
				base = "/";
			else {
				base = rl.base;	
			}
		}

		//Simply lop the basedir off of the requested URL if that was requested
		if ( StructKeyExists(rl, "base") ) {
			localName = Replace( arguments.name, base, "" );
		}

		/*
		//Check for resources in GET or the CGI.stringpath 
		if ( StructKeyExists(rl, "handler") && CompareNoCase(rl.handler, "get") == 0 ) {
			if ( isDefined("url") and isDefined("url.action") )
				name = url.action;
			else {
				if (StructKeyExists(rl, "base")) {
					name = Replace(name, base, "");
				}
			}
		}
		else {
			//Cut out only routes that are relevant to the current application.
			if ( StructKeyExists(rl, "base") ) {
				name = Replace( name, base, "" );
			}
		}
		*/

		//Handle the default route if rl is not based off of URL
		if ( !StructKeyExists( rl, "handler" ) && localName == "index.cfm" ) {
			//return rl.routes.default;
			var tt = rl.routes.default;
			tt.file = "index.cfm";
			tt.path = "/";	
			tt.status = 200;
			return tt;
		}

		/*
		writeoutput("at route evaluator:" );
		writedump( "localName: #localName#" );
		writedump( ListToArray( localName, "/" ) );
		//writedump( rl.routes );
		*/

		//This is the second version, die out and return
		//Chopping from the top, until we stop, is the best thing...
		var t = rl.routes;
		var et = {};
		var path = "";
		var file;
		var l = ListToArray( localName, "/" );

		//to make this easy, something EXPLICIT needs to catch
		for ( var x in l ) {
			var fn = Replace( x, ".cfm", "" );
			if ( StructKeyExists( t, x ) ) {
				t = t[ x ];
				path = ListAppend( path, x, "/" );
				file = x;
			}
			else if ( StructKeyExists( t, fn ) ) {
				t = t[ fn ];
				path = ListAppend( path, fn, "/" );
				file = fn;
			}
			/*
			'*' wildcard catch	
			regex catch
			*/
			else {
				//writeoutput("<h2>we died</h2>" );
				return { 
					status=404
				, path=path
				, file=x
				};
			}
		}

		var diff = 	Len(path) - Len(file);
		t.file = file;
		t.path = ( diff ) ? Left( path, diff ) : path; 
		t.status = 200;
		return t;	
	}


	/**
	 * resourceIndex 
	 *
	 * Find the index of a resource if it exists.  Return 0 if it does not.
	 */
	private String function resourceIndex ( Required String name, Required Struct rl ) {
		//Define a base here
		var base = "default";
		var localName;

		//Handle situations where no routes are defined.
		if ( !structKeyExists( rl, "routes" ) || StructIsEmpty( rl.routes ) )
			return base;

		//Modify model and view include paths if there is a basedir present.
		if ( StructKeyExists( rl, "base" ) ) {
			if ( Len( rl.base ) > 1 )
				base = rl.base;	
			else if ( Len(rl.base) == 1 && rl.base == "/" )
				base = "/";
			else {
				base = rl.base;	
			}
		}

		//Simply lop the basedir off of the requested URL if that was requested
		if ( StructKeyExists(rl, "base") ) {
			localName = Replace( arguments.name, base, "" );
		}

		/*
		//Check for resources in GET or the CGI.stringpath 
		if ( StructKeyExists(rl, "handler") && CompareNoCase(rl.handler, "get") == 0 ) {
			if ( isDefined("url") and isDefined("url.action") )
				name = url.action;
			else {
				if (StructKeyExists(rl, "base")) {
					name = Replace(name, base, "");
				}
			}
		}
		else {
			//Cut out only routes that are relevant to the current application.
			if ( StructKeyExists(rl, "base") ) {
				name = Replace( name, base, "" );
			}
		}
		*/

		//Handle the default route if rl is not based off of URL
		if ( !StructKeyExists( rl, "handler" ) && localName == "index.cfm" ) {
			return "default";
		}

		/*
		writeoutput("at route evaluator:" );
		writedump( "localName: #localName#" );
		writedump( ListToArray( localName, "/" ) );
		writedump( rl.routes );
		*/

		//This is the first version
		//If you made it this far, search for the requested endpoint
		for ( var x in rl.routes ) {
			if ( localName == x || Replace(localName, ".cfm", "" ) == x ) {
				return x;
			}
		}
	
		//You probably found nothing, so either do 404 or some other stuff.
		return ToString(0);
	}



	//Return formatted error strings
	//TODO: More clearly specified that this function takes variables arguments
	private Struct function strerror ( code ) {
		var argArr = [];
		var errors = {
			 errKeyNotFound = "Required key '%s' does not exist."
			,errValueLessThan = "Value of key '%s' fails -lt (less than) test."
			,errValueGtrThan = "Value of key '%s' fails -gt (greater than) test."
			,errValueLtEqual= "Value of key '%s' fails -lt (less than or equal to) test."
			,errValueGtEqual = "Value of key '%s' fails -gte (greater than or equal to) test."
			,errValueEqual = "Value of key '%s' fails -eq (equal to) test."
			,errValueNotEqual = "Value of key '%s' fails -neq (not equal to) test."
			,errFileExtMismatch = "The extension of the submitted file '%s' does notmatch the expected mimetype for this field."
			,errFileSizeTooLarge = "Size of field '%s' (%d bytes) is larger than expected size %d bytes."
			,errFileSizeTooSmall = "Size of field '%s' (%d bytes) is smaller than expected size %d bytes."
		};

		for ( arg in arguments ) {
			if ( arg != 'code' ) {
				//Do an explicit cast here if need be... 
				//(get type...)
				//ArrayAppend( argArr, javacast( arguments[arg], type ) );
				ArrayAppend( argArr, arguments[arg] );
			}
		}
	
		str = createObject("java","java.lang.String").format( errors[code], argArr );

		return {
			status = false,
			message = str 
		};
	}	


	//A quick set of tests...
	public function validateTests( ) {
		// These should all throw an exception and stop
		// req
		// req + lt	
		// req + gt	
		// req + lte
		// req + gte
		// req + eq	
		// req + neq 
		
		// These should simply discard the value from the set
		// An error string can be set to log what happened.
		// lt	
		// gt	
		// lte
		// gte
		// eq	
		// neq 

	}

	//Check a struct for certain values by comparison against another struct
	public function cmValidate ( cStruct, vStruct ) {
		var s = { status=true, message="", results=StructNew() };

		//Loop through each value in v
		for ( key in vStruct ) {
			//Short names
			vk = vStruct[ key ];

			//If key is required, and not there, stop
			if ( structKeyExists( vk, "req" ) ) {
				if ( (!structKeyExists( cStruct, key )) && (vk[ "req" ] eq true) ) {
					return strerror( 'errKeyNotFound', key );
				}
			}

			//No use moving forward if the key does not exist...
			if ( !structKeyExists( cStruct, key ) ) {
				//Use the 'none' key to set defaults on values that aren't required
				if ( StructKeyExists( vk, "ifNone" ) ) {
					s.results[ key ] = vk[ "ifNone" ];	
				} 
				continue;
			}
 
			//Set this key
			ck = cStruct[ key ];

			//Less than	
			if ( structKeyExists( vk, "lt" ) ) {
				//Check types
				if ( !( ck lt vk["lt"] ) ) {
					return strerror( 'errValueLessThan', key );
				}	
			} 

			//Greater than	
			if ( structKeyExists( vk, "gt" ) ) {
				if ( !( ck gt vk["gt"] ) ) {
					return strerror( 'errValueGtrThan', key );
				}	
			}

			//Less than or equal 
			if ( structKeyExists( vk, "lte" ) ) {
				if ( !( ck lte vk["lte"] ) ) {
					// return { status = false, message = "what failed and where at?" }
					return strerror( 'errValueLtEqual', key );
				}	
			} 

			//Greater than or equal
			if ( structKeyExists( vk, "gte" ) ) {
				if ( !( ck gte vk["gte"] ) ) {
					return strerror( 'errValueGtEqual', key );
				}	
			}
	 
			//Equal
			if ( structKeyExists( vk, "eq" ) ) {
				if ( !( ck eq vk["eq"] ) ) {
					return strerror( 'errValueEqual', key );
				}	
			}
	 
			//Not equal
			if ( structKeyExists( vk, "neq" ) ) {
				if ( !( ck neq vk["neq"] ) ) {
					return strerror( 'errValueNotEqual', key );
				}	
			} 

			//This is the lazy way to do this...
			s.results[ key ] = ck;

			//Check file fields
			if ( structKeyExists( vk, "file" ) ) {
				//For ease, I've added some "meta" types (image, audio, video, document)
				meta_mime  = {
					image    = "image/jpg,image/jpeg,image/pjpeg,image/png,image/bmp,image/gif",
					audio    = "audio/mp3,audio/wav,audio/ogg",
					video    = "",
					document = "application/pdf,application/word,application/docx"
				};

				meta_ext   = {
					image    = "jpg,jpeg,png,gif,bmp",
					audio    = "mp3,wav,ogg",
					video    = "webm,flv,mp4,",
					document = "pdf,doc,docx"
				};	

				acceptedMimes = 0;
				acceptedExt = 0;

				//Most exclusive, just support certain mime types
				//(Array math could allow one to build an extension filter)
				if ( structKeyExists( vk, "mimes" ) )
					acceptedMimes = vk.mimes;
				//No mimes, ext or type were specified, so fallback
				else if ( !structKeyExists( vk, "type" ) )
					acceptedMimes = "*";
				else if ( structKeyExists( vk, "ext" ) ) {
					acceptedMimes = "*";
					acceptedExt = vk.ext;
				}	
				//Assume that type was specified
				else {
					acceptedMimes = structKeyExists( meta_mime, vk.type ) ? meta_mime[ vk.type ] : "*";
					acceptedExt = structKeyExists( meta_ext, vk.type ) ? meta_ext[ vk.type ] : 0;
				}
			
				//Upload the file
				file = upload_file( ck, acceptedMimes );

				if ( file.status ) {
					//Check extensions if acceptedMimes is not a wildcard
					if ( acceptedExt neq 0 ) {
						if ( !listFindNoCase( acceptedExt, file.results.serverFileExt ) ) {
							//Remove the file
							FileDelete( file.results.fullpath );
							return strerror( 'errFileExtMismatch', file.results.serverFileExt );
						}
					} 

					//Check expected limits ( you can even block stuff from a value in data.cfm )
					if ( structKeyExists( vk, "sizeLt" ) && !( file.results.oldfilesize lt vk.sizeLt ) ) {
						FileDelete( file.results.fullpath );
						return strerror( 'errFileSizeTooLarge', key, file.results.oldfilesize, vk.sizeLt );
					} 

					if ( structKeyExists( vk, "sizeGt" ) && !( file.results.oldfilesize gt vk.sizeGt ) ) {
						FileDelete( file.results.fullpath );
						return strerror( 'errFileSizeTooSmall', key, file.results.oldfilesize, vk.sizeLt );
					} 
				}
				s.results[ key ] = file.results; 
			}
		}
		return s;
	}


	/**
 	 * _insert
	 * 
	 * .... 
	 */
	public function _insert ( v ) {
		//Define stuff
		var datasource = "";
		var qstring    = "";
		var stmtName   = "";

		//Always pull the query first, failing if there is nothing
		if ( StructKeyExists( v, "query" ) && v[ "query" ] eq "" )
			qstring = v.query;
		else {
			return { status = false, message = "no query string specified." };
		}

		//Data source
		if ( !structKeyExists( v, "datasource" ) )
			datasource = data.source;
		else {
			datasource = v.datasource;
			StructDelete( v, "datasource" );
		}

		//Return failure on bad data sources
		if ( datasource eq "" ) {
			return { status = false, message = "no data source specified." };
		}

		//Name
		if ( !structKeyExists( v, "stmtname" ) )
			stmtName = "myQuery";
		else {
			stmtName = v.stmtname;
			StructDelete( v, "stmtname" );
		}

		//Create a new query and add each value (in the proper order OR use an "alphabetical" bind)
		structDelete( v, "query" );

		//Try an insertion
		try {
			var qs = new Query();
			qs.setSQL( qstring );

			//The BEST way to do this is check the string for ':null', ':random', and ':date'
			/*
			for ( vv in v ) 
			{
				writeoutput( vv );	
				if ( structKeyExists( v[vv], "null" ) )
					qs.addParam( name = vv, null = true );
				else if ( structKeyExists( v[vv], "null" ) )
					qs.addParam( name = vv, null = true );
			}
			*/

			//The other way to do this is to check keys within the struct  (this is long and sucks...)
			for ( var vv in v ) {
				if ( structKeyExists( v[vv], "null" ) )
					qs.addParam( name = vv, null = true );
				else if ( structKeyExists( v[vv], "random" ) )
					qs.addParam( name = vv, value = randstr(32), cfsqltype = "varchar" );
				else if ( structKeyExists( v[vv], "date" ) )
					qs.addParam( name = vv, value = Now(), cfsqltype = "timestamp" );
				else if ( structKeyExists( v[vv], "value" ) ) {
					qs.addParam( name = vv, value = v[vv].value, cfsqltype = v[vv].cfsqltype );
				}
			}

			//Set other query details
			qs.setName( stmtName );
			qs.setDatasource( data.source ); 
			rs = qs.execute( );

			return {
				status = true,
				results = rs
			};
		}
		catch (any e) {
			return {
				status = false,
				results = e.message
			};
		}
	}

	/**
 	 * checkBindType
	 * 
	 * .... 
	 */
	private function checkBindType ( Required ap, String par ) {
		//Pre-initialize 'value' and 'type'
		var v = { value="", name=par, type="varchar" };

		//If the dev only has one value and can assume it's a varchar, then use it (likewise I can probably figure out if this is a number or not)
		if ( !IsStruct( ap ) ) {
			v.value = ( Left(ap,1) eq '##' && Right(ap,1) eq '##' ) ? Evaluate( ap ) : ap;
			try {
				//coercion has failed if I can't do this...
				__ = value + 1;
				v.type = "integer";
			}
			catch (any e) {
				//writeoutput( "conversion fail: " & e.message & "<br />" & e.detail & "<br />" );
				v.type = "varchar";
			}
		}
		else if ( StructKeyExists( ap, par ) ) {
			//Is ap.par a struct?	
			//If not, then it's just a value
			if ( !IsStruct( ap[ par ] ) )
				v.value = ( Left(ap[par],1) eq '##' && Right(ap[par],1) eq '##' ) ? Evaluate( ap[par] ) : ap[par];
			else {
				if ( StructKeyExists( ap[ par ], "value" ) ) {
					var apv = ap[par]["value"];
					v.value = ( Left(apv, 1) eq '##' && Right(apv, 1) eq '##' ) ? Evaluate( apv ) : apv;
				}
				if ( StructKeyExists( ap[ par ], "type" ) ) {
					v.type = ap[ par ][ "type" ];
				}
			}
		}

		//See test results	
		//writeoutput( "Interpreted value is: " & value & "<br /> & "Assumed type is: " & type & "<br />" ); 
		//nq.addParam( name = par, value = value, cfsqltype = type );
		return v; 
	}


	//Make HTTP requests in a saner fashion
	public struct function httpRequest( required string apiUrl, required string method, struct payload, struct headers ) {
		//Define some headers
		var method;
		var fakeUa = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36";
		var apiHeaders = {};

		try {
			//Set some basic headers
			apiHeaders[ "accept" ] = "*/*";
			apiHeaders[ "Content-Type" ] = "application/x-www-form-urlencoded";
			//apiHeaders[ "User-Agent" ] = fakeUa;

			//Check for an access token
			/*
			if ( StructKeyExists( session, "access_token" ) ) {
				headers[ "Authorization" ] = "Bearer #session.access_token#";
			}
			*/

			//Negotiate method
			if ( LCase(arguments.method) eq "post" ) 
				method="post";
			else if ( LCase(arguments.method) eq "put" ) 
				method="put";
			else if ( LCase(arguments.method) eq "head" )
				method="head";
			else {
				method="get";
			}

			//Send off a request (remember that it blocks, and also that it ...???)
			var http = new http( method=UCase(method), charset="utf-8", url=arguments.apiUrl );
			http.setUserAgent( fakeUa );

			/*
			//Add the headers
			if ( StructKeyExists( arguments, "headers" ) ) {
				for ( var k in arguments.headers ) {
					http.addParam(type="header",name=k,value=headers[k]);
				}
			}
			*/

			//Add the body fields
			if ( StructKeyExists( arguments, "payload" ) ) {
				//check between get and post (or pull them)
				for ( var k in arguments.payload ) {
					//TODO: if payload is a one-level deep struct, then don't worry about looping
					//if it's deeper, then loop through each and continue adding the fields, but you have to 
					//make sure that one is part of the body and the other is part of the url
					http.addParam( type="formfield", name=k, value=payload[k] );
				}
			}

			//What goes wrong here?!
			//writedump( http ); abort;
			var h = http.send( );
			var p = h.getPrefix();
			//writedump( p ); writedump( p.fileContent ); abort;
		}
		catch (any e) {
			return {
				status = false 
			, message = "FAILURE" 
			, data = ""
			, extra = "" 
			};
		}

		//When this returns, I want to see the content in my window
		return {
			status = true
		, message = "SUCCESS" 
		, data = p.fileContent 
		, extra = p
		};
	}


	/**
	 * init()
	 *
	 * Initialize Myst.  
	 * TODO: This should only happen once.
	 */
	public Myst function init (Struct appscope) {
		//Define things
		var appdata;
		//this.href = this.link;
	
		//Initialize common elements 
		//TODO: (these should be done once, and I have yet to figure out a clean
		//way to do it.  It's going to have something to do with this step and
		//Application.cfc)
		setHttpHeaders( createObject( "component", "std.components.httpHeaders" ).init() );
		setMimeToFileMap( createObject( "component", "std.components.mimes" ).init() );
		setFileToMimeMap( createObject( "component", "std.components.files" ).init() );

		//Invoke an id to track what happens during hte session
		setRunId( randstr(32) );

		//....
		//var rootDir = getDirectoryFromPath(getCurrentTemplatePath());
		//var currentDir = getDirectoryFromPath(getCurrentTemplatePath());
		var constantMap = {}; 
		setRootDir( getDirectoryFromPath(getCurrentTemplatePath()) );
		setCurrentDir( getDirectoryFromPath(getCurrentTemplatePath()) );
		setArrayConstantMap( [ "app", "assets", "db", "files", "routes", "sql", "std", "views" ] );
		setPathSep( ( server.os.name eq "Windows" ) ? "\" : "/" );
		for ( var k in getArrayConstantMap() ) constantMap[ k ] = getRootDir() & k;
		setConstantMap( constantMap );

		//Add pre and post
		if ( StructKeyExists(appscope, "post") )
			setPostMap( appscope.post );
		if ( StructKeyExists(appscope, "pre") )
			setPreMap( appscope.pre );
		if ( StructKeyExists(appscope, "objects") ) {
			var obj = getObjects();
			for ( var x in appscope.objects ) {
				StructInsert( obj, x, appscope.objects[x] );
			}
		}

		//Now I can just run regular stuff
		try {
			logReport( "Loading data.cfm..." );
			include "data.cfm";
			setAppdata( manifest );
			//appdata = CreateObject( "component", "data" );
			appdata = getAppdata();

			//All of the properties in data.cfm (or data.cfc) should
			//show up here...
			setUrlBase( appdata.base );
			logReport( "Success!" );
		}
		catch (any e) {
			logReport( "Failure!" );
			renderPage( status=500, content="Deserializing data.cfm failed", err=e );
			abort;
		}

		//Check that JSON manifest contains everything necessary.
		for ( var key in [ "base", "routes" ] ) {
			if ( !StructKeyExists( appdata, key  ) ) {
				renderPage( status=500, content="Struct key '"& key &"' not found in data.cfm.", err={} );
			}
		}

		if ( StructKeyExists( appdata, "settings" ) ) {
			for ( var key in [ "addLogLine", "verboseLog", "logLocation" ] ) {
				this[key] = (StructKeyExists(appdata.settings, key)) ? appdata.settings[ key ] : false;
			}
		}

		//Set some other things (TODO: All of the things, not just data.source)
		if ( StructKeyExists( appdata, "source" ) ) {
			setDatasource( appdata.source );
		}

		this.app = appdata;	
		return this;
	}

	/*------------- DEPRECATED --------------------- */
	//@title: wrapError 
	//@args :
	//	Wrap error messages
	private query function wrapError(e) {
		err = e.TagContext[1];
		structInsert(myRes, 0, "status");
		structInsert(myRes, "Error occurred in file " & e.template & ", line " & e.line & ".", "error");
		structInsert(myRes, e.stackTrace, "StackTrace");
		return myRes;
	}
	/*------------- DEPRECATED --------------------- */
}

