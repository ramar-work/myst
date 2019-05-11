<!---
/* ---------------------------------------------- *
 * Application-Redirect.cfc
 * ========================
 * 
 * Author
 * -----
 * Antonio R. Collins II (rc@tubularmodular.com, ramar.collins@gmail.com)
 * 
 * Copyright
 * ---------
 * Copyright 2016-Present, "Tubular Modular"
 * Original Author Date: Tue Jul 26 07:26:29 2016 -0400
 * 
 * Summary
 * -------
 * A stub used to redirect requests to disallowed directories.
 *
 * ---------------------------------------------- */
 --->
component {
	function onRequest (string targetPage)  {
		include "../data.cfm";
		try {
			location( url=manifest.base, addtoken='no' ); 
		} 
		catch (any e) {
			writedump(e);
			abort;
			include "failure.cfm";
		}
	}
}
