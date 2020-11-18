/* ---------------------------------------------- *
 * html.cfc
 * ========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Handles generating basic structures for common 
 * elements in HTML.
 * 
 * ---------------------------------------------- */
component extends="base" {

	/**
	 * Create "breadcrumb" link for really deep pages within a webapp. 
	 *
	 * @param links       A set of links.
	 */
	public function crumbs ( array links ) {
		var a = ListToArray(cgi.path_info, "/");
		//writedump (a);
		/*Retrieve, list and something else needs breadcrumbs*/
		for (var i = ArrayLen(a); i>1; i--) {
			/*If it's a retrieve page, have it jump back to the category*/
			writedump(a[i]);
		}
	}


	/**
	 * Generate navigation.
	 *
	 * @param items     ...
	 */
	public array function generateNav( required items ) {
		var t = myst.getType( items );
		//if it's not an array, struct or query, die
		if ( t.type neq "struct" && t.type neq "array" && t.type neq "string" ) {
			//throw new Exception( 'items were not an array or struct." );
			return [];
		}

		if ( t.type eq "string" ) {
			items = ListToArray( items, "," );		
		}
		
		var links = [];
		for ( var i in items ) {
			//ArrayAppend( links, { href=myst.link( "#baseurl#/#i#" ), name=i } );	
			ArrayAppend( links, { href="#baseurl#/#i#", name=i } );	
		}
		return links;
	}


	/**
	 * Generate links relative to the current application and its basedir if it
	 * exists.
	 *
	 * @param str        ...
	 */
	public string function href( string str ) {
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
			if ( StructKeyExists( appdata, "autoSuffix" ) && Right( linkText, 4 ) != ".cfm" ) {
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

	function init() {
		return this;
	}
}
