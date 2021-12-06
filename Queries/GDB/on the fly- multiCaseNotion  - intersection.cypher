//create virtual events
MATCH(event:Event)
WITH COLLECT(distinct event.activity) AS events
WITH [aName IN events | apoc.create.vNode(['Event'],
{name:aName})] AS activityNodes
WITH apoc.map.groupBy(activityNodes,'name') AS events
//get artifacts 
MATCH (obj1:Object{Type:"Offer"})-[]->(obj2:Object{Type:"Application"})
WITH distinct [obj1,obj2] AS baseObjects,events
// get events connected by ANY relation
MATCH (obj1:Object)<-[:AffectObject]-(e1:Event)-[relation]->(e2:Event)-[:AffectObject]->(obj2:Object)
//aggrigate object of each event AND the relation between them
WITH  e1,COLLECT(obj1) AS objectList1, e2,COLLECT(obj2) AS objectList2,baseObjects,COLLECT(relation) AS c,events
//condition on the list of artifacts of each events AND on the relation betwen events
WHERE ALL(a1 IN baseObjects WHERE a1 IN objectList1) AND ALL(a1 IN baseObjects WHERE a1 IN objectList2) AND ANY(x IN c WHERE x.artifactID IN [baseObjects[0].ObjectID,baseObjects[1].ObjectID])
WITH e1,e2,baseObjects,events
//create relation
WITH e1.activity AS cFrom, e2.activity AS cTo, count(*) AS count, events
RETURN events[cFrom] AS from, events[cTo] AS to, apoc.create.vRelationship(events[cFrom],'DF',{frequency:count},events[cTo]) AS rel;