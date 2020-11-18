/* ---------------------------------------------- *
 * base.cfc
 * ========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Base for standard components.
 * 
 * ---------------------------------------------- */
component accessors=true {
	//Take properties from myst or appdata that are pertinent to properties defined in this component's children.
	function init( myst, appdata ) {
		//for each property defined, take the value from either myst or appdata 
		return this;
	}
}
