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
An MVC framework for CFML pages.

Usage
-----
Use the command line to deploy this file and its
associated components to a new directory.

CHANGELOG
---------
See changelog.txt

TODO
----
See TODO
 * -------------------------------------------------- */
component 
name="Myst" 
accessors=true 
{

	//Cookie key name for grabbing stuff out of structs
	property name="cookie" type="string" default="45d3b6e15e31a72dbdd0ac12672f397d5b9cd959cc348d16b716b2412880";

	//Control debugging
	property name="debug" type="boolean" default="false";

	//The datasource that will be used during the life of the app.
	property name="datasource" type="string";

	//TODO: These are going to be DELETED in the near future
	//Test mode
	//property name="apiAutodie" type="boolean" default=1;
	//Set post functions
	//property name="postMap"; 
	//Set pre functions
	//property name="preMap"; 
	//The current directory as Myst navigates through the framework directories.
	//property name="currentDir" type="string"; 

	//TODO: These are going to be replaced in the near future
	//The 'manifest' value that is loaded at the beginning of starting a Myst app
	property name="appdata"; 

	//TODO: Add these
	//property name="toute" type="struct";

	//TODO: leave these alone
	//Set all http headers once at the top or something...
	property name="httpHeaders" type="struct"; 

	//The root directory
	property name="rootDir" type="string"; 

	//List of app folder names that should always be disallowed by an HTTP client
	property name="arrayConstantMap" type="array"; //Make this a list?

	//Choose a path seperator depending on system.
	property name="pathSep" type="string" default="/";  

	//Relative path maps for framework directories
	property name="constantMap" type="struct"; 

	//Relative path maps for framework directories
	property name="routingKeys" type="string"
		default="before,after,accepts,expects,filter,returns,namespace";
	//	default="before,after,accepts,expects,filter,returns,scope,wildcard,inherit";

	//Relative path maps for framework directories
	property name="urlBase" type="string" default="/"; 

	/*New as of 11/27*/
	//Allow methods to reference the current content-type
	//NOTE: An enum would be safer here, but you'll just want to use a custom setter...
	property name="selectedContentType" type="string" default="text/html"; 
	property name="contentOn404" type="string" default="File not found."; 
	property name="contentOn410" type="string" default="Authentication denied."; 
	property name="contentOn500" type="string" default="Error occurred."; 

	//property name="logString" type="struct";
	property name="logStyle" type="string" default="standard"; //combined, common,
	property name="logType" type="string" default="file";
	property name="logFile" type="string" default="log/log.txt";
	property name="logFormatCommon" type="string" default="";
	property name="logFormatCombined" type="string" default="";
	property name="logFormat" type="string" default="log/log.txt";
	property name="runId" type="string" default="";

	//
	property name="response" type="object" default=false;
	property name="pageStatus" type="number" default=200;
	property name="pageStatusMessage" type="string" default="";
	property name="pageMessage" type="string" default="";
	property name="pageError"; 
	property name="pageErrors" default="";
	property name="pageErrorExtractors" default="detail,message,type"; /*tagContext,stackTrace*/
	property name="components" type="struct";
	property name="mimetypes" type="struct";
	property name="commonExtensionsToMimetypes" type="struct";
	property name="content";
	property name="headers" type="struct";
	property name="defaultModelKey" type="string" default="model";
	property name="defaultErrorKey" type="string" default="error";
	property name="context";

	property name="defaultContentType" type="string" default="text/html";

	property name="model";

	/*DEPRECATE THESE?*/
	//Structs that might be loaded from elsewhere go here (and should really be done at startup)
	property name="objects" type="struct";
	property name="mimeToFileMap" type="struct"; 
	property name="fileToMimeMap" type="struct"; 

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
	public void function logReport ( Required String message ) {
		try {
			if ( getLogStyle() eq "standard" ) { 
				//Do a verbose log
				var id = getRunId();
				var d = DateTimeFormat( Now(), "EEEE mmmm d, yyyy HH:NN:SS tt" );
				var logMessage = "#id#: [#d# EST] #arguments.message#" & Chr(10) & Chr(13);
				var m = FileAppend( getLogFile(), logMessage );
				//writeoutput( logMessage );
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
		catch (any e) {
			//TODO: Obviously, this should pretty much always run
			//Simply catching and throwing an error isn't a good solution...
			writedump(e);
			abort;
		}
	}



	/** FORMATTING/HTML **
 * --------------------------------------------------------------------- */

	/**
	 * link( ... )
	 *
	 * Generate links relative to the current application and its basedir if it
	 * exists.
	 *
	 * TODO: Should be in an HTML component
	 */
	public string function link () {
		//Define spot for link text
		var linkText = "";
		var appdata = getAppData();

		//Base and stuff
		if ( Len( appdata.base ) > 1 || appdata.base neq "/" )
			linkText = ( Right(appdata.base, 1) == "/" ) ? Left( appdata.base, Len( appdata.base ) - 1 ) : appdata.base;

		//Concatenate all arguments into some kind of hypertext ref
		for ( var x in arguments )
			linkText = linkText & "/" & ToString( arguments[ x ] );

		//Is this a file or symbolic representation of what the server expects?
		var filepath = Left( getRootDir(), Len(getRootDir())-1 ) & linkText;
		if ( FileExists( filepath ) ) {
			return linkText;
		}

		//If this is a symbolic representation (TODO: or a .cfm), do something else.
		if ( Len( linkText ) > 1 ) {
			var f = Find( "?", linkText );
			if ( StructKeyExists( appdata, "autoSuffix" ) && appdata.autoSuffix == true && Right( linkText, 4 ) != ".cfm" ) {
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
	 * import( ... )
	 *
	 * Import components.
	 */
	public function import ( Required String cfc ) {
		if ( !StructKeyExists( variables, cfc ) )
			return null;
		else {
			return variables[ cfc ];
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
	 * Get the type of a value.
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
			typename = "unknown";
			//the non-basic types (query, closure, etc) are handled here
			try {
				if ( IsStruct( t ) && StructKeyExists( t, "access" ) )
					return { status=true, type="closure", value=sCheck }; 
				else if ( IsArray( t ) ) {
					for ( var k in [ "isCaseSensitive","name","typeName" ] ) {
						if ( !StructKeyExists( t[1], k ) ) {
							return { status=false, type=typename, value={} }; 
						}
					}
					//TODO: Will 'sCheck' be copied?  b/c this is pretty slow...
					return { status=true, type="query", value=sCheck }; 
				}
			}
			catch (any de) {
				//This should catch either truly unknown or badly wrapped types (like queries)
				return { status=false, type=typename, value={} };
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
	public function _include (Required String where, Required String name) {
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
			, error = "Requested inclusion of a file not in the web directory."
			, exception  = {}
			, ref = ""
			};
		}

		//Set ref here, I'm not sure about scope.
		ref = ToString( where & getPathsep() & name & ".cfm" );
		
		//Include the page and make it work
		try {
			//The content should be wrapped and returned...
			savecontent variable="content" {
			include ref; 
			}
		}
		catch (any e) {
			return {
				status = false
			 ,error = "Myst caught a '#e.type#' exception when trying to include file #ref#"
			 ,exception = e
			 ,ref = ref 
			}
		}

		return {
			status = true
		 ,ref = ref 
		 ,results = content 
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
	 * getExtension( ) 
	 *
   **/
	public string function getExtension( required string filename ) {
		var arr = ListToArray(filename, ".");
		if ( Len(arr) > 1 ) {
			return arr[ Len(arr) ];	
		}
		return "";
	}

	public string function getNamePart( required string filename ) {
		var arr = ListToArray(filename, ".");
		if ( Len(arr) > 1 ) {
			ArrayDeleteAt( arr, Len(arr) );
			return ArrayToList( arr, "." );	
		}
		return "";
	}



	/**
 	 * dbExec 
	 *
	 * Execute queries cleanly and easily.
	 */
	public function dbExec ( String datasource="#getAppData().source#", String filename, String string, bindArgs, Query query ) {
		//Set some basic things
		var Name = "query";
		var Constant = "sql";
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
			fp = cm[ Constant ] & "/" & arguments.filename;
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
		}

		//Set up a new Query
		if ( !cQuery )
			q = new Query( name="#Name#", datasource="#arguments.datasource#" );	
		else {
			q = new Query( name="#Name#", dbtype="query" );
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
					try { __ = value + 1; type = "integer"; }
					catch (any e) { type="varchar"; }
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
	public string function randstr ( Numeric n ) {
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

	private array function queryToArray( Required Query arg ) {
		var ar = ArrayNew(1);
		for ( var v in arg ) ArrayAppend( ar, v );
		return ar;
	}

	//Return pretty JSON with the correct casing from one place...
	public String function queryToJSON ( Required Query arg ) {
		/*
		var ar = ArrayNew(1);
		for ( var v in arg ) ArrayAppend( ar, v );
		return SerializeJSON( ar );
		*/
		return SerializeJSON( queryToArray( arg ) );
	}

	//Return pretty JSON with the correct casing from one place...
	//NOTE: This is for one row
	public string function structToJSON ( Required Struct arg ) {
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

	/**
	 * sendResponse
	 *
	 * Send a response.
	 *
	 */
	private boolean function sendResponse (Required Numeric s, Required string m, Required string c, Struct headers) {
		var r = getPageContext().getResponse();
		var w = r.getWriter();
		var sMessage = getHttpHeaders()[ s ];
		r.setStatus( s );
		r.setStatus( s, sMessage );
		//r.setStatusMessage( getHttpHeaders()[ s ] );
		r.setContentType( m );
		r.setContentLength( Len(c) );
		w.print( c );
		w.flush();
		r.close(); 
		return true;
	}

	/**
	 * sendBinaryResponse
	 *
	 * Send a binary response.
	 *
	 */
	private function sendBinaryResponse(Required numeric s, Required string m, required numeric size, required c) {
		var q = getPageContext().getResponse();
		var r = getPageContext().getResponseStream();
		//You can optionally make a bytestream here
		q.setStatus( s, getHttpHeaders()[s] );
		q.setContentType( m );
		q.setContentLength( size );
		r.write( c );
		r.close();
	}


	/**
	 * formatRepsonse() 
	 *
	 * Return a formatted string dependent on the content-type.
   * TODO: Convert from some reusable closure instead of this...
	 */
	private string function formatResponse ( Required c ) {
		var rtype = getSelectedContentType();
		var ctype = getType( c ).type;
		var ERR_FMT_RESPONSE = "Unsupported input type given to formatResponse()";
		var ERR_FMT_REQUEST = "Unsupported return format requested.";

		//Strings have to be return in key value format when returning JSON
		if ( ctype eq "string" ) {
			if ( rtype eq "application/json" || rtype eq "json" )
				return returnAsJson( { "#getDefaultModelKey()#" = c } );
		/*
			else if ( rtype eq "application/xml" || rtype eq "xml" )
				return returnAsJson( c );
		*/
			else {
				return c;
			}
		}
		else if ( ctype eq "struct" ) {
			//TODO: Should I throw an error or force conversion?
			if ( rtype eq "application/json" || rtype eq "json" )
				return returnAsJson( c );
			/*
			else if ( rtype eq "application/xml" || rtype eq "xml" )
				return returnAsJson( c );
			*/
			else {
				return ERR_FMT_RESPONSE; 
			}
		}
		else {
			if ( rtype eq "application/json" || rtype eq "json" )
				return returnAsJson( { "#getDefaultErrorKey()#" = ERR_FMT_RESPONSE } );
			/*
			else if ( rtype eq "application/xml" || rtype eq "xml" )
				return returnAsJson( c );
			*/
			else {
				//TODO: Should I throw an error or force conversion?
				return ERR_FMT_RESPONSE;
			}
		}

		//Anything else is a failure
		return c;
	}	

	
	/**
	 * renderPage
	 *
	 * Generates a page to send to stdout
		err should have:
		- status
		- status message
		- official coldfusion exception type or 'unknown exception occurred'
		- message about what went wrong (simple, abridged, brief)
		optionally:
		- detailed message (complex, unabridged, detailed)
		- stack trace (formatted to the best of ability)
	 */
	private function renderPage( Required Numeric status, Required content, Struct err ) {
		var t = getType( arguments.content ).type;
		var tt = getSelectedContentType();
		var error = {};
		var headers = {};
		var newContent;

		//SANITY CHECKS HERE	
		//TEST #1: If t is not string or struct, don't even try...
		if ( t neq "string" && t neq "struct" ) {
			newContent = formatResponse( "type #t# is an invalid return format." );
			status = 500; 
		}

		//TEST #2: If status is invalid, return a failure
		if ( !status || status < 100 || status > 599 ) {
			newContent = formatResponse( "Expected HTTP status is invalid." ); 
			status = 500; 
		}

		//TEST #3: If an invalid content-type is requested, return a failure
		if ( !StructKeyExists( getMimetypes(), tt ) ) {
			newContent = formatResponse( "Expected HTTP content type is invalid." );
			status = 500; 
		}

		//Check error status and prepare an error structure if one is not provided
		if ( status > 399 ) {
			//Set common items
			error.status = status;
			error.statusMessage = getHttpHeaders()[status]; 
			error.brief = ( t eq "string" ) ? arguments.content : "Unspecified error occurred.";

			if ( StructKeyExists( arguments, "err" ) ) {
				var ktype = ( !StructKeyExists(err, "type") ) ? "undefined" : err.type;
				error.brief = "An #ktype# error has occurred.";
			}
			else
			if ( !StructKeyExists( arguments, "err" ) || StructIsEmpty( arguments.err ) ) {
				for ( var k in getPageErrorExtractors() ) error[ k ] = "";
				if ( status eq 401 )
					error.detailed = "The client asked for access to a page it does not have access to.";
				else if ( status eq 404 ) {
					error.detailed = "The client made a request for '#cgi.script_name#' and it was not found on this server.";
				}
			}
			/*
			else {
				//Handle errors of different exception types
				var ktype = (!StructKeyExists(err, "type")) ? "undefined" : err.type;
				error.brief = "An #ktype# error has occurred.";
				if ( !StructKeyExists( arguments.err, "type" ) )
					error.brief = "An undefined error has occurred.";
				else {
					error.brief = "An '#err.type#' error has occurred.";
				}
			}
			*/

			//Set all arguments
			for ( var n in arguments ) 
				error[ n ] = arguments[n];
			for ( var n in arguments.err )
				error[ n ] = arguments.err[n];

			//Clean up the new structure a little bit more
			StructDelete( error, "err" );
			setPageError( error );
			//writedump( getPageError() );

			if ( tt == "text/html" ) {
				var f = ( status > 399 && status < 500 ) ? 4 : 5;
				var cs;

				savecontent variable="newContent" {
					cs = _include( where="std", name="#f#xx-view" );
				}

				if ( !cs.status ) {
					error.brief = cs.errors;
					status = 500;
				}
			}
		}

		if ( status < 300 ) {
			newContent = formatResponse( content );
		}

		try {
			sendResponse( s=status, m=tt, c=newContent );
		} 
		catch( any e ) {
			writedump(e); 
			abort;
		}
abort;
		return { status = true, message = "SUCCESS" }
	}


	/**
	 * sendAsJson (t)
	 *
	 * Send a struct back wrapped as a JSON object.
	 */
	public string function sendAsJson ( ) {
		var a = structToJSON( arguments );
		if ( 0 )
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
	 * sendQueryAsJson (t)
	 *
	 * Send a query back wrapped as a JSON object.
	 */
	public string function sendQueryAsJson ( Query q ) {
		var a = queryToJSON( q );
		if ( 0 )
			writeoutput( a );
		else {
			pc = getpagecontext().getResponse();
			pc.setContentType( "application/json" );
			writeoutput( a );
			abort;
		}
		return a;
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
				evalModel( rd.model );
			}
			//Evaluating hooks can be done differently...
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


	/**
	 * returnAsJson ( Struct model )
	 *
   * ...
	 *
	 **/		
	private function returnAsJson( Struct model ) {
		//Filtering should have already been run by this time
		for ( var k in model ) {
			//v should always be a struct with at least a key and value
			var v = model[k];
			var t = getType( v );
			var c;
			//writedump( v ); writedump( model[v] ); writeoutput( "<h2>#k#</h2>" );
			if ( t.type eq "struct" || t.type eq "array" ) 
				c = v; //writeoutput( SerializeJSON( v ) );	
			else if ( t.type eq "query" ) 	
				c = queryToArray(v); //writeoutput( queryToJSON( v ) );	
			else {
				//If we got this far, it's probably a scalar value
				//writeoutput( "Scalar type is #t.type#" );
				c = ( LCase( t.type ) eq "string" ) ? "#v#" : v;//writeoutput( v );
			}
			model[ k ] = c;
		}
		//writeoutput( structToJSON( model ) ); abort;		
		return this.structToJSON( model );		
	}


	//TODO: Prod boxes should be more selective in what's brought back
	public struct function lfailure( required numeric status, required string message, struct exception ) {
		return {
			status = false
		, error = message
		, httpstatus = status
		, exception = StructKeyExists( arguments, "exception" ) ? exception : {}
		};
	}

	/**
	 * failure( numeric status=500, required string message, struct exception )
	 *
   * Short way to call internal server error failures.
	 **/		
	public struct function failure( required string message, struct exception ) {
		return lfailure(
		  message = message
		, status = 500
		, exception = StructKeyExists( arguments, "exception" ) ? exception : {}
		);
	}

	
	/**
	 * lsuccess( numeric status=500, required string message, struct exception )
	 *
   * Short way to call internal server error failures.
	 **/		
	public struct function lsuccess( required numeric status, required string message, results ) {
		return {
			status = true
		, httpstatus = status 
		, message = message
		, results = StructKeyExists( arguments, "results" ) ? results : {}
		}
	}

	/**
	 * success( numeric status=200, required string message, results )
	 *
   * ...
	 **/		
	public struct function success( required string message, results ) {
		return lsuccess(
		  message = message
		, status = 200
		, results = StructKeyExists( arguments, "results" ) ? results : {}
		);
	}

	/**
	 * evaluateClosure ( Required closure )
	 *
   * Execute a closure and wrap any errors appropriately
	 *
	 **/		
	private any function evaluateClosure( required funct, struct model ) {
		var results;
		try {
			results = funct( this, StructKeyExists( arguments, "model") ? model : {} );
		}
		catch (any e) {
			return {
				status = false
			, error = "Error executing closure."
			, httpstatus = 500 
			, exception = e
			}
		}
		return {
			status = true
		, results = results
		}
	}


	/**
	 * evalModel ( Required rd )
	 *
   * Return a struct composed of elements and keys...
	 *
	 **/		
	private struct function evaluateModelKey( Required struct routedata ) {
		logReport( "Evaluating models @ #routedata.name#" );

		var pgArray = [];
		var result = {};
		var ev;
		var namespace = StructKeyExists( routedata, "namespace" ) ? routedata.namespace: {};

		//Stop if there is no routedata
		if ( !StructKeyExists( routedata, "model" ) ) {
			return { status = true };
		}

		//Build an array out of whatever value the model may be...
		if ( ( ev = getType( routedata.model ) ).type != 'array' && ev.type != 'struct' )
			ArrayAppend( pgArray, { type=ev.type, value=ev.value } );
		else if ( ev.type == 'struct' )
			return failure( "Models as structs are not yet supported (check key at #routedata.file#)." ); 
		else {
			for ( var ind=1; ind<=ArrayLen(ev.value); ind++ ) {
				var ee = ev.value[ ind ]; 
				var ey = getType( ee );	
				if ( ey.type == "string" || ey.type == "closure" )
					ArrayAppend( pgArray, { type=ey.type, value=ey.value });
				else if ( ey.type == "struct" )
					ArrayAppend( pgArray, { type=ey.type, value=ey.value });
				else {
					return failure( "Got unsupported type for model at index #ind# at key '#routedata.file#'" );
				}
			}
		}

		//Now load each model, should probably put these in a scope
		for ( var page in pgArray ) {
			var cexec;
			var nsref; 
			var path;

			//Model can be a struct too, this automatically puts things in things...
			if ( page.type == "struct" /*catch other types?*/ )
				return failure( "Models as structs currently aren't supported." );
			else if ( page.type == "closure" ) {
				if ( !( cexec = evaluateClosure( page.value, result ) ).status )
					return cexec;
				else {
					//TODO: this can easily be 
					if ( gettype( cexec.results ).type != "struct" )
						StructInsert( result, nsref, cexec.results );
					else {
						for ( var k in cexec.results ) {
							if ( !StructKeyExists( getAppdata(), "ignoreConflicts" ) || !getAppdata().ignoreConflicts )
								StructInsert( result, k, cexec.results[ k ] );
							else if ( !StructKeyExists( result, k ) )
								StructInsert( result, k, cexec.results[ k ] );
							else {
								return failure( "Encountered duplicate key '#k#' when evaluating model #csref#" ); 	
							}
						}
					}
				}
			}
			else if ( page.type == "string" ) {
				//If path contains @, then just replace it
				if ( FindNoCase( "@", page.value ) == 0 )
					path = "#getRootDir()#app/#page.value#";
				else {
					page.value = Replace( page.value, "@", routedata.file ); 
					path = "#getRootDir()#app/#page.value#";
				}

				//Use either namespace or basename to identify the model when more than one is in use...
				if ( StructKeyExists( namespace, page.value ) )
					nsref = namespace[ page.value ];
				else {
					//nsref = Replace( page.value, "/", "_" );
					var pv = ListToArray( page.value, "/" );
					nsref = pv[ Len( pv ) ];	
				}

				if ( !FileExists( "#path#.cfc" ) && !FileExists( "#path#.cfm" ) )
					return failure( "Could not locate requested model file '#page.value#.cf[cm]' for key 'default'" );
				else if ( FileExists( "#path#.cfc" ) ) {
					//Try to evaluate the model file, if it fails, let the user know why 
					if ( !( cexec = invokeComponent( "app.#page.value#", result )).status ) {
						return cexec;
					}
					//Model splitting is now done manually...
					else {
						//TODO: Should I still support the split evaluation model?
						//result[ nsref ] = cexec.results;
						//TODO: Should a status of false just kill everything?
						//if the type is anything besides a struct, it needs a name 
						if ( gettype( cexec.results ).type != "struct" )
							StructInsert( result, nsref, cexec.results );
						else {
							for ( var k in cexec.results ) {
								if ( !StructKeyExists( getAppdata(), "ignoreConflicts" ) || !getAppdata().ignoreConflicts )
									StructInsert( result, k, cexec.results[ k ] );
								else if ( !StructKeyExists( result, k ) )
									StructInsert( result, k, cexec.results[ k ] );
								else {
									return failure( "Encountered duplicate key '#k#' when evaluating model #csref#" ); 	
								}
							}
						}
					}
				}
				else { //if ( FileExists( "#path#.cfm" ) ) {
					//Models executed this way end up being global or explicitly injected with setScope... 
					if ( !( cexec = _include( where="app", name=page.value ) ).status ) {
						return cexec;
					}
				}
			}
			else {
				//Catch closures and send the result set into it
				try {
					page.value( result );
				}
				catch (any e) {
					return failure( "Error executing model closure at route '???'" );
				}
			}
		}

		return {
			status = true,
			results = result
		}
	}


	/**
	 * private String function evalView ( Required struct rd )
	 *
	 * Evaluates a view.
	 */
	private struct function evalView( Required Struct rd, Struct modeldata ) {
		logReport( "Evaluating views..." );
		//Evaluate a single view
		try {
			var the_page_content;
			savecontent variable="the_page_content" {
				//Get the type name
				var ev = getType( rd.view );
				
				//Custom message is needed here somewhere...
				if ( ev.type != "string" && ev.type != "array" ) {
					return {
						status = false,
						error = "View value for '#rd.file#' was not a string or array.",
						exception = {} 
					}
				}

				//Set pageArray if it's string or array
				var pageArray = (ev.type == 'string') ? [ ev.value ] : ev.value;
				var cs;
			
				//Now load each model, should probably put these in a scope
				for ( var x in pageArray ) {
					x = FindNoCase( "@", x ) ? Replace( x, "@", rd.file ) : x;
					if ( !( cs = _include( where="views", name=x ) ).status ) {
						return cs;
					}
					writeoutput( cs.results );
				}
			}
		}
		catch (any e) {
			//Manually wrap the error template here.
			return {
				status = false,
				error = "Error in parsing view for '#rd.file#'.",
				exception = e 
			}
		}

		return {
			status = true,
			results = the_page_content
		}
	}


		
	/**
   * Wrap loading components to catch any errors.
	 */
	private any function invokeComponent( required string cname, model ) {
		var comp;
	  var _model = StructKeyExists( arguments, "model" ) ? model : {};
		try {
			comp = createObject( "component", cname ).init( this, _model ); 
		}
		catch (any e) {
			return failure(
			  exception = e
			, message = "While attempting to open #cname#. #e.message#"
			);
		}
		return {
			status = true
		, results = comp
		}
	}


	/**
   * loadComponents()
	 */
	private Struct function loadComponents( struct appdata ) {
		//Load all the components should have been loaded...
		logReport( "Loading components..." );

		//Define these here for sensible error handling.
		var cname;
		var componentStruct = {};
		var datasource;
		var dir = "components";
		var fname;
	
		//Choose a datasource for each of our modules to use here.
		if ( StructKeyExists( appdata, "source" ) )
			datasource = appdata.source;
		else if ( StructKeyExists( application, "datasource" ) )
			datasource = application.datasource;
		else if ( StructKeyExists( application, "defaultdatasource" ) )
			datasource = application.defaultdatasource;
		else {
			; //What do I do if there is no datasource?
		}

		try {
			//Initialize each component with common properties
			for ( var q in DirectoryList( "components", false, "query", "*.cfc" ) ) {
				logReport( "Loading component '#q.name#'..." );
				cname = Replace( q.name, ".cfc", "" );
				fname = q.name;
				//TODO: A ListContains() check will be faster than this most likely
				if ( q.name neq "Application.cfc" && q.name neq "base.cfc" ) {
					var vv = Replace( q.name, ".cfc", "" );
					//var cname = Replace( q.name, ".cfc", "" );
					if ( FileExists( "#getRootdir()#components/overrides/#q.name#" ) )
						componentStruct[ cname ] = createObject( "component", "components.overrides.#cname#" ).init( myst = this );
					else {
						componentStruct[ cname ] = createObject( "component", "components.#cname#" ).init( myst = this );
					}	
					//componentStruct[ cname ] = createObject( "component", "components.#cname#" ).init( myst = this );
					/*
					, realname = cname
					, namespace = cname
					, datasource = datasource
					, debuggable = 0
					, verbose = 0
					);
					*/
				}
				logReport("Successfully loaded component #q.name#!");
			}
			return {
				status = true,
				results = componentStruct
			}
		}
		catch (any e) {
			return	{
				status = false,
				error = "Component load failed at #fname#",
				exception = e
			} 
		}
	}


	/**
	 * appendIndependentRoutes()
	 *
	 * 
	 */
	private Struct function appendIndependentRoutes ( data ) {
		logReport("Loading independent routes...");

		try {
			//Add more to logging
			var dirQuery = DirectoryList( "routes", false, "query", "*.cfc" );
			var callstat = 0;
			var routes = {};

			for ( var q in dirQuery ) {
				//...
				if ( q.name neq "Application.cfc" ) {
					var name = Replace( q.name, ".cfc", "" );
					var comp = invokeComponent( "routes.#name#" );
					if ( !comp.status )
						return comp; //failure( "Route injection failed: #comp.message#", comp );
					else {
						StructAppend( routes, comp.results ); 
					}
				} 
			}
			logReport("SUCCESS - All routes loaded!");
			return { status=true, results=routes };
		}
		catch (any e) {
			return failure( message="Route injection failed.", exception=e );
		}
		return { status=true, results={} };
	}


	private array function extractKeys( struct str ) {
		var arr = [];
		for ( var k in str ) {
			ArrayAppend( arr, k );
		}
		return arr;
	}


	/**
	 * ???
   *
	 * This is supposed to turn my routing table into something else.
	 **/
	private function evaluateRoutingTable( Required Struct arg, Struct found, key = "__TOP__" ) {
		var a;
		try {
			var nStruct = {};

			//If found is not blank, loop through each of those and add them...
			if ( !StructIsEmpty( found ) ) {
				for ( var f in found ) {
					arg[ f ] = found[ f ];
				}
			}

			//Check the struct for any keys, apply them to whatever struct
			for ( var k in ListToArray( getRoutingKeys() ) ) {
				if ( StructKeyExists( arg, k ) ) {
					nStruct[ k ] = arg[ k ];
				}
			}

			//Finally, loop through...gin.cfm
			for ( var vv in arg ) {
				//TODO: This is probably slow
				//Descend into each key and apply the next level...

				if ( !ArrayContains( ListToArray( LCase( getRoutingKeys() ) ), LCase( vv ) ) ) {
//writeoutput( "#vv# was found...<br />" ); 

					//If the type is a struct, we need to evaluate again
					if ( getType( arg[ vv ] ).type eq 'struct' ) {
				
//writeoutput( "before transform:<br>" );	
//writedump( arg[ vv ] );	
						//return arg and replacing that key ought to work best
						var y = evaluateRoutingTable( arg[ vv ], nStruct, vv );
						if ( y.status )
							arg[ vv ] = y.results;
						else {
							return {
								status = false
							, message=  "router inheritance failed."
							}
						}
					}
				}

			}
		}
		catch (any e) {
			return {
				error = "Unknown exception occurred at routing table evaluation."
			, exception = e
			, status = false
			}
		}

//writeoutput( "Done with key #key# <br />" );
		return {
			status = true
		, results = arg
		}
	}


	//TODO: This is looking more and more like a class
	private Struct function evaluateRouteData( Struct data ) {

		var index = "_";
		var base = "default";
		var localName;
		var ses_path;
		var path;
		var parent;
		var file;

		//Add more to logging
		logReport( "Evaluating URL route..." );

		//TODO: Is this ever a good idea?
		//if ( !structKeyExists( data, "routes" ) || StructIsEmpty( data.routes ) )
		//	return { model="default", view="default", file="", path="/", status=200 }

		//Check for SES path
		//var ses_path = check_deep_key( data, "settings", "ses" ) ? cgi.script_name : cgi.path_info;
		ses_path = cgi.script_name;

		//Handle situations where no routes are defined.
		if ( !structKeyExists( data, "routes" ) || StructIsEmpty( data.routes ) ) {
			return { status=false, error="Routes are not defined in data.cfm", exception={} }
		}

		//Modify model and view include paths if there is a basedir present.
		if ( StructKeyExists( data, "base" ) ) {
			if ( Len( data.base ) > 1 )
				base = data.base;	
			else if ( Len( data.base ) == 1 && data.base == "/" )
				base = "/";
			else {
				base = data.base;	
			}
			//Simply lop the basedir off of the requested URL if that was requested
			localName = Replace( ses_path, base, "" );
		}


		//Handle requests for the home page 
		if ( localName == index || localName == "#index#.cfm" ) {
			if ( !StructKeyExists( data.routes, "index" ) && !StructKeyExists( data.routes, "default" ) )
				return { status=false, error="No default route specified in data.cfm", exception={} }
			else {
				//return rl.routes.default;
				var tt = StructKeyExists( data.routes, "index" ) ? data.routes.index : data.routes.default;
				tt.file = "index.cfm";
				tt.path = "/";	
				tt.status = true;
				tt.name = Replace( cgi.script_name, ".cfm", "" );
				return tt;
			}
		}

		//Get ready to start moving through and writing a matcher (there should be only one)
		var depth = 0;
		var route = data.routes;
		var paths = ListToArray( localName, "/" );
		var parts = [];
		ArrayDeleteAt( paths, Len( paths ) );
		//Do you want to match literally? Or match using regex, at a specific level?

		for ( var filepath in paths ) {

			if ( StructKeyExists( route, filepath ) ) {
				route = route[ filepath ];
				path = ListAppend( path, filepath, "/" );
				file = filepath;
				ArrayAppend( parts, { name=filepath, regex=false } );
			}
			else {
				//No simple matches were found, so run against any regexes
				var re;
				var is404 = false;
				var reMatched = false;
				try {
					//Check the current level for wildcard or RE
					var routeKeys = this.extractKeys( route ); 
					routeKeys.each( function(e,i,a) { a[i] = LCase(e); } );
					routeKeys.removeAll( ListToArray( "#getRoutingKeys()#" ) );

					//If the name is NOT regexed (or there are no regexes)
					//It's a 400?
					if ( Len( routeKeys ) == 0 )
						is404 = true;
					else {	
						//if it is, but there is no match then it's a 404
						for ( key in routeKeys ) {
							re = key;
							//Pull out normally matched strings
							if ( REFind( "[a-z]", key ) == 1 ) {
								is404 = true;
								continue;
							}

							is404 = false;
							//Stop at the first match
							if ( REFind( key, filepath ) > 0 ) {
								reMatched = true;
								route = route[ key ];						
								break;
							}
						}
					}
				}
				catch (any e) {
					return {
						status = false
					, error = "Error in router handling, check route defined at '#re#'"
					, exception = e
					}
				}

				if ( !reMatched ) {
					return {
						status = false 
					, error = (is404) ? "No mapping for '#filepath#' found." :
							"Parameter did not match regex at #re#"
					, type = (is404) ? 404 : 400 
					, path=path
					, file=filepath
					};
				}
				ArrayAppend( parts, { name=filepath, regex=true } );
			}
		}

		var diff = 	Len(path) - Len(file);
		route.file = file;
		route.info = parts;
		route.path = ( diff ) ? Left( path, diff ) : path; 
		route.status = true;
		route.name = "/#ArrayToList( paths, "/" )#";
		logReport( "SUCCESS!" );
		return route;	
	} 


	private struct function evaluateScopeKey( Struct routedata ) {
		if ( StructKeyExists( routedata, "scope" ) ) {
			logReport( "Evaluating key 'scope' @ /#data.page#..." );
			logReport( "SUCCESS!" );
			return {
				status = true,
				results = routedata.scope
			}
		}
		return {
			status = true,
			keyNotFound = true,
			results = routedata.scope
		}
	}

	private struct function evaluateReturnsKey( Struct routedata, Struct appdata ) {
		var r;
		var k;
		logReport( "Evaluating key 'returns' @ /#routedata.name#..." );

		//Check for key first in routedata, and then appdata
		if ( StructKeyExists( routedata, "returns" ) ) {
			r = routedata.returns;
			k = "routes.#routedata.name#";
		}
		else if ( StructKeyExists( appdata, "returns" ) ) {
			r = appdata.returns;
			k = "top-level";
		}
		else {
			return { 
				status = true, 
				results = getDefaultContentType()
			}
		}

		if ( getType( r ).type neq "string" ) {
			return failure( "Key 'returns' at #k# is not a string." );
		}

		if ( !StructKeyExists( getMimeTypes(), routedata.returns ) ) {
			return failure( "Key 'returns' points to unsupported mimetype '#routedata.returns#' at #routedata.name#." );
		}

		return {
			status = true,
			results = routedata.returns
		}
	}

	private struct function generateLogFmt( Required String key, Required String page ) {
		return {
			key = key,
			message = "Evaluating key '#key#' at '#page#'"
		}
	}

	private struct function evaluateBeforeKey( Struct routedata ) {
		var key = "before"
		//var log_message = "Evaluating key '#key#' at /#routedata.page#..."
		
		//Run something before every request to this endpoint
		if ( StructKeyExists( routedata, key ) ) {
			logReport( "Evaluating key '#key#' at /#routedata.page#..." );
			evalHook( routedata.before, scope );
			//Evaluate any models, etc
			if ( StructKeyExists( routedata.before, "model" ) ) {
				0;//evalModel( routedata.before.model, scope );
			}
			//Evaluate any views, this should probably just be a string
			if ( StructKeyExists( routedata.before, "view" ) ) {
				0;//evalView( routedata.before.view, scope );
			}
			//Get the type of routedata.before
			logReport( "SUCCESS!" );
		}
		return { status = true };
	}

	private struct function evaluateAcceptsKey( Struct routedata ) {
		
		//Checks the actual method
		if ( StructKeyExists( routedata, "accepts" ) ) {
			logReport( "Evaluating key 'accepts' @ /#data.page#..." );
			//If the method is NOT a member of routedata.accepts, die...
			if ( ArrayFind( ListToArray( routedata.accepts ), cgi.request_method ) == 0 ) {
				//renderPage(405, "This endpoint does not accept method '#cgi.request_method#'");
				//renderPage( status=405, content="This endpoint does not accept method '#cgi.request_method#'" ); 
				return {
					status = false,
					error = "This endpoint does not accept method '#cgi.request_method#'",
					exception = {}
				}
			}
			logReport( "SUCCESS!" );
		}
		return { status = true }
	}

	private struct function evaluateExpectsKey( Struct routedata ) {
		
		//Checks the values within a particular scope 
		if ( StructKeyExists( routedata, "expects" ) ) {
			logReport( "Evaluating key 'expects' @ /#data.page#..." );
			var allowed = ( StructKeyExists( routedata, "accepts" ) ) ? routedata.accepts : ListToArray("GET,POST");
			routedata.expects = ListToArray( routedata.expects );
			//Build a list of scopes from the above (if thrown)
			//Otherwise, we ought to assume that the variables could be anywhere 
			var s = { GET=url, POST=form };
			var kFind = {};
			for ( var k in routedata.expects ) {
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
					var content = "This endpoint expected variables it did not receive.";
					//TODO: If no err and status is greater than 399, type is 'custom', detail, I dunno...
					//renderPage( status=412, content=content, err={ message=content,detail="",type="" } );
					//renderPage(412, content, err={ message=content,detail="",type="" } );
					return {
						status = false,
						error = "This endpoint expected variables it did not receive.",
						exception = {}
					}
				}
			}
			logReport( "SUCCESS!" );
		}
		return { status = true };
	}

	private function evaluateQueryKey( Struct routedata ) {
		/*
		//Query SHOULD be higher precedence than model
		if ( StructKeyExists( routedata, "query" ) ) {
			logReport( "Evaluating key 'query' @ /#data.page#..." );
			//routedata.query = "";
			logReport( "SUCCESS!" );
			//Queries ARE supposed to be automatically brought back as things...
		}
		*/
		return { status = true };	
	}

/*
	private struct function evaluateModelKey( Struct routedata ) {
		logReport( "Evaluating models @ #routedata.name#" );
		//This is where rethinking things could help, scope should be another argument.
		if ( StructKeyExists( routedata, "model" ) ) {
			//The status should return here, and errors handled
			var model = evalModel( routedata.model );	
			return model;
		}

		return { status = true }
	*/

	private function evaluateFilterKey( Struct routedata ) {
		//Filter out the scope when returning JSON
		if ( StructKeyExists( routedata, "filter" ) ) {
			//Get the right variable from the scope and stop
			//Break the line at '.' and run a loop for each time	
			//Filter is expected to be used with JSON and XML (other interchange is fine too, but needs help)
			//Keep going through the scope until the element is found...
			//Haroutedata to say whether or not it should be an exception...
			routedata.filter = ListToArray( routedata.filter, "." );
			for ( var n in routedata.filter ) {
				if ( StructKeyExists( variables.pageScope, n ) ) {
					variables.pageScope = variables.pageScope[ n ];
				}
			}
		}
	}


	private function evaluateViewKey( Struct routedata, Struct modeldata ) {
		//Run a view
		if ( !StructKeyExists( routedata, "view" ) )
			return { status = true, keyNotFound = true };	
		else {
			logReport( "Evaluating views @ #routedata.name#..." );
			return evalView( routedata, modeldata );
		}
	}


	private function evaluateAfterKey( Struct routedata ) {
		
		if ( StructKeyExists( routedata, "after" ) ) {
			logReport( "Evaluating key 'after' @ #routedata.name#..." );
			evalHook( routedata.after );
			//writedump( t );
			logReport( "SUCCESS!" );
		}

		//Render the final payload...
	}


	private function dieOnFail( c ) {
		writedump( c );
		abort;
	}


	//Return just the result set when a call was successful.
	private function extractResults( struct data ) {
		if ( data.status && StructKeyExists( data, "results" ) ) {
			return data.results;	
		}
		return data;
	}

	/**
	 * serveStaticResource( array parts )
	 *
	 * ...
	 *
	 **/
	public function serveStaticResource( required array parts, string path, string err ) {
		try {
			var spath;
			var metadata;
			var extension;
			var mimetype;

			if ( StructKeyExists( arguments, "path" ) )
				spath = arguments.path;
			else {
				//Get the part of URL that we want.
				ArrayDeleteAt( parts, Len( parts ) );

				//Generate the path of the requested file here.
				spath = ArrayToList( parts, "/" );
			}

			//If the file does not exist, send a 404
			if ( !FileExists( spath ) ) {
				var str = StructKeyExists( arguments, "err" ) 
					? arguments.err : "Error 404: File '#spath#' not found";
				return this.sendResponse( 404, "text/html", str );
			}

			//If you have problems accessing it, send a 403
			metadata = GetFileInfo( spath );
			if ( !metadata.canRead ) {
				return this.sendResponse( 403, "text/html", "Error: Access Forbidden" );	
			}

			extension = this.getExtension( spath );
			if ( extension eq "" || !StructKeyExists( getCommonExtensionsToMimeTypes(), extension ) )
				mimetype = "application/octet-stream"; 
			else {
				mimetype = getCommonExtensionsToMimetypes()[ extension ];
			}

			//If the file exists, throw it back
			return this.sendBinaryResponse( 200, mimetype, metadata.size, FileReadBinary( spath ) );  
		}
		catch (any e) {
			return this.respondWith( 500, {
				error = "unknown error",
				exception = e,
				status = false
			});
		}
	}


	private function loadAppDataComponent( ) {
		logReport( "Loading data.cfm..." );
		try {
			include "data.cfm";
			setAppdata( manifest );
			//appdata = CreateObject( "component", "data" );
			var appdata = getAppdata();

			//All of the properties in data.cfm (or data.cfc) should
			//show up here...
			setUrlBase( appdata.base );
			logReport( "Success!" );
			return {
				status=true,
				results=appdata
			}
		}
		catch (any e) {
			logReport( "Failure!" );
			return failure( "Deserializing data.cfm failed", e );
			//return this.respondWith( 500, { error="Deserializing data.cfm failed", exception=e, status=false } );
			//abort;
		}
	}

	/**
	 * makeIndex( Myst mystInstance )
	 *
	 * Generate a page through the page generation cycle.

		With this new system in place, some things have higher precedence...
		'before' is always first
		'accepts', 'expects', and possibly 'scope' really should be run...
		'query' should come before model (if implemented)
		'model' ought to be next
		'returns' does little good right now..., models can be done..., I suppose
		'view(s)' next
		'after' should always be final 

	 */
	function init ( string page ) { //Myst MystInstance, globs) {
		//TODO: Change these from global scope when full object conversion happens.
		//variables.coldmvc = MystInstance;
		//variables.db = MystInstance.app.data;
		//variables.myst = MystInstance;
		//variables.data = MystInstance.app;
		var pageParts = ListToArray(page, "/");
	
		//Invoke all components 
		setHttpHeaders( new std.components.headers() );
		setMimetypes( new std.components.mimes() ); 
		setCommonExtensionsToMimetypes( new std.components.files() );
		setRunId( this.randstr(32) );
		setRootDir( getDirectoryFromPath(getCurrentTemplatePath()) );
		setPathSep( ( server.os.name eq "Windows" ) ? "\" : "/" );
		//TODO: Convert this to a list
		setArrayConstantMap( [ "app", "assets", "db", "files", "routes", "sql", "std", "views" ] );
		for ( var k in getArrayConstantMap() ) constantMap[ k ] = getRootDir() & k;
		setConstantMap( constantMap );

		//Invoke this to maintain some control over the environment 
		var ctx = new std.components.ctx();
		setContext( ctx );

		//Invoke this to prepare the body and get ready to do something with it
		var res = new std.components.response(); 
		setResponse( res );

		//Invoke this to load error handling
		var error = new std.components.error( res, this );
		setPageError( error );

		//Load the data component 
		var appdata = loadAppDataComponent();
		if ( !appdata.status )
			return this.respondWith( 500, appdata );
		else {
			appdata = appdata.results;
			setAppData( appdata );
		}

		//Serve static pages first and abort
		if ( Len( pageParts ) > 2 && pageParts[1] == "assets" )
			return serveStaticResource( pageParts );
		else if ( Len( pageParts ) == 2 && pageParts[1] == "favicon.ico" ) {
			//Default choice?
			var favicon_path = "favicon.ico";
			if ( StructKeyExists( appdata, "favicon" ) ) {
				//Get the type
				var type = getType( appdata.favicon );
				if ( type.type == "string" )
					favicon_path = type.value;
				else if ( type.type == "closure" ) {
					//Generate the thing by running the function
					var favicon_data = type.value( this );
					//return this.respondWith( 200, ... );
					return this.respondWith( 500, failure( "Favicon by closure not supported yet." ) );	
				}
				else {
					return this.respondWith( 500, failure( "Invalid favicon format." ) );	
				}
			}

			return serveStaticResource( pageParts, favicon_path );
		}

		//Invoke this to load data.cfc. (TODO: Run depending on config settings)
		//Is being able to choose even necessary...?
		//var data = new data(); 
		//setApplicationData( data );
		
		//include data.cfm?
		//Now I can just run regular stuff

		//Load all of the components here /*!appdata.bypassComponents && */
		if ( !( ctx.components = loadComponents( this )).status ) {
			return this.respondWith( 500, ctx.components );
		}
		else {
			ctx.components = ctx.components.results;
		}

		//This ought to return a machine code friendly struct with route eval data
		if ( !StructKeyExists( appdata, "routes" ) ) 
			return this.respondWith( 500, failure( "No routes specified." ) );
		else {
			var rtable; 
			var r;
			//Route injection happens here.
			if ( !( r = appendIndependentRoutes( appdata ) ).status )
				return this.respondWith( 500, r );
			else {
				StructAppend( appdata.routes, r.results ); 
			}
			
			//This can probably fail, but I can't think of how...
			if ( !( rtable = evaluateRoutingTable( appdata.routes, {} ) ).status ) {
				return this.respondWith( 500, failure( rtable.message ) );
			}

			//Get the mapped route (handle sending back here) 
			if ( !(ctx.route = evaluateRouteData( appdata )).status && StructKeyExists( ctx.route, "exception" ) )
			//if ( !ctx.route.status && StructKeyExists( ctx.route, "exception" ) )
				return this.respondWith( 500, ctx.route );
			else if ( !ctx.route.status && ctx.route.type == 400 )
				return this.respondWith( 400, ctx.route );
			else if ( !ctx.route.status && ctx.route.type == 404 )
				return this.respondWith( 404, ctx.route );
			else {
				ctx.setRoute( ctx.route );
			}
		}

		//The scope should carry things over...
		//if ( !( tmp = evaluatemaking something customers want. The only way to make something customers want is to get a prototype in front of them and refine it based on their reactions.ScopeKey( ctx.route ) ).status )
		//return this.respondWith( ???, ??? );
			 
		//returns
		if ( ( ctx.returns = evaluateReturnsKey( ctx.route, appdata ) ).status )
			res.setContentType( ctx.returns.results );
		else {
			return this.respondWith( 500, ctx.returns );
		}

		//before
		//If this does not exist, move on, if it fails, stop, if it succeeds, add to ctx 
		if ( ( ctx.before = evaluateBeforeKey( ctx.route ) ).status )
			ctx.before = this.extractResults( ctx.before );
		else {
			return this.respondWith( 500, ctx.before );
		}

		//method not accepted, or some other expectation failed... 
		if ( !(ctx.accepts = evaluateAcceptsKey( ctx.route )).status ) {
			return this.respondWith( 405, ctx.accepts );
		}

		//expected certain variables that we didn't get
		if ( !(ctx.expects = evaluateExpectsKey( ctx.route ) ).status ) {
			return this.respondWith( 400, ctx.expects );
		}

		/*
		//If the query was successful, a response should be sent here.
		if ( !(ctx.query = evaluateQueryKey( ctx.route ) ).status )
			return this.respondWith( 500, ctx.query );
		else if ( StructKeyExists( ctx.query, "results" ) ) {
			ctx.query = this.extractResults( ctx.query );
			return this.respondWith( 200, ctx.query );
		}
		*/
	
		//Check the model
		if ( !(ctx.model = evaluateModelKey( ctx.route )).status )
			return this.respondWith( 500, ctx.model );
		else if ( StructKeyExists( ctx.model, "results" ) ) {
			//ctx.model = this.extractResults( ctx.model );
			setModel( ctx.model.results );
		}

		//return this.respondWith( 200, ctx.view );
		//Filter: Optional for now, but will extract certain keys
		//if ( !(ctx.filter = evaluateFilterKey( ctx.route )).status )
		//	this.respondWith( 500, error.render( ctx.filter ) );
		//View interpretation can fail
		if ( !(ctx.view = evaluateViewKey( ctx.route, ctx.model )).status )
			return this.respondWith( 500, ctx.view );
		else if ( ctx.view.status && StructKeyExists( ctx.view, "results" ) )
			return this.respondWith( 200, ctx.view );
		else { //if ( !StructIsEmpty( ctx.model ) ) {
			//No view, and this is supposed to be the case
			//after
			//evaluateAfterKey( ctx );
			//httpstatus - needs to check for number of children, if it's just one, then something
			if ( StructKeyExists( ctx.model, "results" ) )
				return this.respondWith( 200, ctx.model );
			else if ( StructKeyExists( ctx.model, "httpstatus" ) )
				return this.respondWith( 500, { status=false, message="so much failure." } );
			else {
				return this.respondWith( 400, { 
					error = "No resource for #ctx.route.name# found.",
					status = false,
					exception = {}
				});
			}
		}

		//There is absolutely no reason to end up here.  Ever.
		return this;
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
	public struct function validate ( cStruct, vStruct ) {
		var s = { status=true, message="", results=StructNew() };

		//Loop through each value in v
		for ( var key in vStruct ) {
			//Short names
			var ck;
			var tt;
			var vk = vStruct[ key ];

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
					if ( StructKeyExists( vk, "type" ) && ( !(t = getType(vk.ifNone)).status || t.type neq vk.type ) ) {
						return { status = false, message = "type does not match.", results = {} };
					//return failure( "type of value received at key '#key#' is not #vk.type#." );
					}
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
				if ( ( file = upload_file( ck, acceptedMimes ) ).status ) {
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
		var fakeUa = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36";
		var apiHeaders = {};

		try {
			//Create a new request object
			var http = new http( method=UCase(method), charset="utf-8", url=arguments.apiUrl );
			http.setUserAgent( fakeUa );

			//Add appropriate headers
			if ( StructKeyExists( headers, "Content-Type" ) ) 
				http.addParam( type="header", name="Content-Type", value=headers["Content-Type"] );
			else if ( method eq "POST" || method eq "PUT" )
				http.addParam( type="header", name="Content-Type", value="application/x-www-form-urlencoded" );
			else if ( arguments.method eq "multipart" ) {
				http.addParam( type="header", name="Content-Type", value="multipart/form-data" );
			}

			//Add the headers
			if ( StructKeyExists( arguments, "headers" ) ) {
				for ( var k in arguments.headers ) {
					http.addParam( type="header", name=k, value=headers[k] );
				}
			}

			//Add the body fields
			if ( StructKeyExists( arguments, "payload" ) ) {
				//check between get and post (or pull them)
				for ( var k in payload ) {
					//TODO: if payload is a one-level deep struct, then don't worry about looping
					//if it's deeper, then loop through each and continue adding the fields, but you have to 
					//make sure that one is part of the body and the other is part of the url
					http.addParam( type="formfield", name=LCase( k ), value=payload[k] );
				}
			}

			var h = http.send();
			var p = h.getPrefix();
		}
		catch (any e) {
			return failure( "Failure to perform HTTP '#method#' on URL '#apiURL#'", e );
		}

		//When this returns, I want to see the content in my window
		return {
			status = true
		, message = "Successfully performed HTTP #method# on URL '#apiURL#'" 
		, results = p.fileContent 
		, extra = p
		};
	}


	//Handles rendering error messages according to the type of content
	public string function render( struct content ) {
		if ( this.getResponse().getContentType() == "application/json" ) {
			return this.structToJSON( content.results ); 
		}
		else if ( this.getResponse().getContentType() == "text/xml" )
			return SerializeXML( content.results ); 
		else {
			return content.results;
		}
	}



	//Return a message
	public boolean function respondWith( numeric status = 200, struct con ) {
		//A String buffer goes here... not sure how fast this is...
		var contentBuffer;
		var httpstatus; 

		if ( StructKeyExists( con, "httpstatus" ) )
			httpstatus = con.httpstatus;
		else if ( StructKeyExists( con, "results" ) && IsStruct( con.results ) )
			httpstatus = StructKeyExists( con.results, "httpstatus" ) ? con.results.httpstatus :status;
		else {
			httpstatus = status;
		}

		//If status is invalid, return a failure
		if ( httpstatus < 100 || httpstatus > 599 )
			contentBuffer = "Attempted to return invalid code #status#";
		else if ( StructKeyExists( con, "status" ) && !con.status ) {
			var error = getPageError();
			error.setStatus( httpstatus );
			error.setStatusMessage( getHttpHeaders()[ httpstatus ] );
			contentBuffer = error.render( con ); 
		}
		else {
			contentBuffer = this.render( con );
		}

		this.sendResponse( httpstatus, getResponse().getContentType(), contentBuffer );
		return true;
	} 

	/**
	 * init()
	 *
	 * Create a new instance of Myst.  
	 *
	 * TODO: This should only happen once in Application.cfc (preferably)
	 */
/*
	public Myst function init ( Struct globals ) {
		//Define things
		var appdata;
		//this.href = this.link;
	
		//TODO: Initialize common elements ONCE
		setHttpHeaders( createObject( "component", "std.components.httpHeaders" ).init() );
		setMimetypes( createObject( "component", "std.components.mimes" ).init() );
		setCommonExtensionsToMimetypes( createObject( "component", "std.components.files" ).init() );
		setRunId( randstr(32) );

		//....
		//var rootDir = getDirectoryFromPath(getCurrentTemplatePath());
		//var currentDir = getDirectoryFromPath(getCurrentTemplatePath());
		var constantMap = {}; 
		setRootDir( getDirectoryFromPath(getCurrentTemplatePath()) );
		setArrayConstantMap( [ "app", "assets", "db", "files", "routes", "sql", "std", "views" ] );
		setPathSep( ( server.os.name eq "Windows" ) ? "\" : "/" );
		for ( var k in getArrayConstantMap() ) constantMap[ k ] = getRootDir() & k;
		setConstantMap( constantMap );

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
			//this.withResponse( 500, "Deserializing data.cfm failed", e );
			abort;
		}

		//Check that JSON manifest contains everything necessary.
		for ( var key in [ "base", "routes" ] ) {
			if ( !StructKeyExists( appdata, key  ) ) {
				renderPage( 500, "Struct key '"& key &"' not found in data.cfm.", {} );
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
*/

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
	//Make a variable global, so that it can be accessed somewhere else
	public void function setGlobal( v ) {
		
	}
}

