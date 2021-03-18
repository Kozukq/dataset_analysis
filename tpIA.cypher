LOAD CSV WITH HEADERS FROM 'file:///dataset.csv' AS row
WITH row.Name as Name, toInteger(row.Year_of_Release)as Year WHERE row.Name IS NOT NULL
MERGE (j:Jeu {Name: Name})
    SET j.year = Year
RETURN count(j);
