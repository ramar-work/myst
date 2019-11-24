Table of Contents
-----------------
- [summary](#summary)
	- [What is myst?](#what)
	- [Why should I use it?](#why)
- [setup](#setup)
	- [lucee](#lucee)
	- [coldfusion](#lucee)
	- [commandbox](#commandbox)
- [structure](#structure)
	- [top-level](#top-level)
	- [models](#app) (app/)
	- [assets](#assets) (assets/)
	- [components	](#components) (components/)
	- [files](#files) (files/)
	- [setup](#setup) (setup/)
	- [SQL](#sql) (sql/)
	- [std](#std) (std/)
	- [views](#views) (views/)
- [configuration (data.cfm)](#configuration)
	- [a breakdown](#breakdown)
	- [adding routes](#routes)
	- [datasources](#datasources)
	- [errors](#errors)
	- [closures](#closures)
- [the module](#module)
- [version control](#vcs)
	- [what Git tracks](#gitvcs)
- [examples](#examples)
	- [example API](#example-api)
	- [blogging engine](#example-blogging-engine)
	- [video game](#example-video-game)



## summary <a id=summary></a>

### what is myst? <a id="what"></a>

myst is a web framework intended for use with servers running CFML.   It is a
flexible solution to problems like creating an API for your next mobile
application, designing a CMS for your blog or company web page, or creating a
store for products.


## setup

Setting up myst on most Linux-based systems is easy.  You will only need git and
GNU make to get going.   Windows support is slightly less straightforward, but
as long as Git Bash or Cygwin is present on your system, you will have little
issue getting it going there as well.

### On Linux <a id="setup_linux"></a>

1. Clone the newest version of the repository.
	<pre>
	$ git clone https://github.com/tubular-modular/myst.git
	</pre>

1. Change into the directory and run `make && make install`
	<pre>
	$ make && make install
	</pre>

1. Create a new application.
	<pre>
	$ myst --create typical-app --folder $HOME/typical-app
	</pre>


### On OSX <a id="setup_osx"></a>

1. Clone the newest version of the repository.
	<pre>
	$ git clone https://github.com/tubular-modular/myst.git
	</pre>

1. Change into the directory and run `make && make install`
	<pre>
	$ make && make install
	</pre>

1. Create a new application.
	<pre>
	$ myst --create typicalApp --folder $HOME/typicalApp
	</pre>


### On Windows <a id="setup_windows"></a>

1. Clone the newest version of the repository.
	<pre>
	$ git clone https://github.com/tubular-modular/myst.git
	</pre>

1. Change into the directory and run `make && make install`
	<pre>
	$ make && make install
	</pre>

1. Create a new application.
	<pre>
	$ myst --create typical-app --folder $HOME/typical-app
	</pre>



## structure

myst applications are pretty simple to follow and figure out.  In the next few
paragraphs, we'll break down what all goes where.  To follow along, you can 
use the example project titled 'frogs' in myst's installation directory. 
Optionally, you can also create a new folder if you want something of your own
to play with.

### top-level <a id="top-level"></a>

To get an app running, myst relies on four files in the root directory of the
application being hosted.

file            | description
-----           | -----------
myst.cfc        | The primary component that powers everything.
index.cfm       | A stub meant only to initialize myst.
Application.cfc | A custom Application.cfc that allows our module to control errors and exceptions.
data.cfm        | A configuration file to help setup our app.


Applications have a specific directory for most of the different parts.

folder      | description
-----       | -----------
app         | All model files go here.
assets      | Any static assets go here.  Includes images, CSS, Javascript and video.
components  | All components go in this folder
files       | Uploaded files (and files needing private access) are placed here.
setup       | Setup scripts go here (right now can be written in any language) 
sql         | SQL files go here.
std         | myst's standard templates go here. 
tests       | Tests needed to run can go here.
views       | All view/template files go here. 

Notice that all of these folders have a primary purpose

### app <a id="app"></a>

The app folder contains all the model files used for our stuff.  Files located
here ought to never output anything to the browser.  During testing, results of 
files listed here can be dumped via the 'dumpModels=' key in data.cfm

![]()


### assets <a id="assets"></a>

myst, by default, will disallow access to all other folders in the
application's directory except this one.   Obviously, it needs some way to
bypass CFML and just serve static files.  HTML files, image files, documents and
whatever else that needs to be publically accessible can go in this directory.

For our frogs app, an `ls assets/*` will show us the static guts of our app.

<pre>
// List all the files under css, js and img
$ ls assets/\*

// Lots of files
assets/4xx-view.css
assets/5xx-view.css
assets/default.css

assets/css:

assets/img:
01-frog-day-gallery.adapt.1900.1.jpg
08_46MB-1000x469.jpg
...
white_lipped_tree_frog_3.jpg

assets/js:

</pre>

Notice that neither the Javascript nor CSS files are in their respective
folders.  myst assumes that you know how you want to organize things, and
won't place restrictions on you that would make that difficult.  For convience,
myst ships with a function called <i>link()</i> that takes one argument, the
relative path of the file you'd like to generate a reference to.


### components <a id="components"></a>

Components are ColdFusion's way of extending functionality via packages.  They
are a great way to organize reusable code and manage dependencies.  myst
allows you to include packages once and only once for efficiencie's sake by
adding them to data.cfm.  You can place the components you want in the
components directory and myst will include them in a specific namespace at
the start of Application cycle.


### files <a id="files"></a>

All private file access is done via this directory.  Let's say I want to get a
uploaded photos or something, they can all be placed here.  On Linux, this
cannot be a symbolic link.


### setup	 <a id="setup"></a>

Scripts needed to initialize commonly needed elements are all placed here.  At
the moment, there are no limitations on what file types are accepted here.


### sql <a id="sql"></a>

SQL files are placed here.  myst does not ship any ORM helpers at the moment,
so most of the database work is done through a function called <i>dbExec()</i>. 
It handles binding arguments and loading SQL via either a string or a file.


### std <a id="std"></a>

All of myst's standard templates sit in this directory, such as the 404 and
500 error pages.  If you would like to add your own templates, add them to the
user directory with the correct extension and filename.   So, for example, if
you want a custom 404 page, place your custom 404's .cfm template into
std/user/404.cfm

### views <a id="views"></a>

Finally, all CFML views end up in this directory.   Note: although myst
sticks to this common structure for most applications, you <i>can</i> just use
the views (or app) directory to write your applications.  There will be no
limitations on this.  However, please carefully consider if that is the best way
to maintain your application.  MVC (and other models) were created through the
hard work and thought of programmers before us.  They came to their conclusions
for a reason.


## configuration (data.cfm)

data.cfm is the primary means of configuring applications written with myst.
A couple of simple key-value structures are all that's needed to make a large
application with this toolkit.  Routing, datasources, and error handling are
just a few of the one-line configurations handled here.

### a breakdown <a id="breakdown"></a>

At the start of an application, data.cfm is loaded and parsed.  Any errors in
parsing will cause your CFML engine to stop and throw an exception.  If this
happens, find your syntax error and fix it so you can get rolling again.

A simple example data.cfm file will look something like the following (NOTE:
Comments have been removed for brevity):
<pre>
// data.cfm
manifest = {
	"cookie" = "3ad2d4dc34e75130c0c2f3c4bbb262481b49250261bcb8e6443728b63d24"
	,debug  = useDebug 
	,localdev  = [ "frogs.local:8888", "localhost:8888", "127.0.0.1:8888" ]
	,source = "frogs_db" 
	,base   = "/frogs/"
	,title  = "FrogsDB - A Site About Frogs and Their Wonders"
	,settings = {
		"verboseLog" = 0
		,"addLogLine" = 0
	}
	,data = {}
	,routes = {
		 default= { model="default", view = [ "master/head", "default", "master/tail" ] }
		,support= { model="support", view = [ "master/head", "support", "master/tail" ] }
		,register= { model="register", view = [ "master/head", "register", "master/tail" ] }
	}
}
</pre>

At the very least, the keys 'base' and 'routes' must be present in the
file.  Without the 'base' key, myst has no idea where your application root
actually is.  Without 'routes', myst does not know what to send a response
to.

A full list of keys supported are below.  If one of these is not enough, you can
specify your own using the same format as the file above.

key        | type     | required? | description
---------- | ----     | --------- | ----------- 
cookie     | string   | no        | A unique string recorded as the value for cookies.
debug      | boolean  | no        | A key to tell whether or not we should be in debug mode
base       | string   | yes       | The root of your application relative to the server root 
settings   | struct   | no        | ...
title      | string   | no        | A site title.
routes     | struct   | yes       | A struct of key-value pairs meant to serve as routes for your application. 
data       | struct   | no        | Symbolic names for database tables


### adding routes <a id="routes"></a>

### datasources <a id="datasources"></a>

### errors <a id="errors"></a>

### closures <a id="closures"></a>


## the module <a id="module"></a>

## version control <a id="vcs"></a>

### what git tracks <a id="gitvcs"></a>


## examples <a id="examples"></a>

### example api <a id="example-api"></a>

### blogging engine <a id="example-blogging-engine"></a>

### video game <a id="example-video-game"></a>


