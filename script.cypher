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
CREATE (game:Game {
  name: line.Name,
  year: toInteger(line.Year_of_Release),
  sales: toFloat(line.Global_Sales),
  score: toInteger(line.Critic_Score)
  })
MERGE (dev:Developer {name: line.Developer})
MERGE (pub:Publisher {name: line.Publisher})
MERGE (plat:Platform {name: line.Platform})
MERGE (genre:Genre {name: line.Genre})
CREATE (game)-[:DEVELOPED_BY]->(dev)
CREATE (game)-[:PUBLISHED_BY]->(pub)
CREATE (game)-[:RUNS_ON]->(plat)
CREATE (game)-[:IS]->(genre);

// Node Similarity
:param config => ({
  similarityCutoff: 0.1,
  degreeCutoff: 1,
  nodeProjection: '*',
  relationshipProjection: {
    relType: {
      type: '*',
      orientation: 'NATURAL',
      properties: {}
    }
  },
  writeProperty: 'value',
  writeRelationshipType: 'SIMILARITY'
});
CALL gds.nodeSimilarity.write($config);

// Modularity Optimization
:param config => ({
  nodeProjection: 'Game',
  relationshipProjection: {
    relType: {
      type: 'SIMILARITY',
      orientation: 'NATURAL',
      properties: {
        value: {
          property: 'value',
          defaultValue: 1
        }
      }
    }
  },
  relationshipWeightProperty: 'value',
  seedProperty: '',
  maxIterations: 10,
  tolerance: 0.0001,
  writeProperty: 'community'
});
CALL gds.beta.modularityOptimization.write($config);

// N’ayant pas trouvé comment exécuter le script principal tout en permettant un affichage dynamique, les requêtes d'affichage seront
// à retrouver dans la dernière partie du rapport (Analyse des résultats) et seront à exécuter à la main dans le Browser de Neo4j.