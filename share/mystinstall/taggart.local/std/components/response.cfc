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

	/**
	 * sendBinaryResponse
	 *
	 * Send a binary response.
	 *
	 */
	public boolean function sendBinaryResponse(Required numeric s, Required string m, required numeric size, required c) {
		var q = getPageContext().getResponse();
		var r = getPageContext().getResponseStream();
		//You can optionally make a bytestream here
		q.setStatus( s, getHttpHeaders()[s] );
		q.setContentType( m );
		q.setContentLength( size );
		r.write( c );
		r.close();
		return true;
	}

	//Send the message over the wire
	
	public boolean function send(Required Numeric s, Required String m, Required c, Struct headers) {
		/*
		var r = getPageContext().getResponse();
		var w = r.getWriter();
		r.setStatus( s, getHttpHeaders()[ s ] );
		r.setContentType( m );
		w.print( c );
		w.flush(); //this is a function... thing needs to shut de fuk up
		*/
		var r = getPageContext().getResponse();
		var w = r.getWriter();
		r.setStatus( s, getHttpHeaders()[ s ] );
		r.setContentType( m );
		w.print( c );
		w.flush();
		r.close(); 
		return true;
	}

	function init() {
		return this;
	}

}
