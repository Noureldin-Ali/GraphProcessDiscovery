//create virtual events
MATCH(event:Event)
WITH COLLECT(DISTINCT event.activity) AS events
WITH [eName IN events | apoc.create.vNode(['Event'],
{activityName:eName})] AS eventNodes
WITH apoc.map.groupBy(eventNodes,'activityName') AS events

//get Objects
MATCH (obj1:Object{Type:"Offer"})-[]->(obj2:Object{Type:"Application"})
WITH distinct [obj1,obj2] AS baseObjects,events

//get start AND END node of 2 Objects
MATCH (e1S:Event)-[:AffectObject]->(:Object{Type:"Offer",ObjectID:baseObjects[0].ObjectID}),
(e1E:Event)-[:AffectObject]->(:Object{Type:"Offer",ObjectID:baseObjects[0].ObjectID}),
(e2S:Event)-[:AffectObject]->(:Object{Type:"Application",ObjectID:baseObjects[1].ObjectID}),
(e2E:Event)-[:AffectObject]->(:Object{Type:"Application",ObjectID:baseObjects[1].ObjectID})
WHERE NOT EXISTS((:Event)-[:OfferFollowedBy{ObjectID:baseObjects[0].ObjectID}]->(e1S)) 
AND NOT EXISTS((e1E)-[:OfferFollowedBy{ObjectID:baseObjects[0].ObjectID}]->(:Event)) 
AND NOT EXISTS((:Event)-[:ApplicationFollowedBy{ObjectID:baseObjects[1].ObjectID}]->(e2S)) 
AND NOT EXISTS((e2E)-[:ApplicationFollowedBy{ObjectID:baseObjects[1].ObjectID}]->(:Event)) 

//get path of 2 Objects
MATCH path1 = (e1S)-[:OfferFollowedBy*{ObjectID:baseObjects[0].ObjectID}]->(e1E),
    path2=(e2S)-[:ApplicationFollowedBy*{ObjectID:baseObjects[1].ObjectID}]->(e2E)
WITH NODES(path1) AS objects1,NODES(path2) AS objects2,baseObjects,events

//intersection
WITH apoc.coll.intersection(objects1,objects2) AS outObjects,baseObjects,events
WITH apoc.coll.sortNodes(outObjects, 'timestamp') AS outObjects,baseObjects,events
//convert to pair of events
WITH baseObjects,apoc.coll.pairsMin(outObjects) AS pairsOfEventConnected,events
UNWIND pairsOfEventConnected AS pair
//create virual relation
WITH pair[0].activity AS cFrom, pair[1].activity AS cTo, count(*) AS count, events
RETURN events[cFrom] AS from, events[cTo] AS to, apoc.create.vRelationship(events[cFrom],'DF',{frequency:count},events[cTo]) AS rel;