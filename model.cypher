// Nettoyage de la BD
MATCH (n) DETACH
DELETE n;

// Création des noeuds
LOAD CSV WITH HEADERS FROM 'file:///dataset.csv' AS line
CREATE
	(:Game {name: line.Name, publisher: line.Publisher, sales: line.Global_Sales})
MERGE
	(:Publisher {name: line.Publisher});

// Création de la relation représentant les ventes
MATCH
	(p:Publisher), (g:Game)
WHERE
	p.name = g.publisher
CREATE
	(p)-[:SALES {value: g.sales}]->(g);