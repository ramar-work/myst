<cfscript>
/* ------------------------------------------ *
data.cfm
--------

CFML-based configuration file.

Application routes, datasources and more
are all updated here.
* ------------------------------------------- */

/*This variable is used by ColdMVC to load all configuration data*/
manifest={
	 "cookie" = "3ad2d4dc34e75130c0c2f3c4bbb262481b49250261bcb8e6443728b63d24"

	/*Turn on debugging, yes or no?*/
	,debug  = 0 

	/*Specify whether or not to use .cfm*/
	,autoSuffix = false 

	/*All requests will use this as the base directory*/
	,base   = "/"

	/*Set the site title from here*/
	,title  = "Taggart! - A Test Instance for Myst"

	/*This is used to control how much logging to do where*/
	,settings = {
		 "verboseLog" = 0
		,"addLogLine" = 0
	}

	/*----------------- CUSTOM  ---------------------------------*/
	/*Other things that can go in data, but to keep things easy
	to fix later, I'll seperate them from what should be there*/
	,sitename = "taggart.local"

	/*----------------- ROUTES ---------------------------------*/
	/*Here are the application's routes or endpoints.*/
	,routes = {
	 	/*regular site*/
		default= { model="home", view =[ "intro/head", "default", "intro/tail" ] }

		/*user mgmt*/
	 ,login= { model = [ "login" ] }
	 ,register= { model= "register", view =[ "intro/head", "register", "intro/tail" ] }
	 ,logout= { model= "logout", view = "logout" }

	 	//Here is a test API at /api/recipes
	 ,api = {
			returns = "application/json",
			recipes = {
				namespace = { "api/recipe" = "items" },
				"\bcreate\b" = { model = "api/recipe" },
				"\bupdate\b|\bremove\b|\bget\b" = {
					"[0-9*]" = { model = "api/recipe" }
				},
			},
		}
	}
};
</cfscript>
