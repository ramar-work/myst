<cfscript>
if ( StructKeyExists( url, "file" ) && StructKeyExists( url, "module" ) ) {
	myst.setupdatasource( file=url.file, module=url.module );
}
</cfscript>
