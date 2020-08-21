/*jsonfmt.cfc - Formats JSON properly when returning from CF*/
component name="jsonfmt" accessors="true" {
	//structs are primary format,
	//queries work too
	//maybe arrays, true/false, etc
	function init() {
		return this;
	}
}
