/* ------------------------------------------------------ *
 * routes/base.cfc
 * ---------------
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 *
 * @summary
 * Initialize the routes for a particular route
 * 
 * @todo
 * ...
 * ------------------------------------------------------ */
component extends="std.base.model" {

	//TODO: A lot of work may be needed to make this work the way I'd like
	private boolean function serveStatic( myst, model ) {
		var path = "files/#getNamespace()#/#route.active#";
		return myst.serveStaticResource([], path, "File not found.");
	}

	//This assumes that the path exists somehow...
	//It also assumes that your server is fast... b/c this is inefficient
	private array function returnPath( required string bp, required file ) {
		//Return an array if that's what's given...
		var arr = [];
		for ( var nn in arguments[2] ) {
			var file = arguments[2][nn];
			if ( FileExists( "#createName()#/#bp#/custom/#file#" ) )
				ArrayAppend( arr, "#createName()#/#bp#/custom/#file#" );
			else {
				ArrayAppend( arr, "#createName()#/#bp#/#file#" ); 
			}
		}
		return arr;
	}

	//...
	function init(myst, model) {
		variables.path.public = function (required file) {
			return returnPath( "no-auth", arguments );
		}
		variables.path.private = function (required file) {
			return returnPath( "auth", arguments );
		}
		return Super.init( myst );
	}
}
