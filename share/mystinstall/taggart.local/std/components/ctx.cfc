component name="ctx" accessors="true" {
	//The active route goes here	
	property name="route" type="struct";

	//Components loaded during the lifetime of myst go here...
	property name="components" type="struct";

	//A query
	property name="query" type="query";

	//Code that runs before everything (can be whatever)
	property name="before"; //type="query";

	//Accepts certain types (can be a list too, since that makes it easier)
	property name="accepts" type="array";

	//Variables expected to be in a request 
	property name="expects" type="struct";

	//The model (all of that wrapping takes place here)
	property name="model"; 

	//The view data
	property name="view"; 

	//Variables and content passed in after execution go here...
	property name="scope" type="struct";

	function init() {
		return this;
	}
}
