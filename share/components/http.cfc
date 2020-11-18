/* ---------------------------------------------- *
 * http.cfc
 * ========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Handles logging.
 * 
 * ---------------------------------------------- */
component extends="base" {

	/**
	 * Do a GET request.
	 *
	 * @param uri        A URL to make the request to.
	 * @param headers    Headers to use when making the request.
   */
	public struct function get( required string uri, struct headers ) {
	}

	/**
	 * Do a HEAD request.
	 *
	 * @param uri        A URL to make the request to.
	 * @param headers    Headers to use when making the request.
   */
	public struct function head( required string uri, struct headers ) {
	}

	/**
	 * Do a PUT request.
	 *
	 * @param uri        A URL to make the request to.
	 * @param headers    Headers to use when making the request.
   */
	public struct function put( required string uri, payload, struct headers ) {
	}

	/**
	 * Do a PATCH request.
	 *
	 * @param uri        A URL to make the request to.
	 * @param headers    Headers to use when making the request.
   */
	public struct function patch( required string uri, payload, struct headers ) {
	}


	/**
	 * Do a DELETE request.
	 *
	 * @param uri        A URL to make the request to.
	 * @param headers    Headers to use when making the request.
   */
	public struct function delete( required string uri, payload, struct headers ) {
	}


	/**
	 * Do a POST request.
	 *
	 * @param uri        A URL to make the request to.
	 * @param headers    Headers to use when making the request.
   */
	public struct function post ( required string uri, payload, struct headers ) {
		//Define some headers
		var fakeUa = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36";
		var apiHeaders = {};
		var completed;

		try {
			//Create a new request object
			var http = new http( method=UCase(method), charset="utf-8", url=arguments.uri );
			http.setUserAgent( fakeUa );

			//Add appropriate headers
			if ( StructKeyExists( headers, "Content-Type" ) ) 
				http.addParam( type="header", name="Content-Type", value=headers["Content-Type"] );
			else if ( method eq "POST" || method eq "PUT" )
				http.addParam( type="header", name="Content-Type", value="application/x-www-form-urlencoded" );
			else if ( arguments.method eq "multipart" ) {
				http.addParam( type="header", name="Content-Type", value="multipart/form-data" );
			}

			//Add the headers
			if ( StructKeyExists( arguments, "headers" ) ) {
				for ( var k in arguments.headers ) {
					http.addParam( type="header", name=k, value=headers[k] );
				}
			}

			//Add the body fields
			if ( StructKeyExists( arguments, "payload" ) ) {
				var t = getType( arguments.payload );
				if ( t.type neq "string" && t.type neq "struct" )
					return failure( "Payload is of incorrect type.", e ); //500
				else if ( t.type eq "string" )
					http.addParam( type="body", value=arguments.payload );
				else if ( t.type eq "struct" ) {
					for ( var k in payload ) {
						http.addParam( type="formfield", name=LCase( k ), value=payload[ k ] );
					}
				}
			}

			completed = http.send().getPrefix();
		}
		catch (any e) {
			return failure( "Failure to perform HTTP '#method#' on URL '#apiURL#'", e );
		}

		//When this returns, I want to see the content in my window
		return {
			status = true
		, message = "Successfully performed HTTP #method# on URL '#apiURL#'" 
		, results = completed.fileContent 
		, extra = completed 
		};
	}


	function init( myst, data ) {
		return this;
	}
}
