<!---
/* ---------------------------------------------- *
index.cfm
=========

Author
------
Antonio R. Collins II (rc@tubularmodular.com, ramar.collins@gmail.com)

Copyright
---------
Copyright 2016-Present, "Tubular Modular"
Original Author Date: Tue Jul 26 07:26:29 2016 -0400

Summary
-------
This file serves as a single entry point for all 
new ColdMVC applications.

 * ---------------------------------------------- */
  --->
<cfscript>
	coldmvc = createObject("component", "coldmvc").init({});
	coldmvc.make_index(coldmvc);
</cfscript>
