<html>

<head>
<script>
document.addEventListener("DOMContentLoaded",function(e) {
	var x = new XMLHttpRequest();
	x.open( "GET", '/api/donut/cake.cfm', false );
	x.send( );
	console.log( x.responseText );
	var a = JSON.parse( x.responseText );
	console.log( a );	
});
</script>
</head>

<body>
<cfif #data.page# eq "cheese">
	<h2>Eat cheese</h2>
<cfelseif #data.page# eq "fish">
	<h2>Eat fish</h2>
<cfelse>
	<h2>Eat something</h2>
</cfif>
</body>

</html>
