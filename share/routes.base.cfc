/* ------------------------------------------------------ *
 * routes/base.cfc
 * ---------------
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 *
 * @copyright
 * Copyright 2016-Present, "Tubular Modular"
 * Original Author Date: Tue Jul 26 07:26:29 2016 -0400
 *
 * @summary
 * Allow the routes map to be extended by other components. 
 * 
 * ------------------------------------------------------ */
component extends="std.base.model" {

	//TODO: Fix this
	private boolean function serveStatic( myst, model ) {
		var path = "files/#getNamespace()#/#route.active#";
		return myst.serveStaticResource([], path, "File not found.");
	}

	//This assumes that the path exists somehow...
	//It also assumes that your server is fast... b/c this is inefficient
	private array function returnPath( required string t, required file ) {
		//Return an array if that's what's given...
		var arr = [];
		for ( var nn in arguments[2] ) {
			var file = arguments[2][nn];
			var ext = ( t == "app" ) ? "cfc" : "cfm";
			var customPath = "#myst.getRootdir()##t#/#createName()#/custom/#file#.#ext#"; 
			if ( FileExists( customPath ) )
				ArrayAppend( arr, "#createName()#/custom/#file#" );
			else {
				ArrayAppend( arr, "#createName()#/#file#" ); 
			}
		}
		return arr;
	}

	//...
	function init(myst, model) {
		variables.view.path = function (required file) {
			return returnPath( "views", arguments );
		}
		variables.app.path = function (required file) {
			return returnPath( "app", arguments );
		}
		return Super.init( myst );
	}
}
