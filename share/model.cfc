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
accessors=true {

	property type="list" name="dependencies" default="";

	property type="string" name="dependencyBaseDir" default="";

	/** 
	 * Maps dependencies specified in a model's 'dependencies' property.
	 *
	 */
	private boolean function mapDependencies() {
		for ( var n in ListToArray( getDependencies() ) ) {
			variables[ basename( n ) ] = createObject( n ).init( myst );
		}
		return true;
	}

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
		if ( !mapDependencies() ) {

		}
		return this;	
	}
}
