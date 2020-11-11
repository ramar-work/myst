/* ---------------------------------------------- *
 * api.cfc
 * =======
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Example API file	
 * 
 * ---------------------------------------------- */
component 
name="api"
extends="model" 
accessors="true" 
{

	//How many levels should myst step back in the URL to find an expected match?
	property name="resolution" type="number" default="2";

	//Keys to catch when running a /create
	property name="requiredOnCreate" type="struct" default="";

	//Keys to catch when running an /update
	property name="requiredOnUpdate" type="struct" default="";

	//Keys to catch when running a /delete
	property name="requiredOnDelete" type="struct" default="";

	//Keys to catch when running a /retrieve
	property name="requiredOnRetrieve" type="struct" default="";

	//Keys to catch when running a /create
	property name="optionalOnCreate" type="struct" default="";

	//Keys to catch when running an /update
	property name="optionalOnUpdate" type="struct" default="";

	//Keys to catch when running a /delete
	property name="optionalOnDelete" type="struct" default="";

	//Keys to catch when running a /retrieve
	property name="optionalOnRetrieve" type="struct" default="";

	//If values are not specified, default to a blank string
	property name="optionalDefaultToString" type="boolean" default=false;

	//Only API will deal with this for now... but this may change
	private struct function filter( required string method, required args ) {
		//results are the results of myst.validate()
		var v = {};

		for ( var key in ListToArray( variables[ "requiredOn#method#" ] ) ) {
			v[ key ] = { req = true };
		}

		for ( var key in ListToArray( variables[ "optionalOn#method#" ] ) ) {
			var lr = ListToArray( key, "=" ); 
			if ( Len(lr) eq 1 ) {
				v[ key ] = { req = false }
				if ( variables.optionalDefaultToString ) {
					v[ key ].ifNone = ""; 
				}
			}
			else if ( lr[2] eq "file" ) {
				v[ lr[1] ] = { req = false, file = true }
			}
			else {
				v[ lr[1] ] = { 
					req = false
				, ifNone = lr[2]
				, type = myst.getType( lr[2] ).type
				}
			}
		}

		if ( !( valid = myst.validate( args, v ) ).status ) {
			return myst.lfailure( 400, valid.message );
		}

		//If the method is NOT create, then route.active should be added as the id
		if ( method neq "create" ) {
			valid.results[ "id" ] = route.active;
		}

		return { 
		  status = true 
		, results = valid.results
		};
	}

	/** 
	 * Check if a route maps to a method name (and invoke it automatically)
	 *
	 */
	private struct function doesRouteMap( numeric step=1 ) {
		var f = getMetadata( this ).functions;
		//Only move back $step times in the routing table
		for ( var s = 0; s < step; s++ ) {
			var name = route.parts[ Len(route.parts) - s ]; 
			for ( var fd in f ) {
				if ( fd.name == name ) {
					return { status = true, name = name };
				}
			}
		}
		return { status = false };
	}

	//Always runs ahead
	public boolean function pre() {
		return true;
	}

	//Always runs after 
	public boolean function post() {
		return true;
	}

	function init( myst, model ) {
		Super.init( myst );

		//Do constructive things here...
		if ( !this.pre() ) {
			return myst.lfailure( 412, "Precondition failed." );
		}

		//If method is POST and struct is empty form, then die...
		if ( cgi.request_method == "POST" && StructIsEmpty( form ) ) {
			return myst.lfailure( 400, "No data sent." );
		}

		//Dispatch to methods and filter necessary keys
		if ( ( map = doesRouteMap( 2 ) ).status )
			return ( !(r = filter( map.name, getScope() )).status ) ? r : this[ map.name ]( r.results ); 
		/*
		else if ( uuid_exists( route.active ) ) {
			//exists must return true for whatever it is... and call retrieve too
			return this.retrieve( { id = route.active } );	
		}
		*/

		//Do destructive things here...
		this.post();

		//Other entries should return 404 automatically...		
		return myst.lfailure( 400, "Server could not fulfill this request." );
	}
}

