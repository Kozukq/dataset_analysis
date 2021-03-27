// Nettoyage de la BD
MATCH (n) 
DETACH DELETE n;

// Création des noeuds et relations
LOAD CSV 
WITH HEADERS FROM 'file:///dataset.csv' AS line
WITH line
WHERE line.Developer IS NOT NULL 
AND line.Publisher IS NOT NULL 
AND line.Platform IS NOT NULL 
AND line.Genre IS NOT NULL
CREATE (game:Game {name: line.Name, year: toInteger(line.Year_of_Release), sales: toFloat(line.Global_Sales), score: toInteger(line.Critic_Score)})
MERGE (dev:Developer {name: line.Developer})
MERGE (pub:Publisher {name: line.Publisher})
MERGE (plat:Platform {name: line.Platform})
MERGE (genre:Genre {name: line.Genre})
CREATE (dev)-[:DEVELOPED]->(game)
CREATE (game)-[:DEVELOPED_BY]->(dev)
CREATE (pub)-[:PUBLISHED]->(game)
CREATE (game)-[:PUBLISHED_BY]->(pub)
CREATE (game)-[:RUNS_ON]->(plat)
CREATE (plat)-[:RUNS]->(game)
CREATE (game)-[:IS]->(genre)
CREATE (genre)-[:HAS]->(game);

:param limit => ( 42);
:param config => ({similarityCutoff: 0.1,degreeCutoff: 1,nodeProjection: '*',relationshipProjection: {relType: {type: '*',orientation: 'NATURAL',properties: {}}},writeProperty: 'score',writeRelationshipType: 'SIMILAR_JACCARD'});
:param communityNodeLimit => ( 10);
CALL gds.graph.create("in-memory-graph-1616863943532", $config.nodeProjection, $config.relationshipProjection, {});
CALL gds.nodeSimilarity.write("in-memory-graph-1616863943532", {similarityCutoff: 0.1, degreeCutoff: 1, writeProperty: "score", writeRelationshipType: "SIMILAR_JACCARD"});
MATCH (from)-[rel:`SIMILAR_JACCARD`]-(to)
WHERE exists(rel.`score`)
RETURN from, to, rel.`score` AS similarity
ORDER BY similarity DESC
LIMIT toInteger($limit);
CALL gds.graph.drop("in-memory-graph-1616863943532");
:param limit => ( 70);
:param config => ({nodeProjection: 'Game',relationshipProjection: {relType: {type: 'SIMILAR_JACCARD',orientation: 'UNDIRECTED',properties: {}}},relationshipWeightProperty: null,writeProperty: 'communaute'});
:param communityNodeLimit => ( 30);
CALL gds.labelPropagation.write($config);
MATCH (node:`Game`)
WHERE exists(node.`communaute`)
WITH node.`communaute` AS community, collect(node) AS allNodes
RETURN community, allNodes[0..$communityNodeLimit] AS nodes, size(allNodes) AS size
ORDER BY size DESC
LIMIT toInteger($limit);