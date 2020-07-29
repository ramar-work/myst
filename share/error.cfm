<html>
<head>
</head>
<body>
<cfset v = getPageError()>
<cfoutput>
	<div class="container">
		<!--- Status Code --->
		<h1>#v.getStatus()#</h1>
		<h2>#v.getStatusMessage()#</h2>
		<h3><!--- #v.brief# ---></h3>

		<div class="container-section">
			<h5>Error Summary</h5>
			<p class="error text">#v.getErrorMessage()#</p>

			<h5>Error Detail</h5>
			<p class="error text">
				Caught error at line #v.getLineNumber()#, col #v.getColumnNumber()#
			</p>

			<!--- Show the code section where things went wrong --->	
			<h6>Code Dump</h6>
			<div>#v.getDump()#</div>

			<!--- Show the stack trace if asked --->	
			<h6>Stack Trace</h6>
			<div>#v.getStackTrace()#</div>
		</div>
	</div>
</body>
</cfoutput>
</html>
