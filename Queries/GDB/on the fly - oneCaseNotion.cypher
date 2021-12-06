//on the fly - one case notion
//create virtual events
MATCH(event:Event)
WITH collect(distinct event.activity) AS events
WITH [eName IN events | apoc.create.vNode(['Event'],
{activityName:eName})] AS EventNodes
WITH apoc.map.groupBy(EventNodes,'activityName') AS events

//create DFG
MATCH (e1:Event)-[relation:AppFollowedBy]->(e2:Event)
WITH e1.activity AS cFrom, e2.activity AS cTo, count(*) AS count, events
RETURN events[cFrom] AS from, events[cTo] AS to, apoc.create.vRelationship(events[cFrom],'DF',{frequency:count},events[cTo]) AS rel;