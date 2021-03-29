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
CREATE (game)-[:DEVELOPED_BY]->(dev)
CREATE (game)-[:PUBLISHED_BY]->(pub)
CREATE (game)-[:RUNS_ON]->(plat)
CREATE (game)-[:IS]->(genre);

// Application de l'algorithme Node Similarity
:param config => ({similarityCutoff: 0.1,degreeCutoff: 1,nodeProjection: '*',relationshipProjection: {relType: {type: '*',orientation: 'NATURAL',properties: {}}},writeProperty: 'value',writeRelationshipType: 'SIMILARITY'});
:param communityNodeLimit => ( 10);

CALL gds.nodeSimilarity.write($config);;

//Affichage du résulat
MATCH (from)-[rel:`SIMILARITY`]-(to)
WHERE exists(rel.`value`)
RETURN from, to, rel.`value` AS similarity
ORDER BY similarity DESC;;

//Application de l'algorithme Modularity Optimization
:param limit => ( 42);
:param config => ({similarityCutoff: 0.1,degreeCutoff: 1,nodeProjection: '*',relationshipProjection: {relType: {type: '*',orientation: 'NATURAL',properties: {}}},writeProperty: 'score',writeRelationshipType: 'SIMILAR_JACCARD'});
:param communityNodeLimit => ( 10);