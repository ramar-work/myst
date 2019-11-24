# Extensions / Modules

Extensions and modules are run via filesystem now.
Eventually, they'll be uploaded to http://repo.mystframework.com (or mystframework.com/repo)


## Installing New Modules to New Instances

mystmod --install $MODNAME --to $INSTANCE


## Creating New Modules 

mystmod \
	--create $MODNAME \
	--author $AUTHORNAME \
	--folder $HOME/www/repo.mystframework.local/repo/$MODNAME \
	--description "What the hell does this really do?"
