<!---
/* ---------------------------------------------- *
views-default.cfm
=================

Author
------
Antonio R. Collins II (rc@tubularmodular.com, ramar.collins@gmail.com)

Copyright
---------
Copyright 2016-Present, "Tubular Modular"
Original Author Date: Tue Jul 26 07:26:29 2016 -0400

Summary
-------
Default 'It Works!' style page for successful 
myst deployments. 

 * ---------------------------------------------- */
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
	font-family: Helvetica;
	background-color: #ddd;
}
pre {
	font-family: "Lucida Console", "Lucida Sans Typewriter", monaco, "Bitstream Vera Sans Mono", monospace;
	width: 95%;
	margin: 0 auto;
	background-color: white;
	color: black;
	margin-top: 10;
	padding: 5;
}
.center {
	text-align: center;
}
.container {
	width: 59%;
	background-color: #333;
	color: white;
	height: 100%;
	float: left;
}
.other-container {
	position: relative;
	width: 39%;
	padding-top: 10;
	margin-bottom: 10;
	float: right;
}
.container-section {
	position: relative;
	width: 95%;
	padding-top: 10;
	margin: 0 auto;
	margin-bottom: 10;
}

.container-dark-line {
	border-top: 5px solid #333;
}

.container-light-line {
	border-top: 5px solid #ccc;
}

.container p {
	font-size: 1.5em;
}

h1, h2, h3, h4, h5 {
	transition: font-size 0.2s;	
}

p {
	transition: font-size 0.2s,
							width 0.2s;
}

a {
	transition: background-color 0.2s,
							color 0.2s;
}

h1 { font-size: 16em; font-weight: bold; text-align: center; }
h2 { font-size: 5em; }
h3 { font-size: 4em; }
h4 { font-size: 3em; }
h5 { font-size: 2em; }

a {
	font-family: "Lucida Console", "Lucida Sans Typewriter", monaco, "Bitstream Vera Sans Mono", monospace;
	line-height: 40px;
	background-color: #333;
	font-size: 1.4em;
	color: white;
	text-align: center;
	padding: 10px;
}

a:hover {
	background-color: white;
	color: black;
}

p {
	font-family: "Lucida Console", "Lucida Sans Typewriter", monaco, "Bitstream Vera Sans Mono", monospace;
	font-size: 1.4em;
	margin-top: 30px;
}

ul li {
	margin: 5;
	margin-left: 0;
}

.gets
{
	transition: display 0.2s;
	display: none;
}


/*mobile*/
@media ( max-width: 736px ) {
	.container {
		width: 100%;
		height: 100%;
		padding-bottom: 20px;
	}

	.other-container {
		background-color: #ccc;
		width: 100%;
		height: 100%;
		padding-bottom: 20px;
	}

	h1 { font-size: 8em; 
			 font-weight: bold; padding-bottom: 30; padding-top: 100px; }

	.gets
	{
		display: block;
		position: absolute;
		bottom: 10;
		right: 10;
	}
}

@media (min-width: 737px) and ( max-width: 1200px ) {
	h1 { font-size: 10em; 
			 font-weight: bold; 
			 padding-top: 100px; }
}
</style>
</head>


<body>
<cfset model = #getModel().default#>
<cfoutput>
	<div class="container">
		<div class="container-section">
			<h1>#model.greeting#</h1>
		</div>
		<div class="container-section container-less container-light-line center">
			<p>And welcome to myst, an MVC web framework for sites driven by CFML</p>
		</div>
		<a class="gets" href="##gets">More</a>
	</div>

	<div class="other-container">
		<div id="gets" class="container-section">
			<p>You are currently looking at an example web page, meaning that myst was able to deploy your site correctly.</p>
			<p>To get rid of this page type the following in your terminal:
				<pre>myst --finalize /this/directory</pre>
			</p>
		</div>

		<div class="container-section container-dark-line">
			<p>
				If you're new here, check out some of these resources to get up to speed:
			<ul>
				<li><a href="http://ramarcollins.com/myst">Quick-start Tutorial</a></li>
				<li><a href="http://ramarcollins.com/myst##reference">Reference</a></li>
				<li><a href="http://ramarcollins.com/myst##examples">Examples</a></li>
			</ul>
			</p>
		</div>

		<div class="container-section container-dark-line">
			<p>Happy coding!</p>
		</div>
	</div>

</body>
</cfoutput>
</html>
