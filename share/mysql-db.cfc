//mysql looks like this
this.datasources["__DBSYMNAME__"] = {
	  class: 'com.mysql.jdbc.Driver'
	, bundleName: 'com.mysql.jdbc'
	, bundleVersion: '5.1.40'
	, connectionString: 'jdbc:mysql://localhost:__DBPORT__/__DBNAME__?useUnicode=true&characterEncoding=UTF-8&useLegacyDatetimeCode=true'
	, username: '__DBUSERNAME__'
	, password: '__DBPASSWORD__'
	
	// optional settings
	, connectionLimit: __DBCONNLIMIT__
}
