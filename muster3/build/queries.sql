/* Query 1 */
/* # TODO Write Query 1 here */
WITH RECURSIVE kl_hierarchie(kl_id, name, uebergeordnet) AS (
	SELECT klasse.kl_id AS kl_id, name, uebergeordnet, CAST(0 AS INTEGER) AS stufe
	FROM klasse JOIN zugeordnet ON klasse.kl_id = zugeordnet.kl_id WHERE k_id = 7
	UNION ALL
	SELECT kl.kl_id, kl.name, kl.uebergeordnet, (k.stufe + 1) AS stufe
	FROM klasse kl JOIN kl_hierarchie k ON (k.uebergeordnet = kl.kl_id)
) SELECT kl_id, name, uebergeordnet, stufe FROM kl_hierarchie;

/* Query 2 */
/* # TODO Write Query 2 here */
SELECT name, gesamtlohn 
FROM
   ((SELECT arzt.svnr, sum(honorar) AS gesamtlohn
     FROM arzt JOIN Lohnzettel ON arzt.svnr = lohnzettel.svnr
     GROUP BY arzt.svnr
     HAVING sum(honorar) <= ALL (SELECT sum(honorar) 
                                 FROM arzt JOIN Lohnzettel ON arzt.svnr = lohnzettel.svnr
                                 GROUP BY arzt.svnr))
	UNION 
    (SELECT arzt.svnr, sum(honorar) AS gesamtlohn
     FROM arzt JOIN Lohnzettel ON arzt.svnr = lohnzettel.svnr
     GROUP BY arzt.svnr
     HAVING sum(honorar) >= ALL (SELECT sum(honorar) 
                                 FROM arzt JOIN Lohnzettel ON arzt.svnr = lohnzettel.svnr
                                 GROUP BY arzt.svnr))
   ) AS glohn
JOIN person ON glohn.svnr = person.svnr 
ORDER BY gesamtlohn DESC;




