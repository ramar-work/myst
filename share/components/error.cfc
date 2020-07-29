/*error.cfc - Deals with handling errors*/
component 
name="error"
accessors=true
{
	property name="status" type="numeric"; 

	property name="statusMessage" type="string"; 

	property name="errorHandler" type="string" default="error";

	property name="errorMessage" type="string" default="Error occurred.";

	property name="lineNumber" type="numeric"; 

	property name="columnNumber" type="numeric"; 

	property name="stacktrace" type="string"; 

	property name="dump" type="string"; 

	//Dependencies
	property name="response" type="object"; 
	property name="framework" type="object"; 

	//Takes a structure as an argument and breaks it down
	public void function explode( struct error ) {
		this.setErrorMessage( error.error );
		if ( StructKeyExists( error, "exception" ) && !StructIsEmpty( error.exception ) ) {
			//The error class could be invoked instead...
			var me = error.exception
			if ( StructKeyExists( me, "TagContext" ) ) {
				this.setLineNumber( me.TagContext[1].line );
				this.setColumnNumber( me.TagContext[1].column );
				this.setDump( me.TagContext[1].codePrintHTML );
				this.setStackTrace( me.StackTrace );
			}	
		}
	}

	//Handles rendering error messages according to the type of content
	public string function render( struct error ) {
		this.explode( error );
		//
		if ( this.response.getContentType() == "application/json" )
			return SerializeJSON( this ); 
		else if ( this.response.getContentType() == "text/xml" )
			return SerializeXML( this ); 
		else {
			//Include an error handler file
			fwResults = this.framework._include( "std", this.getErrorHandler() );
			if ( fwResults.status )
				return fwResults.results;					
			else {
				//If file is not found or something else is wrong then die out
				var ie = this.explode( fwResults );  //This really should return something...
				return 
					"<h2>#this.getErrorMessage()#</h2>" &
					"<h3>HTTP STATUS MESSAGE SHOULD GO HERE</h3>" &
					"<p>#this.getStackTrace()#</p>"
			}
		}	
	}

	function init( res /*Instance of response for content-type*/, fw /*Myst instance*/ ) {
		this.response = res;
		this.framework = fw;
		return this;
	}
}
