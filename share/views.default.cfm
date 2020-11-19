<!---
views-default.cfm
=================

@author
Antonio R. Collins II (rc@tubularmodular.com, ramar.collins@gmail.com)

@copyright
Copyright 2016-Present, "Tubular Modular"
Original Author Date: Tue Jul 26 07:26:29 2016 -0400

@summary
Default 'It Works!' style page for successful 
myst deployments. 
  --->
<html>

<head>
<style type=text/css>
/*Borrowed and modified from http://meyerweb.com/eric/tools/css/reset/ */
html, body, div, 
h1, h2, h3, h4, h5, h6, 
p, pre,
a, img, b, u, i, center, dl, dt, dd, ol, ul, li,
fieldset, form, label, legend, table, caption, 
tbody, tfoot, thead, tr, th, td, article, aside, 
canvas, details, embed, figure, figcaption, 
footer, header, hgroup, menu, nav, output, ruby, 
section, summary, time, mark, audio, video {
	margin: 0;
	padding: 0;
	border: 0;
	font-size: 100%;
	font: inherit;
	vertical-align: baseline;
}
article, aside, details, figcaption, figure, 
footer, header, hgroup, menu, nav, section {
	display: block;
}
body {
	line-height: 1;
}
ol, ul {
	list-style: none;
}
blockquote, q {
	quotes: none;
}
blockquote:before, blockquote:after, q:before, q:after {
	content: '';
	content: none;
}
table {
	border-collapse: collapse;
	border-spacing: 0;
}
html {
	background-color: #333;
	font-family: Helvetica;
	font-size: 0.9em;
	color: #ddd;
}
pre {
	font-family: "Lucida Console", "Lucida Sans Typewriter", monaco, "Bitstream Vera Sans Mono", monospace;
	width: 96%;
	margin: 0 auto;
	background-color: white;
	color: black;
	margin-top: 20px;
	padding: 2%;
}

.center {
	text-align: center;
}

.container {
	padding-top: 50px;
	width: 59%;
	min-width: 400px;
	max-width: 600px;
	padding-bottom: 50px;
}


.container-section {
	position: relative;
	width: 95%;
	padding-top: 10;
	margin: 0 auto;
	margin-bottom: 50px;
}
.container-footer {
	font-size: 10px;
}

.container-section:not( :nth-child(1) ) {
	border-top: 5px solid white;
}

.container-dark-line {
	border-top: 5px solid #333;
}

.container-light-line {
	border-top: 5px solid #ccc;
}

h1, h2, h3, h4, h5, h6 {
	transition: font-size 0.2s;
	font-weight: bold;
	color: white;
	letter-spacing: -3px;
}


p {
	transition: font-size 0.2s,
			width 0.2s;
}

a {
	transition: background-color 0.2s
		  , color 0.2s;
}

h1 { font-size: 6em;  }
h2 { font-size: 5em; }
h3 { font-size: 4em; }
h4 { font-size: 3em; }
h5 { font-size: 2em; }

a {
	
	background-color: #333;
	color: white;
}

a:hover {
	background-color: white;
	color: black;
}

p {
	font-size: 1.4em;
	margin-top: 30px;
	letter-spacing: -0.5px;
}


</style>
</head>


<body>
<cfoutput>
	<div class="container">
		<div class="container-section">
			<h1>#model.greeting#</h1>
			<p>And welcome to <a href="http://mystframework.com">Myst</a>, an MVC web framework for sites using ColdFusion.</p>
			<p>You are currently looking at the example page for your new site located at <b>#model.site.dir#</b>, meaning that Myst was able to deploy your site correctly.</p>
			<p>To get rid of this page type the following in your terminal:
				<pre>myst --finalize #model.site.name#</pre>
			</p>
			<p>Happy coding!</p>
		</div>
		
		<!--- This is coming soon.
		<div class="container-section">
			<h4>Configuration</h4>
			<p>Below is some info about your site is currently configured.</p>
		</div>
		
		<div class="container-section">
			<h4>Resources</h4>
			<p>Follow the resources below to get started learning a bit more about you can best use Myst.</p>
		</div>
		--->
		
		<div class="container-section container-footer">
			<p>Proudly designed by <a href="http://collinsdesign.net">Tubular Modular Inc dba Collins Design</a></p>
		</div>
	</div>
</body>
</cfoutput>
</html>
