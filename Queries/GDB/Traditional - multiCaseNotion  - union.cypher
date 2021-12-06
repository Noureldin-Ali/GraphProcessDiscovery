//create virtual events
MATCH(event:Event)
WITH COLLECT(distinct event.activity) AS events
WITH [eName IN events | apoc.create.vNode(['Event'],
{activityName:eName})] AS eventNodes
WITH apoc.map.groupBy(eventNodes,'activityName') AS events
//get objects
MATCH (obj1:Object{Type:"Offer"})-[]->(obj2:Object{Type:"Application"})
WITH distinct [obj1,obj2] AS baseObjects,events
//get start AND END node of 2 objects
MATCH (e1S:Event)-[:AffectObject]->(:Object{Type:"Offer",ObjectID:baseObjects[0].ObjectID}),
(e1E:Event)-[:AffectObject]->(:Object{Type:"Offer",ObjectID:baseObjects[0].ObjectID}),
(e2S:Event)-[:AffectObject]->(:Object{Type:"Application",ObjectID:baseObjects[1].ObjectID}),
(e2E:Event)-[:AffectObject]->(:Object{Type:"Application",ObjectID:baseObjects[1].ObjectID})
WHERE NOT EXISTS((:Event)-[:OfferFollowedBy{ObjectID:baseObjects[0].ObjectID}]->(e1S)) 
AND NOT EXISTS((e1E)-[:OfferFollowedBy{ObjectID:baseObjects[0].ObjectID}]->(:Event)) 
AND NOT EXISTS((:Event)-[:ApplicationFollowedBy{ObjectID:baseObjects[1].ObjectID}]->(e2S)) 
AND NOT EXISTS((e2E)-[:ApplicationFollowedBy{ObjectID:baseObjects[1].ObjectID}]->(:Event)) 
//get path of 2 objects
MATCH path1 = (e1S)-[:OfferFollowedBy*{ObjectID:baseObjects[0].ObjectID}]->(e1E),
    path2=(e2S)-[:ApplicationFollowedBy*{ObjectID:baseObjects[1].ObjectID}]->(e2E)
WITH NODES(path1) AS object1,NODES(path2) AS object2,baseObjects,events
//Union
WITH apoc.coll.union(object1,object2) AS outEvents,baseObjects,events
CALL{
    WITH outEvents,baseObjects
    UNWIND outEvents AS x
    MATCH (x)-[:AffectObject]->(obj:Object)
    WITH x,COLLECT(obj) AS obj,baseObjects
    WHERE NOT ANY(x IN baseObjects WHERE ANY(i IN obj WHERE i.Type=x.Type AND i<>x) 
                                        AND NOT ANY(i IN obj WHERE i=x))
    return x AS event
}
WITH COLLECT(event) AS outEvents,baseObjects,events
WITH apoc.coll.sortNodes(outEvents, 'timestamp') AS outEvents,baseObjects,events
//convert to pair of events
WITH baseObjects,apoc.coll.pairsMin(outEvents) AS pairsOfEventConnected,events
UNWIND pairsOfEventConnected AS pair
//create virual relation
WITH pair[0].activity AS cFrom, pair[1].activity AS cTo, count(*) AS count, events
RETURN events[cFrom] AS from, events[cTo] AS to, apoc.create.vRelationship(events[cFrom],'DF',{frequency:count},events[cTo]) AS rel;

