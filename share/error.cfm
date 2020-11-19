<html>
<head>
</head>
<body>
<cfoutput>
	<div class="container">
		<!--- Status Code --->
		<h1>#error.getStatus()#</h1>
		<h2>#error.getStatusMessage()#</h2>
		<h3><!--- #v.brief# ---></h3>

		<div class="container-section">
			<h5>Error Summary</h5>
			<p class="error text">#error.getErrorMessage()#</p>

			<h5>Error Detail</h5>
			<p class="error text">
				Caught error at line #error.getErrorLineNumber()#, col #error.getErrorColumnNumber()#
			</p>

			<!--- Show the code section where things went wrong --->	
			<h6>Code Dump</h6>
			<div>#error.getErrorDump()#</div>

			<!--- Show the stack trace if asked --->	
			<h6>Stack Trace</h6>
			<div>#error.getErrorStackTrace()#</div>
		</div>
	</div>
</body>
</cfoutput>
</html>
