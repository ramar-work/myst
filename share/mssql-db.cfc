//mssql looks like this
this.datasources["__DBSYMNAME__"] = {
	  class: 'com.microsoft.sqlserver.jdbc.SQLServerDriver'
	, bundleName: 'com.microsoft.sqlserver.mssql-jdbc'
	, bundleVersion: '6.2.2.jre8'
	, connectionString: 'jdbc:sqlserver://localhost:__DBCONNLIMIT__;DATABASENAME=__DBNAME__;sendStringParametersAsUnicode=true;SelectMethod=direct'
	, username: '__DBUSERNAME__'
	, password: '__DBPASSWORD__'
	
	// optional settings
	, connectionLimit: __DBCONNLIMIT__
};
