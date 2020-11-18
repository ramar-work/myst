/* ---------------------------------------------- *
 * query.cfc
 * =========
 * 
 * @author
 * Antonio R. Collins II (ramar@collinsdesign.net)
 * 
 * @copyright
 * 2016 - Present, Tubular Modular Inc dba Collins Design
 * 
 * @summary
 * Methods for dealing with queries.
 * 
 * ---------------------------------------------- */
component name="query" extends="base" {

	//Defines a datasource
	property name="datasource" type="string";

	//Defines a timeout (in milliseconds)
	property name="timeout" type="numeric" default=100;

	/**
	 * Execute queries cleanly and easily.
	 *
	 * @param qd
	 */
	private query function duplicate( required struct qd ) {
		var qset;
		var typeset = "";
		for ( var _ in qd.prefix.columnList ) {
			typeset = ListAppend( typeset, "varchar" );
		}
		return QueryNew( qd.prefix.columnList, typeset ); 
	}


	/**
	 * ...
	 *
	 * @param qd
	 */
	private string function querySetColumns( args ) {
		//cycle through all arguments, adding each and a type
		var ts = "";
		return ts;
	}


	/**
	 * ...
	 *
	 * @param qd
	 */
	private string function queryGetColumns( required query query ) {
		var list = "";
		for ( var qs in arguments.query ) {
			for ( var key in qs ) list = ListAppend( list, key );
			break;
		}	
		return list;
	}


	/**
	 * Execute queries cleanly and easily.
	 *
	 * @param qd
	 */
	private string function queryMockTypes( required query query ) {
		var list = "";
		for ( var qs in arguments.query ) {
			for ( var key in qs ) list = ListAppend( list, "varchar" );
			break;
		}	
		return list;
	}


	/**
	 * Check if a result set is composed of all nulls
	 */
	public boolean function isSetNull ( Required Query q ) {
		var columnNames = ListToArray( q.columnList );
		if ( q.recordCount gt 1 )
			return false;
		else if ( q.recordCount eq 1 ) { 
			//Check that the first (and only) row is not blank.
			for ( var ci=1; ci lte ArrayLen(columnNames); ci++ ) {
				if ( q[columnNames[ci]][1] neq "" ) {
					return false;	
				}
			}
		}
		return true;
	}


	/**
	 * Execute queries cleanly and easily.
 	 *
	 * @param datasource       A data source name
	 * @param filename         A filename in $ROOT/sql/ that contains SQL code.
	 * @param string           A string of SQL
	 * @param query            A query
	 * @param bindargs         Arguments to use for binding.
	 */
	public struct function execute( string datasource, string filename, string string, struct bindArgs, query query ) {
		//Set some basic things
		var Name = "query";
		var Constant = "sql";
		var SQLContents = "";
		var cm = getConstantMap();
		var Period;
		var fp;
		var rr;
		var Base;
		var q;
		var resultSet;

		//Check for either string or filename
		var cFilename = StructKeyExists( arguments, "filename" );
		var cString = StructKeyExists( arguments, "string" );
		var cQuery = StructKeyExists( arguments, "query" );

		if ( !cFilename && !cString ) {
			return { 
				status= false, 
				message= "Either 'filename' or 'string' must be present as an argument to this function."
			};
		}

		//Make sure data source is a string
		if ( !cQuery ) {
			if ( !IsSimpleValue( arguments.datasource ) ) {
				return { status= false, message= "The datasource argument is not a string." };
			}

			if ( arguments.datasource eq "" ) {
				return { status= false, message= "The datasource argument is blank."};
			}
		}

		//Then check and process the SQL statement
		if ( StructKeyExists( arguments, "string" ) ) {
			if ( !IsSimpleValue( arguments.string ) ) {
				return { status= false, message= "The 'string' argument is neither a string or number." };
			}

			Name = "_anonymous";
			SQLContents = arguments.string;
		}
		else {
			//Make sure filename is a string (or something similar)
			if ( !IsSimpleValue( arguments.filename ) )
				return { status= false, message= "The 'filename' argument is neither a string or number." };

			//Get the file path.	
			fp = cm[ Constant ] & "/" & arguments.filename;
			//return { status= false, message= "#current# and #root_dir#" };

			//Check for the filename
			if ( !FileExists( fp ) )
				return { status= false, message= "File " & fp & " does not exist." };

			//Get the basename of the file
			Base = find( "/", arguments.filename );
			if ( Base ) {
				0;	
			}

			//Then get the name of the file sans extension
			Period = Find( ".", arguments.filename );
			Name = ( Period ) ? Left(arguments.filename, Period - 1 ) : "query";

			//Read the contents
			SQLContents = FileRead( fp );
		}

		//Set up a new Query
		if ( !cQuery )
			q = new Query( name="#Name#", datasource="#arguments.datasource#" );	
		else {
			q = new Query( name="#Name#", dbtype="query" );
			q.setAttributes( _mem_ = arguments.query );
		}

		//q.setName = "#Name#";

		//If binds exist, do the binding dance 
		if ( StructKeyExists( arguments, "bindArgs" ) ) {
			if ( !IsStruct( arguments.bindArgs ) ) {
				return { status= false, message= "Argument 'bindArgs' is not a struct." };
			}

			for ( var n in arguments.bindArgs ) {
				var value = arguments.bindArgs[n];
				var type = "varchar";

				if ( IsSimpleValue( value ) ) {
					try { __ = value + 1; type = "integer"; }
					catch (any e) { type="varchar"; }
				}
				else if ( IsStruct( value ) ) {
					v = value;
					if ( !StructKeyExists( v, "type" ) || !IsSimpleValue( v["type"] ) )
						return { status = false, message = "Key 'type' does not exist in 'bindArgs' struct key '#n#'" };	
					if ( !StructKeyExists( v, "value" ) || !IsSimpleValue( v["value"] ) ) 
						return { status = false, message = "Key 'value' does not exist in 'bindArgs' struct key '#n#'" };	
					type  = v.type;
					value = v.value;
				}
				else {
					return { 
						status = false, 
						message = "Each key-value pair in bindArgs must be composed of structs."
					};
				}
				q.addParam( name=LCase(n), value=value, cfsqltype=type );
			}
		}

		//Execute the query
		try { 
			rr = q.execute( sql = SQLContents ); 
		}
		catch (any e) {
			return { 
				status  = false,
			  message = "Query failed. #e.message# - #e.detail#."
			};
		}

		//Put results somewhere.
		resultSet = rr.getResult();

		//Return a status
		return {
			status  = true
		 ,message = "SUCCESS"
		 ,results = ( !IsDefined("resultSet") ) ? {} : resultSet
		 ,prefix  = rr.getPrefix()
		};
	}


	/**
	 * Modify queries cleanly and easily.
 	 *
	 * @param query            An executed query 
	 * @param append           A struct containing keys and values to append to a query.
	 * @param transform        A struct containing keys and values to modify within a query.
	 */
	public struct function modify( required struct query, struct append, struct transform ) {
		var ts = queryMockTypes( query.results );
		var cs = queryGetColumns( query.results ); 

		//Then append to it if the proper arguments were given. 
		if ( StructKeyExists( arguments, "append" ) ) {
			for ( var _ in append ) ts= ListAppend( ts, "varchar" );
			for ( var t in append ) cs= ListAppend( cs, t );
		}

		//Then create a new query
		var bquery = QueryNew( cs, ts ); 

		//Do some syntactic sugar to make this easier
		var tr = StructKeyExists( arguments, "transform" ) ? transform : {};
		var ap = StructKeyExists( arguments, "append" ) ? append : {};

		//You should also check arguments ahead of time to see if they are the right type.
		//myst.getType( );

		//Loop through all rows
		for ( var qs in arguments.query.results ) {
			var row = {};
			//Whenever you run into a transform, do what needs to be done and add it	
			for ( var key in qs ) {
				row[ key ] = StructKeyExists( tr, key ) ? tr[ key ]( qs[ key ] ) : qs[ key ];
			}

			//Call with the first argument being the original query row
			for ( var t in ap ) {
				row[ t ] = ap[ t ]( qs ) 
			}

			QueryAddRow( bquery, row );
		}

		var pfx = StructKeyExists( arguments.query, "prefix" ) ?
			arguments.query.prefix : {}; 

		return {
			status = true
		, prefix = pfx 
		, results = bquery
		}
	}


	/**
	 * Retrieve the column names from a database table.
 	 *
	 * @param table            A table to query for column names.
	 * @param dbname           An alternate datasource to use.
	 */
	public String function columns( required string table, string dbname ) {
		var noop = "";

		//Save column names to a variable titled 'cn'
		dbinfo datasource=arguments.dbname type="columns" name="cn" table=table;
		writedump( cn );	

		//This should be just one of the many ways to control column name output
		for ( name in cn ) {
			noop &= cn.column_name;
		}

		return noop;
	}


	/**
	 * Find the columns in a query (or string) and return the most appropriate zero-length values
 	 *
	 * @param query            An executed query 
	 * @param string           A struct containing keys and values to append to a query.
	 */
	public query function empty( struct query, string string ) {
		if ( !StructKeyExists( arguments, "query" ) && !StructKeyExists( arguments, "string" ) )
			;//DIE
		var a = StructKeyExists( arguments, "query" ) ?	arguments.query : myst.dbExec( string = arguments.string );
		var ts = queryMockTypes( a.results );
		var cs = queryGetColumns( a.results ); 
		var bquery = QueryNew( cs, ts );
		var vals = {};
		for ( var key in ListToArray( cs ) ) {
			vals[ key ] = "";	
		}
		QueryAddRow( bquery, vals );
		return bquery
	}


	/**
	 * .... 
	 * 
	 * @param table            Table to add to. 
	 * @param values           Values to add (either a transaction or a single record) 
	 */
	public struct function insert( required string table, required struct values ) {
//Can't tell if this makes sense or not...
//myst.query.insert( "table", { a=b, c=d });
		//var str = "INSERT INTO #table# ( ## ) VALUES ( ## )"
		return {
			status = true
		,	id = 1 //id of record added
		,	count = 1 //how many records
		}
	}


	function init() {
		return this;
	}
}
