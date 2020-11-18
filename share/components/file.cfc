/* ---------------------------------------------- *
 * file.cfc
 * ========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Methods for dealing with files.
 * 
 * ---------------------------------------------- */
component name="file" {

	/**
	 * Get the extension of a file.
	 *
 	 * @param filename       The filename to get the extension of.
   **/
	public string function getExtension( required string filename ) {
		var arr = ListToArray(filename, ".");
		if ( Len(arr) > 1 ) {
			return arr[ Len(arr) ];	
		}
		return "";
	}


	/**
	 * Get the name portion of a file.
	 *
 	 * @param filename       The filename to get the name of.
   **/
	public string function getNamePart( required string filename ) {
		var arr = ListToArray(filename, ".");
		if ( Len(arr) > 1 ) {
			ArrayDeleteAt( arr, Len(arr) );
			return ArrayToList( arr, "." );	
		}
		return "";
	}

	function init() {
		return this;
	}

}
