/* ---------------------------------------------- *
 * rand.cfc
 * ========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Handles generating random data.
 * 
 * ---------------------------------------------- */
component {

	/**
	 * Generates random letters.
	 *
	 * @param n     Length of random string.
	 */
	public string function string ( numeric n ) {
		// make an array instead, and join it...
		var str="abcdefghijklmnoqrstuvwxyzABCDEFGHIJKLMNOQRSTUVWXYZ0123456789";
		var tr="";
		for ( var x=1; x<n+1; x++) tr = tr & Mid(str, RandRange(1, len(str) - 1), 1);
		return tr;
	}


	/**
	 * Generates random numbers as a string.
	 *
	 * @param n     Length of random string.
	 */
	public string function number ( numeric n ) {
		// make an array instead, and join it...
		var str="0123456789";
		var tr="";
		for ( var x=1; x<n+1; x++ ) tr = tr & Mid(str, RandRange(1, len(str) - 1), 1);
		return tr;
	}

	function init() {
		return this;
	}

}
