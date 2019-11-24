summary <a id=summary></a>
-------

### what is myst? <a id="summary.what"></a>

myst is a web framework intended for use with servers running CFML.   It is a
flexible solution to problems like creating an API for your next mobile
application, designing a CMS for your blog or company web page, or creating a
store for products.


setup<a id="setup"></a>
-----

Setting up myst on most Linux-based systems is easy.  You will only need git and
GNU make to get going.   Myst can be downloaded <a
href="http://mystframework.com">here</a>
or via Github at <a href="https://github.com/tubularmodular/myst">https://github.com/tubularmodular/myst</a>.  
You can get the latest version up and running by using the following on your system:

1. If you are on Linux, go to your home directory and grab the latest copy.
	<pre>
	$ cd ~
	$ git clone https://github.com/tubularmodular/myst.git
	</pre>
	
	If you do not have git installed, you may also download directly from the home page. 
	<pre>
	$ cd ~
	$ wget -O myst.tar.gz http://mystframework.com/assets/myst.tgz
	$ tar xzf myst.tar.gz
	</pre>

2. Now, we can install Myst and it's accompanying files.   Notice we use sudo to
	assume the role of an administrator for the install.
	<pre>
	$ cd myst
	$ sudo make install
	</pre>

	If you decide that you don't like Myst or run into some sort of configuration
	problem, you can delete the installed files by running:
	<pre>
	$ sudo make uninstall
	</pre>

3. Myst has been heavily tested with Tomcat and Apache and running it with either
	 of those servers will yield the best results.  If you do not have Apache
	already running on your system, it will be easiest to use Lucee's built-in
	Tomcat server.  The following commands will install Myst in your system's /opt 
	directory.
	<pre>
	# Output of this command will let you know that Myst was
	# installed and is in your system $PATH
	$ myst -h
	$ mystinstall --full-install --prefix /opt/myst --user http
	</pre>


### Builds On <a id="setup.builds"></a>

Myst is administered via shell script right now, and has been tested most
heavily on different distributions of Linux.  I plan to resume Apple OS, 
Cygwin and Windows 10 testing in the next two months.   However, this also means
that Linux users will have the best results with this application for a little
while.

