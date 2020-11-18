/* ---------------------------------------------- *
 * error.cfc
 * =========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Methods for dealing with errors.
 * 
 * ---------------------------------------------- */
component 
name="error"
extends="base"
accessors=true
{
	property name="status" type="numeric"; 

	property name="statusMessage" type="string"; 

	property name="errorHandler" type="string" default="error";

	property name="errorMessage" type="string" default="Error occurred.";

	property name="errorDetail" type="string"; 
	
	property name="errorException" type="object"; 

	property name="errorLineNumber" type="numeric"; 

	property name="errorColumnNumber" type="numeric"; 

	property name="errorStacktrace" type="string"; 

	property name="errorDump" type="string"; 

	property name="response" type="object"; 

	//Takes a structure as an argument and breaks it down
	public void function explode( struct error ) {
		this.setErrorMessage( error.error );
		if ( StructKeyExists( error, "exception" ) && !StructIsEmpty( error.exception ) ) {
			//The error class could be invoked instead...
			this.setErrorException( error.exception );
			if ( StructKeyExists( error.exception, "Detail" ) ) {
				this.setErrorDetail( error.exception.detail );
			}
			if ( StructKeyExists( error.exception, "TagContext" ) ) {
				this.setErrorLineNumber( error.exception.TagContext[1].line );
				this.setErrorColumnNumber( error.exception.TagContext[1].column );
				this.setErrorDump( error.exception.TagContext[1].codePrintHTML );
				this.setErrorStackTrace( error.exception.StackTrace );
			}	
		}
	}

	//
	public struct function serialize() {
		return {
			error_message = this.getErrorMessage()
		, error_detail = this.getErrorDetail()
		, line = this.getErrorLineNumber()
		, column = this.getErrorColumnNumber()
		, dump = this.getErrorDump()
		, stack_trace = this.getErrorStackTrace()
		}
	}

	//Handles rendering error messages according to the type of content
	public string function render( struct error ) {
		this.explode( error );
		var res = myst.getResponse();
		if ( res.getContentType() == "application/json" )
			return SerializeJSON( this.serialize() ); 
		else if ( res.getContentType() == "text/xml" )
			return SerializeXML( this.serialize() ); 
		else {
			//Include an error handler file
			fwResults = myst._include( "std", this.getErrorHandler() );
			if ( fwResults.status )
				return fwResults.results;					
			else {
				//If file is not found or something else is wrong then die out
				var ie = this.explode( fwResults );  //This really should return something...
				return 
					"<h2>#this.getErrorMessage()#</h2>" &
					"<h3>HTTP STATUS MESSAGE SHOULD GO HERE</h3>" &
					"<p>#this.getErrorStackTrace()#</p>"
			}
		}	
	}

	function init( myst ) {
		variables.myst = myst;
		return this;
	}
}
