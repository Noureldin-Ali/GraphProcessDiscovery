# Enabling Multi-Process Discovery on Graph Databases
## Table of Content

<ul>
<li>Experiments
<ul>
<li>Memory: contains the results of the experiment applied on RDB and GDB</li>
<li>Time: contains the results of the experiment applied on PM4PY,RDB and GDB, also a script python of use PM4PY with XES</li>
</ul>
</li>
<li>Queries
<ul>
<li>GDB (Graph databases): contains all the queries (traditional and on the fly) run on the graph databases(BPI datasets)</li>
<li>RDB (Relational databases: query to extract Directly Follows Relation from relational databases(BPI datasets)</li>
</ul>
</li>
</ul>

## Installation

We used [Neo4j](https://neo4j.com/) 4.3.1 as a DBMS for Graph Databases.

For the experiments, we used [python](https://www.python.org/).
After install python, you need to download PM4PY library.
```sh
pip install pm4py
```
Also, We used [Microsoft SQL Server 2019](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) as a DBMS for Relational Databases. 


To download the datasets click [here](https://drive.google.com/drive/folders/1Zo23Uidml6z8P_u_WiFYqeA-RskMTc1T?usp=sharing), or contact me at ali.nour-eldin@bonitasoft.com.

After install the DBMS and download the datasets, for Neo4j, to restore the dataset,first open cypher-shell and run:
```
neo4j-admin load --from=$PWD/<dataset_name>.dump --database=neo4j --force
```
Then, you can run any query.


For Microsot SQL Server, to restore the database, run:
```
RESTORE DATABASE BPIDATASETS FROM DISK = '$PWD/databases.bak' WITH NORECOVERY
```
Then, you can run the query to extract directly follows relation.

## Development
After install Neo4j and restore the database, you can run different queries to extract directly follows graph from graph database. You just need to change the Object_FollowedBy relation and the type of object in same cases.

For on the fly query , you change the label the relation named "relation" from "AppFollowedBy" to target relation: 
```
...
MATCH (e1:Event)-[relation:AppFollowedBy]->(e2:Event)
WITH e1.activity AS cFrom, e2.activity AS cTo, count(*) AS count, events
...
```

For on the fly - intersection, you just need to change the type of objects:
```
...
MATCH (obj1:Object{Type:"Offer"})-[]->(obj2:Object{Type:"Application"})
...
```
For the traditional query, you need to change the relations "FollowedBy" and the type of objects. Like here, "OfferFollowedBy" and "ApplicationFollowedBy" relations, "Offer" and "Application" properties :
```
...
MATCH (e1S:Event)-[:AffectObject]->(:Object{Type:"Offer",ObjectID:baseObjects[0].ObjectID}),
(e1E:Event)-[:AffectObject]->(:Object{Type:"Offer",ObjectID:baseObjects[0].ObjectID}),
(e2S:Event)-[:AffectObject]->(:Object{Type:"Application",ObjectID:baseObjects[1].ObjectID}),
(e2E:Event)-[:AffectObject]->(:Object{Type:"Application",ObjectID:baseObjects[1].ObjectID})
WHERE NOT EXISTS((:Event)-[:OfferFollowedBy{ObjectID:baseObjects[0].ObjectID}]->(e1S)) 
AND NOT EXISTS((e1E)-[:OfferFollowedBy{ObjectID:baseObjects[0].ObjectID}]->(:Event)) 
AND NOT EXISTS((:Event)-[:ApplicationFollowedBy{ObjectID:baseObjects[1].ObjectID}]->(e2S)) 
AND NOT EXISTS((e2E)-[:ApplicationFollowedBy{ObjectID:baseObjects[1].ObjectID}]->(:Event)) 
...
```
