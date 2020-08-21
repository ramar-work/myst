component
name="failure"
accessors=true {
	property name="status" type="boolean";
	property name="error" type="string";
	property name="exception";
	
	function init( required string errstring, struct exception ) {
		this.error = errstring;
		this.status = false;
		this.exception = exception;
		return this;
	}
}
