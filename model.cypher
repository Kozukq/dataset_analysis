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
CREATE (pub)-[:PUBLISHED]->(game)
CREATE (game)-[:RUNS_ON]->(plat)
CREATE (game)-[:IS]->(genre);