<!---
/* ------------------------------------------ *
 * data.cfm
 * --------
 * 
 * Summary
 * --------
 * CFML-based configuration file.
 * 
 * Application routes, datasources and more
 * are all updated here.
 *
 * ------------------------------------------- */
 --->
<cfscript>
/*This variable is used by ColdMVC to load all configuration data*/
manifest = {
/*This should probably not be modified by you*/
 "cookie" = "f7a3edbe212ceeb08539ff8d37bd3a21181948b9796a988ef24b1b1291fa"

/*----------------- USER-MODIFIABLE STUFF ------------------*/
/*Turn on debugging, yes or no?*/
,"debug"  = 0  

/*Set a description for this new application*/
,"description"  = "__DESCRIPTION__" 

/*Set a primary author for SEO purposes*/
,"author"  = "" 

/*Locations for alternate serving locations can go here*/
,"hosts"  = [ ]

/*Select a datasource*/
,"source" = "(none)"

/*All requests will use this as the base directory*/
,"base"   = "/"

/*This is a symbolic name for the application*/
,"name"   = "testsa"

/*Set a global site title from here for SEO purposes*/
,"title"  = "testsa"

/*This is used to control how much logging to do where*/
,"settings" = {
	 "verboseLog" = 0
	,"addLogLine" = 0
}

/*----------------- DEPRECATED / UNUSED ---------------------*/
/*This was used to run something after every request*/
,"master-post" = false

/*This was used to choose custom 404 and 500 error pages*/
,"localOverride" = {
	 "4xx"    = 0
	,"5xx"    = 0
}

/*----------------- CUSTOM  ---------------------------------*/
/*Add your custom variables here*/

/*----------------- DATABASES -------------------------------*/
/*Aliases for database tables can go here*/
,"data"   = {}

/*----------------- ROUTES ---------------------------------*/
/*Here are the application's routes or endpoints.*/
,"routes" = {

	/*Lots of tests here*/
	/*default should always return something*/
	"default"= { model="default", view = "default" }
 ,"route-symbolic"= { model="default", view = "default" }

	/*these are simple file finding errors*/
 ,"route-no-files"= { model="zilch", view = "zilch" }
 ,"route-bad-syntax-general"= { model="badSyntax-badSyntax", view = "badSyntax-badSyntax" }
 ,"route-bad-syntax-model"= { model="badSyntax", view = "badSyntax" }
 ,"route-bad-syntax-view"= { model="badSyntax", view = "badSyntax" }

	/*these are chain loading errors*/
 ,"route-eval-string"= { model="zilch", view = "zilch" }
 ,"route-eval-array"= { model=[ "rea1", "rea2" ], view = "zilch" }
 ,"route-eval-object"= { model={ rea3 = "a", rea4 = "b" }, view = "zilch" }

	/*this exists to stress the engine*/
 ,"errors"= { model="errors", view = "errors" }
 } /*end routes*/
};
</cfscript>
