/* ------------------------------------------ *
 * data.cfc
 * --------
 * 
 * @summary
 * Component-based configuration file. Application 
 * routes, datasources and more are all updated 
 * here.  See std/base/data.cfc for additional 
 * properties.
 * ------------------------------------------- */
component extends="std.base.data" accessors="true" {
	//Set a description for this new application
	property name="description" type="string" default="__DESCRIPTION__";

	//Set a primary author for SEO purposes
	property name="author" type="string" default="__AUTHOR__";

	//Select a datasource
	property name="source" type="string" default="__DATASOURCE__";

	//Set a global site title from here for SEO purposes
	property name="title" type="string" default="__TITLE__";

	//Return things
	function init( myst ) {
		return Super.init( myst, {
			//Add your site's routes here
			"default" = { model="default", view="default" }
		}); 
	}
}
