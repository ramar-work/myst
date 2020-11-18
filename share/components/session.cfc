/* ---------------------------------------------- *
 * session.cfc
 * ===========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Methods for dealing with sessions.
 * 
 * ---------------------------------------------- */
component name="session" extends="base" {

	//FUTURE: what does this do?
	property name="keys" type="string";

	//FUTURE: what does this do?
	property name="name" type="string"; 

	/**
	 * Check for a specific key 
	 *
	 * @param obj   ....
	 */
	public boolean function check( struct obj ) {
		return StructKeyExists( session, "quickcart_token" );
		/*
		if ( getAuthStorage() eq "session" ) {
			return StructKeyExists( session, "quickcart_token" );
		}
		else if ( getAuthStorage() eq "db" ) {
			//Use a cookie or other identifier to track the user
			status = myst.dbExec(
				string = "SELECT * FROM quickcart_session VALUES ( :id )"
			, bindArgs = { id = "" }
			);
		
			if ( !status ) {
				return false;
			}
		}
		*/
	}

	/**
	 * Get a key
	 *
	 * @param obj   ....
	 */
	public string function key( struct obj ) {
		return ( StructKeyExists( session, "quickcart_token" ) ) ? session.quickcart_token : '';
		/*
		if ( getAuthStorage() eq "session" ) {
			return ( StructKeyExists( session, "quickcart_token" ) ) ? session.quickcart_token : '';
		}
		else {
			return false;
		}
		//should throw...
		return "";
		*/
	}	

	/**
	 * delete a session anonymously in a cart
	 *
	 * @param obj   ....
	 */
	public boolean function destroy() {
		var status = true;
		try {
			if ( getAuthStorage() eq "session" ) {
				StructDelete( session, "username" );
				StructDelete( session, "token" );
				StructDelete( session, "startDate" );
			}	
			else if ( getAuthStorage() eq "db" ) {
				var del = myst.dbExec(
					string = "DELETE FROM #prefix#session WHERE session_tracker = :trkr )"
				);
		
				if ( !del.status ) {
					return false;
				}
			}
		}
		catch (any e) {
			return false;
		}
		return true;
	}


	/**
	 * start a session anonymously in a cart
	 *
	 * @param obj   ....
	 */
	public boolean function start() {
		var status = true;
		try {
			if ( getAuthStorage() eq "session" ) {
				session.quickcart_token = myst.randStr( 64 );	
				session.quickcart_startDate = Now();	
			}	
			else if ( getAuthStorage() eq "db" ) {
				status = myst.dbExec(
					string = "INSERT INTO #prefix#session VALUES ( :trkr, :start )"
				, bindArgs = { trkr = myst.randstr(32), start = myst.getCurrentDatestamp() } 
				);
			
				if ( !status ) {
					return false;
				}
			}
		}
		catch (any e) {
			return false;
		}
		return true;
	}


	function init() {
		return this;
	}
}
