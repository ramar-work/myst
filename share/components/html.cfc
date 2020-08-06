/* html.cfc - Handles basic HTML functions in views */
component {

	/**
	 * crumbs( ... )
	 *
	 * Create "breadcrumb" link for really deep pages within a webapp. 
	 *
	 */
	public function crumbs ( array links ) {
		throw "EXPERIMENTAL";
		var a = ListToArray(cgi.path_info, "/");
		//writedump (a);
		/*Retrieve, list and something else needs breadcrumbs*/
		for (var i = ArrayLen(a); i>1; i--) {
			/*If it's a retrieve page, have it jump back to the category*/
			writedump(a[i]);
		}
	}


	/**
	 * href( ... )
	 *
	 * Generate links relative to the current application and its basedir if it
	 * exists.
	 *
	 * TODO: Should be in an HTML component
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
}
