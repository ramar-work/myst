<cfscript>
//I might be able to simulate each error from this page
if ( !StructKeyExists( url, "error" ) )
	0;
else {
	/*
	if ( url.error eq "Application" )
		3 + 3;
	*/
	var q;
	if ( url.error eq "Database" ) {
		var rr;
		q = new Query( datasource="i_dont_exist_and_never_will" );	
		q.setName = "toodly";
		rr = q.execute( sql = "select * from nothing" );	
	}
	if ( url.error eq "MissingInclude" || url.error eq "Template" )
		include "i_will_never_exist.cfm";
	if ( url.error eq "Object" ) {
		q = createObject( "component", "nothingness_and_despair" );	
	}	
	if ( url.error eq "Expression" ) {
		var bb = null;
		StructIsEmpty( bb );	
	}	
	if ( url.error eq "Security" )
		0;
	if ( url.error eq "Lock" )
		0;
}
</cfscript>
