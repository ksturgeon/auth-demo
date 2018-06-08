#!/bin/bash

# Create volumes for data input and processed
echo "Create volumes for data input and processed data - set appropriate access controls"

echo "maprcli volume create -name demo -path /demo -readAce 'p' -writeAce 'p'"
maprcli volume create -name demo -path /demo -readAce 'p' -writeAce 'p'

echo "maprcli volume create -name demo-views -path /demo/demo-views -readAce 'p' -writeAce 'p'"
maprcli volume create -name demo-views -path /demo/demo-views -readAce 'p' -writeAce 'p'

echo "maprcli volume create -name demo-data -path /demo/demo-data -readAce 'u:mapr' -writeAce 'u:mapr'"
maprcli volume create -name demo-data -path /demo/demo-data -readAce 'u:mapr' -writeAce 'u:mapr'

echo "maprcli volume create -name demo-table -path /demo/demo-table -readAce 'p' -writeAce 'p'"
maprcli volume create -name demo-table -path /demo/demo-table -readAce 'p' -writeAce 'p'

# Put the json file into the data directory
echo "Put the json file into the data directory"
echo "hadoop fs -put business.json /demo/demo-data/"
hadoop fs -put business.json /demo/demo-data/

# Create json table with the demo data
echo "Create json table with the demo data"
echo "mapr importJSON -idfield "business_id" -src /demo/demo-data/business.json -dst /demo/demo-table/yelp-business-table"
mapr importJSON -idfield "business_id" -src /demo/demo-data/business.json -dst /demo/demo-table/yelp-business-table

# Create drill views - replace with your IP address - could also use a zk connection
echo "Create Drill Views - replace with the IP of a drillbit"
echo "sqlline -u jdbc:drill:drillbit=172.16.2.222:31010 -n mapr --run=create-views.sql"
sqlline -u jdbc:drill:drillbit=172.16.2.222:31010 -n mapr --run=create-views.sql

# Since we can rely on tmp workspace as writeable, we created the view there, now copy to the right volume
echo "We created the view in /tmp, now copy to the volume we created"
echo "hadoop fs -cp /tmp/short_business.view.drill /demo/demo-views/"
hadoop fs -cp /tmp/short_business.view.drill /demo/demo-views/
