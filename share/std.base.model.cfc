/* ---------------------------------------------- *
 * model.cfc
 * ===========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Example model file	
 * 
 * ---------------------------------------------- */
component
name="model"
accessors="true" {

	//List of dependencies needed by this model
	property name="dependencies" type="list" default="";

	/** 
	 * Return an appropriate scope per received method.
	 *
	 */
	private struct function getScope() {
		if ( cgi.request_method == "GET" || cgi.request_method == "DELETE" ) 
			return url;
		else {
			return form;
		}
	}

	/** 
	 * ...
	 *
	 */
	private boolean function methodMatches( required array methods ) {
		for ( var f in methods ) {
			if ( cgi.request_method == f ) {
				return true;	
			}
		}
		return false;
	}

	/** 
	 * Return the basename of a path.
	 *
	 */
	private string function basename( required string str ) {
		return ( arr = ListToArray( str, "." ) )[ Len( arr ) ];
	}

	/** 
	 * Return the name of the currently initialized component.
	 *
	 */
	private string function createName() {
		return basename( getMetadata( this ).name );
	}


	function init( myst ) {
		variables.myst = myst;
		variables.route = {}
		variables.components = myst.getContext().components;
		
		//Initialize extensions to router
		if ( StructKeyExists( myst.getContext(), "route" ) ) { 
			variables.route = myst.getContext().route;
			variables.route.path = myst.getContext().route.name;
			variables.route.parts = ListToArray( variables.route.path, "/" )
			variables.route.active = variables.route.parts[ Len( variables.route.parts ) ];
		}

		//Add any dependencies
		for ( var n in ListToArray( getDependencies() ) ) {
			variables[ basename( n ) ] = createObject( n ).init( myst );
		}
		return this;	
	}
}
