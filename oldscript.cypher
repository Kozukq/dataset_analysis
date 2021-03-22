LOAD CSV WITH HEADERS FROM 'file:///dataset.csv' AS row
WITH row.Name as Name, toInteger(row.Year_of_Release)as Year WHERE row.Name IS NOT NULL AND row.NA_Sales IS NOT NULL AND row.EU_Sales IS NOT NULL AND row.JP_Sales IS NOT NULL
MERGE (j:Jeu {Name: Name})
    SET j.year = Year
RETURN count(j);
LOAD CSV WITH HEADERS FROM 'file:///dataset.csv' AS row
WITH row.Publisher as Publisher WHERE row.Name IS NOT NULL AND row.Publiser IS NOT NULL
MERGE (e:Entreprise {Name: Publisher})
RETURN count(e);
LOAD CSV WITH HEADERS FROM 'file:///dataset.csv' AS row
WITH row.Developer as Developer WHERE row.Name IS NOT NULL AND row.Developer IS NOT NULL
MERGE (e:Entreprise {Name: Developer})
RETURN count(e);
LOAD CSV WITH HEADERS FROM 'file:///dataset.csv' AS row
WITH row.Name as NameJ, row.Publisher as Publisher WHERE row.Name IS NOT NULL AND row.Publisher IS NOT NULL
MATCH (j:Jeu {Name: NameJ})
MATCH (e:Entreprise {Name: Publisher})
MERGE (e)-[rel:APublie]->(j)
RETURN count(rel);
LOAD CSV WITH HEADERS FROM 'file:///dataset.csv' AS row
WITH row.Name as NameJ, row.Developer as Developer WHERE row.Name IS NOT NULL AND row.Developer IS NOT NULL
MATCH (j:Jeu {Name: NameJ})
MATCH (e:Entreprise {Name: Developer})
MERGE (e)-[rel:ADeveloppe]->(j)
RETURN count(rel);
