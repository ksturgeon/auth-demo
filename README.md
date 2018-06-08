# Helper scripts to demonstrate data authorization in a MapR Cluster

1.  Unzip the business.json.gzip file ```gunzip business.json.zip```
2.  If needed, run the ```setup-user.sh``` script to add a user and group 'user1:group1' - not necessary if you have other users configured in the cluster.
3.  Modify the ```setup-data.sh``` script - replace the IP address in the sqlline command with one of the drillbit IPs for your cluster
4.  Run the ```setup-data.sh``` script.  This will;
  a.  Create appropriate volumes - note one of them "/demo-data" is created with restrictive permissions to simulate a "raw" landing zone for data.
  b.  Takes the uncompressed json file and copies it to this restrictive volume.
  c.  Runs a mapr command to load this json file into a MapR-DB Document Database.
  d.  Creates a Drill View with a subset of data, and moves this into its own volume.
   
**At this point, data exists in the MapR filesystem in two formats - raw file data (/demo/demo-data/business.json) and a MapR-DB database table (/demo/demo-table/yelp-business-table).  
**Because of the Volume permissions, and the default permissions in the MapR Databse, ONLY the "mapr" user has access to this data.

Try this;

  A.  Connect to Drill as "mapr" user (if using Drill 1.12 or greater, you can use the web UI and provide an identity when running the query) via sqlline ```sqlline -u jdbc:drill:drillbit=<DRILLBITHOST>:31010 -n mapr```
  
  B.  Query the file data ```>select * from dfs.`/demo/demo-data/business.json` limit 10;```
  
  C.  Query the DB Table ```>select * from dfs.`/demo/demo-table/yelp-busines-table` limit 10;```
  
  D.  Disconnect from sqlline ```>!quit```
  
  E.  Reconnect using a different user (user1 if that's what you've set up - or any other user should work) ```sqlline -u jdbc:drill:drillbit=<DRILLBITHOST>:31010 -n user1```
  
  F.  Run the same queries in A&B - note you cannot access the file, and only the document ID is returned for the DB table.  You could further restrict access by default to the DB table by setting up the Volume ACE to not be 'p' (public)
  
  G.  Extra Credit - if you log into a terminal session as another user, you can't even "ls" the /mapr/clustername/demo/demo-data/ directory.
  

Let's create some better access controls.

5.  Run the setup-data-access.sh script.  This will;
    a.  Configure the MapR-DB to allow for public access to the data.
    
    b.  Restrict certain fields - allow only the "mapr" user to view the "address" and "attributes" fields.
    
    c.  Create an Access Control Expression to allow public access to the Drill View which only returns a small number of fields.  As above, the "raw" data is restricted, but the view (which only exposes a few fields) is available to the public.
    

Try this now;
  A.  Connect to Drill as "user1" or any other user
  
  B.  Query the view ```>select * from dfs.`/demo/demo-views/short_business` limit 10;```  Note you can only see a few fields.
  
  C.  Query the MapR-DB Table ```>select * from dfs.`/demo/demo-table/yelp-business-table` limit 10;```  Note the "address" and "attributes" fields are missing.
  

Summary:
Basically, we have restricted access in a number of different ways;
 - At the file system level via "Access Control Expressions".  Only allowing user "mapr" access to the raw data.  This is a restriction at the storage level - NO user other than "mapr" can read the data.
 - At the Database level.  As above, no user or application can read the data.
 - At the Drill level via views.  Drill can perform "chained" impersonation - where users can access the view, but the view needs to access data restricted to specific users.  In this case, Drill will impersonate user "mapr" to retrieve the raw data that makes up the view.


NOT COVERED.  Specific Drill UDFs to create masked data.  Please see the blog post here: https://community.mapr.com/docs/DOC-1636
