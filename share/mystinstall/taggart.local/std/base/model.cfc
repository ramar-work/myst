/*model.cfc*/
component
name="model"
accessors=true {
	function init( myst ) {
		variables.myst = myst;
		variables.routepath = myst.getContext().route.name;
		return this;	
	}
}
