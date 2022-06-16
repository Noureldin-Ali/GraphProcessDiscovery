//create virual events
MATCH(event:Event)
WITH COLLECT(distinct event.activity) AS events
WITH [eName IN events | apoc.create.vNode(['Event'],
{activityName:eName})] AS eventNodes
WITH apoc.map.groupBy(eventNodes,'activityName') AS events

//get object
MATCH (object:Object{Type:"App"})
WITH object.ObjectID AS baseObject,events

//get START and END node
MATCH (e1:Event)-[:AffectObject]->(:Object{Type:"App",ObjectID:baseObject}),(e2:Event)-[:AffectObject]->(:Object{Type:"App",ObjectID:baseObject})
WHERE NOT EXISTS((:Event)-[:AppFollowedBy{ObjectID:baseObject}]->(e1)) 
AND NOT EXISTS((e2)-[:AppFollowedBy{ObjectID:baseObject}]->(:Event)) 
WITH baseObject,e1,e2,events

//get path between start AND END
MATCH path = (e1)-[:AppFollowedBy*{ObjectID:baseObject}]->(e2)
WITH NODES(path) AS trace,events,baseObject

//convert trace to pair of events
WITH baseObject,apoc.coll.pairsMin(trace) AS pairsOfEventConnected,events
UNWIND pairsOfEventConnected AS pair
WITH pair[0].activity AS cFrom, pair[1].activity AS cTo, count(*) AS count, events
RETURN events[cFrom] AS from, events[cTo] AS to, apoc.create.vRelationship(events[cFrom],'DF',{frequency:count},events[cTo]) AS rel;
