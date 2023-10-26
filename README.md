myst 
====

## NOTE 

This project has been sunset, as I rarely write anything in Lucee or Coldfusion these days.   This framework was replaced by an engine called <a href="https://github.com/ramar-work/hypno">Hypno</a> which uses Lua for business logic and builts upon many of the ideas formulated here in Myst.  You might like it.  If I were you, I'd check it out.  Seriously.


Summary
-------

Myst is a web framework for CFML based webservers such as ColdFusion and Lucee.  
The intent of this application is to facilitate the adoption of model-view-controller based web development for ColdFusion applications.  This helps enforce seperation of concerns and greatly helps maintenance of applications written in ColdFusion.

Installation
------------

<!-- Myst can be downloaded via its <a href="http://mystframework.com">home page</a> -->
Myst can be downloaded via Github at <a href="https://github.com/ramar-work/myst">https://github.com/ramar-work/myst</a>.  You can clone the latest version by using the following on your system:

NOTE: These instructions are best executed on a Linux machine (Arch or Ubuntu are preferable.)

1. If you are on Linux, go to your home directory and grab the latest copy.
	<pre>
	$ cd ~
	$ git clone https://github.com/ramar-work/myst.git
	</pre>
	
	If you do not have git installed, you may also download directly from the home page. 
	<pre>
	$ cd ~
	$ wget -O myst.tar.gz http://mystframework.com/assets/myst-v0.2.tar.gz
	$ tar xzf myst.tar.gz
	</pre>

2. Now, we can install Myst and it's accompanying files. 
	<pre>
	$ cd myst 
	$ make
	</pre>

3. Provided there were no errors, you can now run install as root (or use sudo)
	<pre>
	$ make install    # You'll probably need to be root
	</pre>

	If you decide that you don't like the framework or run into some sort of configuration
	problem, you can delete the installed files by running:
	<pre>
	$ make uninstall  # NOTE: You'll probably need to be root again
	</pre>


### Notes 

Myst only builds on Linux for now.  

OSX is as yet untested, and users may run into general issues with Lucee. 

Windows is also untested, but Cygwin users may be in good shape.


Setting up your first Myst project
----------------------------------

### Introduction

For the purposes of this quick walkthrough, let's assume we want to create a
quick image gallery.  We're going to call it 'Gal Gadot'.


### Create an instance 

Myst can generate a new folder with all of the necessary components needed to work correctly. 

<pre>
myst --create gal_gadot.gallery --description "An image gallery" --enable
</pre>

The --create flag will create a new directory containing the components needed to make the site work.   The --description flag will add a short description of the site for our purposes in the future.   

Finally, the --enable flag will "activate" the website and allow you to see page output locally.  Myst ships with its own copy of Apache and similarly to a Debian /Ubuntu setup out of the box, sites can be enabled or disabled at will.


### Create a Database

ColdFusion supports MySQL, PostgreSQL, SQL server and Oracle database servers.  This example will use MySQL.

We will first create the database using the database driver's native tooling.  If you have any other roles that need to be created for this database, now would be a good time to do them. 

<pre>
mysql -u <your-username> --password=<your-password> -e 'CREATE DATABASE gal_gadot_db'
</pre>

Then we can use Myst to tell Lucee about how to connect to it.

<pre>
mystdb --generate gal_gadot_db --user gal_user --password=gal_pass
</pre>

The name you use when generating is what Lucee will use as a datasource.


### Enable DNS for your new site

After creating the new site, Lucee needs to scan and initialize the new directory.  Apache will also need to be restarted because there is a new host to listen out for.   

On a simple local development setup, you can edit /etc/hosts and add the host 'gal_gadot.gallery' there.

Adding the new record to a local DNS server is a FAR better option, but beyond the scope of this simple documentation.


### Restart Server

After adding the domain name, restart both of these services.

<pre>
sudo systemctl restart myst 
sudo systemctl restart lupache 
</pre>



Doing real work
---------------

### Models

Myst uses components to handle generating models.  A template for a simple model would look something like the following:
<pre>
component extends="std.base.model" {
	function init( myst, model ) {
		Super.init(myst);
		return {}
	}	
}
</pre>

Obviously, this model returns nothing, so let's try something a bit more interesting.
<pre>
component extends="std.base.model" {
	function init( myst, model ) {
		Super.init(myst);
		return {
			images = [ "1.jpg", "2.jpg", "3.jpg" ]
		}
	}	
}
</pre>

### Views

### Database Queries 

### Routes 


Extensions
----------



<link href="style.css" rel="stylesheet">
