#!/bin/bash -
# A script to test out creation of a new instance and database
NAME=cafe.local
DBNAME=cafe_db
DESCRIPTION="A site about Cafe Racers."

# Cleanup?
mysql --user=root --password=toor -e "DROP DATABASE IF EXISTS $DBNAME"
myst --disable $NAME
test -d /opt/myst/www/$NAME && rm -rf /opt/myst/www/$NAME


# Generate the instance
echo myst --create $NAME --description "$DESCRIPTION" --enable
myst --create $NAME --description "$DESCRIPTION" --enable || { echo 'step failed...'; exit 1; }

# Create a database (natively)
echo mysql --user=root --password=toor -e "CREATE DATABASE $DBNAME";
mysql --user=root --password=toor -e "CREATE DATABASE $DBNAME" || { echo 'step failed...'; exit 1; }

# Create a datasource
echo mystdb --generate $DBNAME --mysql --user "local" --password "local" 
mystdb --generate $DBNAME --mysql --user "local" --password "local" || { echo 'step failed...'; exit 1; }

# Install the CMS module
echo mystmod -i cms --at $NAME -s $DBNAME --setup
mystmod -i cms --at $NAME -s $DBNAME --setup || { echo 'step failed...'; exit 1; }

# Add to /etc/hosts
# ... no good way to do this yet
echo "Restarting myst & Apache daemons."
sudo systemctl restart myst 
sudo systemctl restart lupache 
