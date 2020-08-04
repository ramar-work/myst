component 
name="response"
accessors="true"
{
	
	property name="headers" type="array";

	property name="content" type="string";

	property name="contentType" type="string" default="text/html";

	property name="size" type="numeric";

	//Status of the page in question goes here
	property name="status" type="numeric";

	public boolean function _toBoolean() {
		return false; 
	}

	//Send the message over the wire
	private void function send() {
		var r = getPageContext().getResponse();
		var w = r.getWriter();
		r.setStatus( s, getHttpHeaders()[ s ] );
		r.setContentType( m );
		w.print( c );
		w.flush(); //this is a function... thing needs to shut de fuk up
	}

	function init() {
		return this;
	}

}
