/* --------------------------------------------------
myst.cfc
========

@author
Antonio R. Collins II (ramar@collinsdesign.net)

@copyright
Copyright 2016 - Present, Tubular Modular Inc dba Collins Design
Original Author Date: Tue Jul 26 07:26:29 2016 -0400

@summary
An MVC framework for CFML pages.

@more
Generate a page through the page generation cycle.

With this new system in place, some things have higher precedence...
'before' is always first
'accepts', 'expects', and possibly 'scope' really should be run...
'query' should come before model (if implemented)
'model' ought to be next
'returns' does little good right now..., models can be done..., I suppose
'view(s)' next
'after' should always be final 

@usage
Use the command line to deploy this file and its
associated components to a new directory.

@changelog
See changelog.txt

 * -------------------------------------------------- */
component accessors="true" {

	/* ALL OF THESE WILL MOVE, BUT WHERE DO WE PUT THEM? */
	//Relative path maps for framework directories
	property name="urlBase" type="string" default="/"; 

	//property name="logString" type="struct";
	property name="logStyle" type="string" default="standard"; //combined, common,
	property name="logType" type="string" default="file";
	property name="logFile" type="string" default="log/log.txt";
	property name="logFormatCommon" type="string" default="";
	property name="logFormatCombined" type="string" default="";
	property name="logFormat" type="string" default="log/log.txt";
	property name="runId" type="string" default="";

	//Text to serve when encountering a 404
	property name="contentOn404" type="string" default="File not found."; 

	//Text to serve when encountering a 410
	property name="contentOn410" type="string" default="Authentication denied."; 

	//Content to serve when encountering a 500 
	property name="contentOn500" type="string" default="Error occurred."; 

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
	property name="defaultContentType" type="string" default="text/html";



	/* Public properties start here */
	//The datasource that will be used during the life of the app.
	property name="datasource" type="string";

	//Control debugging
	property name="debug" type="boolean" default="false";

	//Extra components to load
	property name="extra" type="list" default="html,http,query,session";

	//Methods that myst should expect to work with (all by default)
	property name="methods" type="list" default="HEAD,GET,POST,PUT,PATCH,DELETE";

	//Keys to expect in routing table. TODO: Deprecate routingKeys and replace with this...
	property name="routingActions" type="list" default="accepts,expects,returns,model,view";
	//	default="accepts,after,before,expects,filter,inherit,returns";

	//Keys to expect in routing table.
	property name="routingKeys" type="string" default="before,after,accepts,expects,filter,returns,namespace";
	//	default="before,after,accepts,expects,filter,returns,inherit";

	//The model struct
	property name="model" type="struct";

	//Sessions
	property name="session" type="object";
	/* END */


	/* Private properties start here */

	//The 'manifest' value that is loaded at the beginning of starting a Myst app
	property name="appdata" type="object";

	//TODO: This shouldn't be needed anymore... Deprecate ASAP
	property name="index" type="string" default="_";

	//Base components to load
	property name="base" type="list" default="ctx,error,evaluate,file,headers,log,mime,response,rand" setter="false";

	//Track the current context for use elsewhere
	property name="context" type="object";

	//Relative path maps for framework directories
	property name="constantMap" type="list" default="app,assets,db,files,routes,sql,std,views" setter="false"; 

	//Set all http headers once at the top or something...
	property name="httpHeaders" type="struct" setter="false";

	//Choose a path seperator depending on system.
	property name="pathSep" type="string" default="/" setter="false";

	//The root directory
	property name="rootDir" type="string" setter="false";

	//Set the routes for use elsewhere.
	property name="routes" type="object";

	//
	property name="selectedContentType" type="string" default="text/html"; 
	/* END */

	
	/**
	 * Get the full path of a particular directory within our web root
	 *
	 * @param key        ...
	 */
	private function getConst( required string key ) {
		return ( ListFind( getConstantMap(), key ) ) ? "#getRootDir()##key#" : "";
	}


	/**
	 * Handles file uploads argument.
	 *
	 * @param formfield
	 * @param mimetype
	 */	
	public struct function upload_file ( string formField, string mimetype ) {
		//Create a file name on the fly.
		var a;
		var fp = ToString( Left( getConst( "files" ), Len(getConst("files") - 1 ) ) );
		//fp = ToString( Left(fp, Len(fp) - 1) ); 
		
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
			return failure( "File upload type error.", e ); 
		}
		catch ( any e ) {
			return failure( "File upload error.", e ); 
		}
		
		return a;
		/*
		return {
			status =true
		, results = a
		}
		*/
	}


	/** 
	 * Get the type of a value.
	 * 
	 * @param scheck       check
	 */
	public struct function getType ( required sCheck ) {
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
	 * A wrapper around cfinclude to work with the framework's structure.
	 * TODO: This will soon be removed.
	 *
	 * @param where     The type of asset to include.
	 * @param name      The name of the asset to include.
 	 */
	public function _include (required string where, required string name) {
		//log.report( "Running _include on path #where#/#name#" );

		//Return a status of false and a full message if the file was not found.
		if ( getConst( where ) eq "" )
			return failure( "Requested inclusion of a file not in the web directory." );

		//Set ref here, I'm not sure about scope.
		var ref = ToString( where & getPathsep() & name & ".cfm" );
		
		//Wrap and return included content
		try {
			savecontent variable="content" { include ref; }
		}
		catch (any e) {
			return failure( "Myst caught a '#e.type#' exception when trying to include file #ref#", e );
		}

		return {
			status = true
		, ref = ref 
		, results = content 
		}
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

	public String function queryToXML ( Query arg ) {

	}

	public String function structToXML ( Struct arg ) {

	}

	/**
   * ...
	 *
	 * @param model          ....
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



	/**
	 * Return a formatted string dependent on the content-type.
   * TODO: Convert from some reusable closure instead of this...
	 *
	 * @param c
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
   * ...
	 *
	 * @param message           ...
	 * @param results           ...
	 **/		
	public struct function lfailure( required numeric status, required string message, struct exception ) {
		return {
			status = false
		, error = message
		, httpstatus = status
		, exception = StructKeyExists( arguments, "exception" ) ? exception : {}
		};
	}


	/**
   * ...
	 *
	 * @param message           ...
	 * @param results           ...
	 **/		
	public struct function failure( required string message, struct exception ) {
		return lfailure(
		  message = message
		, status = 500
		, exception = StructKeyExists( arguments, "exception" ) ? exception : {}
		);
	}

	
	/**
   * ...
	 *
	 * @param message           ...
	 * @param results           ...
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
   * ...
	 *
	 * @param message           ...
	 * @param results           ...
	 **/		
	public struct function success( required string message, results ) {
		return lsuccess(
		  message = message
		, status = 200
		, results = StructKeyExists( arguments, "results" ) ? results : {}
		);
	}


	/**
   * Execute a closure and wrap any errors appropriately
	 *
	 * @param funct             ...
	 * @param model             ...
	 **/		
	private any function evaluateClosure( required funct, struct model ) {
		var results;
		try {
			results = funct( this, StructKeyExists( arguments, "model") ? model : {} );
		}
		catch (any e) {
			return lfailure( 500, "Error executing closure.", e );
		}
		return {
			status = true
		, results = results
		}
	}


	/**
   * Return a struct composed of elements and keys...
	 *
	 * @param routedata             ...
	 **/		
	private struct function model( required struct routedata ) {
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

		getContext().setModel( result );
		return {
			status = true,
			results = result
		}
	}


	/**
	 * Evaluate a view.
	 *
	 * @param routedata             ....
	 * @param modeldata      ....
	 */
	private struct function view( required struct routedata, struct modeldata ) {
		//log.report( "Evaluating views..." );
		//Evaluate a single view
		var content;
		try {
			savecontent variable="content" {
				//Get the type name
				var ev = getType( routedata.view );
				
				//Custom message is needed here somewhere...
				if ( ev.type != "string" && ev.type != "array" )
					return lfailure( 500, "View value for '#routedata.file#' was not a string or array." );

				//Set pageArray if it's string or array
				var pageArray = (ev.type == 'string') ? [ ev.value ] : ev.value;
				var cs;
			
				//Now load each model, should probably put these in a scope
				for ( var x in pageArray ) {
					x = FindNoCase( "@", x ) ? Replace( x, "@", routedata.file ) : x;
					if ( !( cs = _include( where="views", name=x ) ).status ) {
						return cs;
					}
					writeoutput( cs.results );
				}
			}
		}
		catch (any e) {
			return lfailure( 500, "Error in parsing view for '#routedata.file#'.", e );
		}

		getContext().setView( content );
		return {
			status = true
		,	results = content
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
	 * Load compnents
	 *
	 * @param appdata       ....
	 */
	private Struct function loadComponents( struct appdata ) {
		//Load all the components should have been loaded...
		//log.report( "Loading components..." );

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
				//log.report( "Loading component '#q.name#'..." );
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
				}
				//log.report("Successfully loaded component #q.name#!");
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
	 * Adds routes in routes/ and routes/overrides/ folders to the route map. 
	 *
	 * @param data          ....
	 * @param data          ....
	 */
	private Struct function appendIndependentRoutes ( data, ctx ) {
		//log.report("Loading independent routes...");

		try {
			//Add more to logging
			var dirQuery = DirectoryList( "routes", false, "query", "*.cfc" );
			var callstat = 0;
			var routes = {};
			var ctxc = GetComponents();

			//Check for 
			for ( var q in dirQuery ) {
				if ( q.name neq "Application.cfc" && q.name neq "base.cfc" ) {
					var cmp;
					var name = Replace( q.name, ".cfc", "" );
					if ( StructKeyExists( ctxc, name ) && !ctxc[name].getRoutesEnabled() )
						;
					else if ( FileExists( "#getRootdir()#/routes/overrides/#q.name#" ) )
						cmp = createObject( "routes.overrides.#name#" ).init( this );
					else {
						cmp = createObject( "routes.#name#" ).init( this );
					}
					StructAppend( routes, cmp ); 
				}
			}
			//log.report("SUCCESS - All routes loaded!");
			return { 
				status = true
			, results = routes 
			};
		}
		catch (any e) {
			return failure( message="Route injection failed.", exception=e );
		}
		return { 
			status = true
		, results = {} 
		};
	}


	private array function extractKeys( struct str ) {
		var arr = [];
		for ( var k in str ) {
			ArrayAppend( arr, k );
		}
		return arr;
	}


	/**
	 * Transform the routing table.
	 * 
	 * @param arg       ...
	 * @param found     ...
	 * @param key       ...
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
					//If the type is a struct, we need to evaluate again
					if ( getType( arg[ vv ] ).type eq 'struct' ) {
						//return arg and replacing that key ought to work best
						var y = evaluateRoutingTable( arg[ vv ], nStruct, vv );
						if ( y.status )
							arg[ vv ] = y.results;
						else {
							return failure( "Router inheritance failed." );
						}
					}
				}
			}
		}
		catch (any e) {
			return failure( "Unknown exception occurred at routing table evaluation.", e );
		}

		return {
			status = true
		, results = arg
		}
	}


	/**
	 * Figure out which route is actually being called.
	 * 
	 * @param arg       ...
	 * @param found     ...
	 * @param key       ...
	 **/
	private struct function evaluateRouteData( required struct data ) {
		var base = "default";
		var localName;
		var path;
		var parent;
		var file;
		var depth = 0;
		var routes = getRoutes();

		//Add more to logging
		//log.report( "Evaluating URL route..." );

		//Check for SES path
		var ses_path = cgi.script_name;

		//Handle situations where no routes are defined.
		if ( StructIsEmpty( routes ) )
			return failure( "Routes are not defined in data.cfm" ); 

		//Modify model and view include paths if there is a basedir present.
		if ( data.getBase() neq "" ) {
			if ( Len( data.getBase() ) > 1 )
				base = data.getbase();	
			else if ( Len( data.getbase() ) == 1 && data.getbase() == "/" )
				base = "/";
			else {
				base = data.getbase();	
			}
			//Simply lop the basedir off of the requested URL if that was requested
			localName = Replace( ses_path, base, "" );
		}

		//Handle requests for the home page 
		if ( localName == getIndex() || localName == "#getIndex()#.cfm" ) {
			if ( !StructKeyExists( routes, "index" ) && !StructKeyExists( routes, "default" ) )
				return failure( "No default route specified in data.cfm" );
			else {
				//return rl.routes.default;
				var tt = StructKeyExists( routes, "index" ) ? routes.index : routes.default;
				tt.file = "index.cfm";
				tt.path = "/";	
				tt.status = true;
				tt.name = Replace( cgi.script_name, ".cfm", "" );
				return tt;
			}
		}

		//Get ready to start moving through and writing a matcher (there should be only one)
		var route = routes;
		var paths = ArraySlice( ListToArray( localName, "/" ), -1, 1 );
		var parts = [];

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
					return failure( "Error in router handling, check route defined at '#re#'", e );
				}

				if ( !reMatched ) {
					/*
					return {
						status = false 
					, error = (is404) ? "No mapping for '#filepath#' found." :
							"Parameter did not match regex at #re#"
					, type = (is404) ? 404 : 400 
					, path = path
					, file = filepath
					};
					*/
					var status = (is404) ? 404 : 400;
					var emsg = (is404) ? "No mapping for '#filepath#' found." :
							"Parameter did not match regex at #re#"
					return lfailure( status, emsg );
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
		return route;	
	}


	/**
	 * Return a key-value set of scopes by accepted name.
	 *
	 * @param list      A string of a list of scopes to return/'*' for all
	 **/
	private struct function scopes( required string scopes ) {
		var t = {};
		var scopeMap = {
			"HEAD" = {} 
		,	"GET" = url
		,	"POST" = form
		,	"PUT" = form
		,	"PATCH" = form
		,	"DELETE" = url 
		,	"OPTIONS" = {} 
		,	"TRACE" = {} 
		}
	
		for ( var v in ListToArray( scopes ) ) {
			if ( StructKeyExists( scopeMap, v ) ) {
				t[ v ] = scopeMap[ v ];	
			}
		}

		return t;
	}


	/**
	 * Figure out the content-type of the route to be served.
	 * 
	 * @param routedata     ...
	 * @param appdata       ...
	 **/
	private struct function returns( struct routedata, struct appdata ) {
		var r;
		var k;
		//log.report( "Evaluating key 'returns' @ /#routedata.name#..." );

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
				status = true
			,	results = getDefaultContentType()
			}
		}

		if ( getType( r ).type neq "string" ) {
			return failure( "Key 'returns' at #k# is not a string." );
		}

		if ( !StructKeyExists( mime.mimes(), routedata.returns ) ) {
			return failure( "Key 'returns' points to unsupported mimetype '#routedata.returns#' at #routedata.name#." );
		}

		getContext().setReturns( routedata.returns );
		return {
			status = true
		,	results = routedata.returns
		}
	}


	/**
	 * Checks the method received at a particular endpoint
	 * 
	 * @param routedata      ...  
	 **/
	private struct function accepts( required struct routedata ) {
		if ( getType( routedata.accepts ).type neq "string" )
			return lfailure( 500, "Key 'accepts' at [routes.#routedata.path#] must point to a string or list." );
		else if ( ListFind( routedata.accepts, UCase( cgi.request_method ) ) == 0 ) {
			return lfailure( 405, "This endpoint does not accept method '#cgi.request_method#'" );
		}
		getContext().setAccepts( routedata.accepts );
		return { 
			status = true
		, results = getContext().getAccepts()
		}
	}


	/**
	 * Checks the values received from a client within a particular scope ..
	 * 
	 * @param routedata      ...
	 **/
	private struct function expects( required struct routedata ) {
		//log.report( "Evaluating key 'expects' @ /#data.page#..." );
		var ctx = getContext();
		var supported = ctx.getAccepts() neq "" ? ctx.getAccepts() : getMethods();
		var values = {};
		
		//expects should only be a string/list or a struct
		if ( gettype( routedata.expects ).type neq "string" )
			return lfailure( 500, "Incorrect type of value received at key 'expects' at [routes.#routedata.path#]" );

		//for each value, check all of the available scopes for a match
		var scopeMap = scopes( supported );
		for ( var method in scopeMap ) {
			for ( var v in ListToArray( routedata.expects ) ) {
				if ( StructKeyExists( scopeMap[ method ], v ) ) {
					values[ v ] = true;	
				}	
			} 
		}

		if ( StructCount( values ) < Len( ListToArray( routedata.expects ) ) ) {
			return lfailure( 412, "Endpoint '#routedata.name#' expected variables it did not receive." );
		}

		getContext().setExpects( routedata.expects );
		return {
			status = true
		}
	}


	/**
	 * Evaluates a closure or page for use before the evaluation models and views in a route.
	 * TODO: Unfinished at the moment.
	 * 
	 * @param routedata      ...
	 **/
	private struct function before( required struct routedata ) {
		//log.report( "Evaluating key '#key#' at /#routedata.page#..." );
		//Evaluate any models, etc
		if ( StructKeyExists( routedata.before, "model" ) ) {
			0;//evalModel( routedata.before.model, scope );
		}
		//Evaluate any views, this should probably just be a string
		if ( StructKeyExists( routedata.before, "view" ) ) {
			0;//evalView( routedata.before.view, scope );
		}
		//Get the type of routedata.before
		//getContext().setBefore( routedata.before );
		//log.report( "SUCCESS!" );
		return { status = true };
	}


	/**
	 * Use the query as a model. 
	 * TODO: Unfinished at the moment.
	 * 
	 * @param routedata      ...
	 **/
	private struct function query( required struct routedata ) {
		//getContext().setModel( name, routedata.query );
		return { status = true };	
	}


	/**
	 * Evaluates a closure or page for use after the evaluation models and views in a route.
	 * TODO: Unfinished at the moment.
	 * 
	 * @param routedata      ...
	 **/
	private function after( struct routedata ) {
		//log.report( "Evaluating key 'after' @ #routedata.name#..." );
		//writedump( t );
		//log.report( "SUCCESS!" );
		return { status = true }
	}


	/**
	 * Serve a static resource.
	 *
	 * @params parts
	 * @params path
	 * @params err
	 **/
	public function serveStaticResource( required array parts, string path, string err ) {
		var spath;
		var metadata;
		var extension;
		var mimetype;
		var a = arguments;

		try {
			//Get the part of URL that we want and generate the path of the requested file.
			spath = StructKeyExists( a, "path" ) ? a.path : ArrayToList( ArraySlice( parts, -1, 1 ), "/" );
			/*
			if ( StructKeyExists( arguments, "path" ) )
				spath = arguments.path;
			else {
				//Get the part of URL that we want and generate the path of the requested file.
				spath = ArrayToList( ArraySlice( parts, -1, 1 ), "/" );
			}
			*/

			//If the file does not exist, send a 404
				//var str = StructKeyExists( a, "err" ) ? a.err : "Error 404: File '#spath#' not found";
			if ( !FileExists( spath ) )
				return sendResponse( 404, "text/html", StructKeyExists( a, "err" ) ? a.err : "Error 404: File '#spath#' not found" );

			//If you have problems accessing it, send a 403
			//if ( !metadata.canRead ) {
			if ( !( metadata = GetFileInfo( spath ) ).canRead )
				return this.sendResponse( 403, "text/html", "Error: Access Forbidden" );	

			if ( ( extension = GetExtension( spath ) ) eq "" || !StructKeyExists( getCommonExtensionsToMimeTypes(), extension ) )
				mimetype = "application/octet-stream"; 
			else {
				mimetype = getCommonExtensionsToMimetypes()[ extension ];
			}
			/*
			if ( extension eq "" || !StructKeyExists( getCommonExtensionsToMimeTypes(), extension ) )
				mimetype = "application/octet-stream"; 
			else {
				mimetype = getCommonExtensionsToMimetypes()[ extension ];
			}
			*/

			//If the file exists, throw it back
			return response.sendBinary( 200, mimetype, metadata.size, FileReadBinary( spath ) );  
		}
		catch (any e) {
			return this.respondWith( 500, {
				error = "unknown error",
				exception = e,
				status = false
			});
		}
	}


	/**
	 * Load the appdata.
	 **/
	private struct function loadAppData() {
		//log.report( "Loading data.cfm..." );
		try {
			return {
				status = true
			, results = createObject( "data" ).init( this )
			}
		}
		catch ( any e ) {
			return failure( "Deserializing data.cfm failed", e );
		}
	}


	/**
	 * Check a struct for certain values by comparison against another struct
	 * 
	 * @param cstruct     ...
	 * @param vstruct     ...
	 **/
	public struct function validate ( required struct cstruct, required struct vstruct ) {
		//Loop through each value in v
		var results = {};
		for ( var key in vstruct ) {
			var vk = vstruct[ key ];
			var ck = StructKeyExists( cstruct, key ) ? cstruct[ key ] : {};

			//If key is required, and not there, stop
			if ( StructKeyExists( vk, "req" ) && ( vk.req eq true ) && StructIsEmpty( ck ) )
				return failure( "Required key #key# does not exist." );

			//No use moving forward if the key does not exist...
			if ( StructIsEmpty( ck ) && StructKeyExists( vk, "ifNone" ) ) {
				var t = getType( vk.ifNone ); 
				if ( StructKeyExists( vk, "type" ) && ( t.status || t.type neq vk.type ) ) {
					return failure( "type of value received at key '#key#' is not #vk.type#." );
				}
				results[ key ] = vk.ifNone;	
				continue;
			}
 
			if ( StructKeyExists( vk, "lt" ) && !( ck lt vk.lt ) )
				return failure( "Value of key '##' fails -lt (less than) test." );

			if ( StructKeyExists( vk, "gt" ) && !( ck gt vk.gt ) )
				return failure( "Value of key '%s' fails -gt (greater than) test." );

			if ( StructKeyExists( vk, "lte" ) && !( ck lte vk.lte ) )
				return failure( "Value of key '%s' fails -lte (less than or equal to) test." );

			if ( StructKeyExists( vk, "gte" ) && !( ck gte vk.gte ) )
				return failure( "Value of key '%s' fails -gte (greater than or equal to) test." );
	 
			if ( StructKeyExists( vk, "eq" ) && !( ck eq vk.eq ) )
				return failure( "Value of key '%s' fails -eq (equal to) test." );
	 
			if ( StructKeyExists( vk, "neq" ) && !( ck neq vk.neq ) )
				return failure( "Value of key '%s' fails -neq (not equal to) test." );

			results[ key ] = ck;

			//Check file fields
			if ( StructKeyExists( vk, "file" ) ) {
				//For ease, I've added some "meta" types (image, audio, video, document)
				var meta_mime  = {
					image = "image/jpg,image/jpeg,image/pjpeg,image/png,image/bmp,image/gif",
					audio = "audio/mp3,audio/wav,audio/ogg",
					video = "",
					document = "application/pdf,application/word,application/docx"
				};

				var meta_ext   = {
					image = "jpg,jpeg,png,gif,bmp",
					audio = "mp3,wav,ogg",
					video = "webm,flv,mp4,",
					document = "pdf,doc,docx"
				};	

				//Most exclusive, just support certain mime types
				var file;
				var acceptedMimes = "*";
				var acceptedExt = 0;
				if ( StructKeyExists( vk, "mimes" ) )
					acceptedMimes = vk.mimes;
				else if ( StructKeyExists( vk, "ext" ) )
					acceptedExt = vk.ext;
				else {
					acceptedMimes = StructKeyExists( meta_mime, vk.type ) ? meta_mime[ vk.type ] : "*";
					acceptedExt = StructKeyExists( meta_ext, vk.type ) ? meta_ext[ vk.type ] : 0;
				}
			
				//Upload the file
				if ( ( file = upload_file( ck, acceptedMimes ) ).status ) {
					//Check extensions if acceptedMimes is not a wildcard
					if ( acceptedExt neq 0 ) {
						if ( !listFindNoCase( acceptedExt, file.results.serverFileExt ) ) {
							//Remove the file
							FileDelete( file.results.fullpath );
							return failure( "The extension of the submitted file '%s'" & 
								"does notmatch the expected mimetype for this field." );
						}
					} 

					//Check expected limits ( you can even block stuff from a value in data.cfm )
					if ( StructKeyExists( vk, "sizeLt" ) && !( file.results.oldfilesize lt vk.sizeLt ) ) {
						FileDelete( file.results.fullpath );
						return failure( "Size of field '##' (## bytes) is larger than expected size ## bytes." );
					} 

					if ( StructKeyExists( vk, "sizeGt" ) && !( file.results.oldfilesize gt vk.sizeGt ) ) {
						FileDelete( file.results.fullpath );
						return failure( "Size of field '##' (## bytes) is smaller than expected size ## bytes." );
					} 
				}
				results[ key ] = file.results; 
			}
		}
		return {
			status = true
		, results = results
		};
	}


	/**
	 * Handles rendering error messages according to the type of content
	 *
	 * @param content        Content to push
	 **/
	public string function render( required struct content ) {
		if ( this.getResponse().getContentType() == "application/json" ) {
			return this.structToJSON( content.results ); 
		}
		else if ( this.getResponse().getContentType() == "text/xml" )
			return SerializeXML( content.results ); 
		else {
			return content.results;
		}
	}


	/**
	 * Return a message
	 *
	 * @param status         Status to throw with
	 * @param con            ...
	 **/
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
			error.setStatus( httpstatus );
			error.setStatusMessage( headers[ httpstatus ] );
			contentBuffer = error.render( con ); 
		}
		else {
			contentBuffer = this.render( con );
		}

		response.send( httpstatus, response.getContentType(), contentBuffer );
		return true;
	}

 
	/**
	 * Generates a context based on a request.  Returns a response.
	 *
	 * @param page         The name of the page requested.
	 **/
	function init ( string page ) {
		//Invoke all components
		for ( var f in ListToArray( "#getBase()#,#getExtra()#" ) ) {
			variables[ f ] = createobject( "std.components.#f#" ).init( this ); 
		}

		//Some other things need to be set, but there must be a way around this...
		var tmpctx;
		variables.rootdir = getDirectoryFromPath( getCurrentTemplatePath() );
		variables.runId = rand.string(32);
		variables.pathSep = ( server.os.name eq "Windows" ) ? "\" : "/";
		//setCommonExtensionsToMimetypes( new std.components.mime().getFiletypeMap() );
		
		//TODO: appdata should not be global, and should be on a seperate line
		//var appdata = loadAppdata();
		if ( !( variables.appdata = loadAppdata() ).status )
			return this.respondWith( 500, appdata );
		else {
			variables.appdata = variables.appdata.results;
			setAppData( variables.appdata );
			setContext( ctx );
		}

		//Serve static pages first and abort
		var pageParts = ListToArray( page, "/" );
		if ( Len( pageParts ) > 2 && pageParts[1] == "assets" )
			return serveStaticResource( pageParts );
		else if ( Len( pageParts ) == 2 && pageParts[1] == "favicon.ico" ) {
			//Default choice?
			var favicon_path = "favicon.ico";
			if ( StructKeyExists( variables.appdata, "favicon" ) ) {
				//Get the type
				var type = getType( variables.appdata.favicon );
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

		//Load all of the components here
		if ( !( variables.components = loadComponents( this )).status )
			return this.respondWith( 500, variables.components );
		else {
			variables.components = variables.components.results;
		}

		//This ought to return a machine code friendly struct with route eval data
		variables.routes = variables.appdata.getRoutes();
		if ( StructIsEmpty( variables.routes ) ) 
			return this.respondWith( 500, failure( "No routes specified." ) );
		else {
			var rtable; 
			var r;
			//Route injection happens here.
			if ( !( r = appendIndependentRoutes( variables.appdata, ctx ) ).status )
				return this.respondWith( 500, r );
			else {
				StructAppend( variables.routes, r.results ); 
			}
			
			//This can probably fail, but I can't think of how...
			if ( !( rtable = evaluateRoutingTable( variables.routes, {} ) ).status )
				return this.respondWith( 500, failure( rtable.message ) );

			//Get the mapped route (handle sending back here) 
			//if ( !ctx.route.status && StructKeyExists( ctx.route, "exception" ) )
			if ( !(ctx.route = evaluateRouteData( variables.appdata )).status && StructKeyExists( ctx.route, "exception" ) )
				return this.respondWith( 500, ctx.route );
			else if ( !ctx.route.status && ctx.route.type == 400 )
				return this.respondWith( 400, ctx.route );
			else if ( !ctx.route.status && ctx.route.type == 404 )
				return this.respondWith( 404, ctx.route );
			else {
				ctx.setRoute( ctx.route );
			}
		}


		//Loop through all the keys in the current route that should or should not be there...
		//TODO: The routing actions need to be rebuilt based on what the user wants to remove...
		for ( var key in ListToArray( getRoutingActions() ) ) {
			//Check for the existence of the key first
			if ( StructKeyExists( ctx.getRoute(), key ) ) {
				//Call the right evaluation method, which ought to run its own setter
				var t = this[ key ]( ctx.getRoute(), variables.appdata );

				//This is not going to return the right thing all of the time as written...
				if ( !t.status )
					return this.respondWith( 500, t );

				//Set the model here "globally"
				if ( key eq "model" ) {
					variables.model = getContext().getModel();
				}
			}
		}

		//Use the context to serve a response. 
		//TODO: This does not account for custom headers
		var fctx = getContext();
		if ( fctx.getView() neq "" )
			return this.respondWith( fctx.getStatus(), { status=true, results=fctx.getView() });
		else {
			var imodel = fctx.getModel();
			if ( StructKeyExists( imodel, "results" ) )
				return this.respondWith( fctx.getStatus(), imodel );
			else if ( StructKeyExists( imodel, "httpstatus" ) )
				return this.respondWith( 500, { status=false, message="so much failure." } );
			else {
				return this.respondWith( 400, { 
					error = "No resource for #fctx.getRoute().name# found.",
					status = false,
					exception = {}
				});
			}
		}

		/*
		//View interpretation can fail
		if ( !(ctx.view = evaluateViewKey( ctx.route, ctx.model )).status )
			return this.respondWith( 500, ctx.view );
		else if ( ctx.view.status && StructKeyExists( ctx.view, "results" ) )
			return this.respondWith( 200, ctx.view );
		else { 
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
		*/

		//There is absolutely no reason to end up here.  Ever.
		return this;
	}
}

