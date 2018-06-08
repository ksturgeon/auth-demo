#!/bin/bash

#### MapR-DB Table permissions are enforced at the filesystem ###

# Modify the imported table to allow public read access to the default column family
echo "Set a Table Access Control Expression to allow public read access"
echo "maprcli table cf edit -path /demo/demo-table/yelp-business-table -cfname default -readperm 'p'"
maprcli table cf edit -path /demo/demo-table/yelp-business-table -cfname default -readperm 'p'

# Restrict "address" field to just mapr user
echo "Restrict access to the address field to just mapr user"
echo "maprcli table cf colperm set -path /demo/demo-table/yelp-business-table -cfname default -name address -readperm 'u:mapr'"
maprcli table cf colperm set -path /demo/demo-table/yelp-business-table -cfname default -name address -readperm 'u:mapr'

echo "same for attributes field - shows better"
echo "maprcli table cf colperm set -path /demo/demo-table/yelp-business-table -cfname default -name attributes -readperm 'u:mapr'"
maprcli table cf colperm set -path /demo/demo-table/yelp-business-table -cfname default -name attributes -readperm 'u:mapr'

#### Drill Views - allows for chained impersonation ####

# Set an ACE on the Drill View
echo "Set an ACE on the Drill View so public has access to the view but not the underlying data directly"
echo "hadoop mfs -setace -readfile 'p' /demo/demo-views/short_business.view.drill"
hadoop mfs -setace -readfile 'p' /demo/demo-views/short_business.view.drill
