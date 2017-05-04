/* Query 1 */
# TODO Write Query 1 here 
WITH RECURSIVE unter(kl_id,name,uebergeordnet) AS (
    SELECT kl_id,name,uebergeordnet, CAST(0 AS INTEGER) AS stufe
    FROM Klasse
    WHERE kl_id = 6
  UNION ALL
    SELECT k.kl_id,k.name,k.uebergeordnet,(u.stufe + 1) AS stufe
    FROM unter u JOIN Klasse k ON (u.uebergeordnet = k.kl_id)
)
SELECT kl_id,name,stufe FROM unter;

/* Query 2 */
# TODO Write Query 2 here
SELECT p.name,gehalt
FROM ((
        SELECT a.svnr AS soznr, sum(l.honorar) AS gehalt
	    FROM Lohnzettel l INNER JOIN Arzt a USING (svnr)
	    GROUP BY a.svnr
	    ORDER BY sum(l.honorar) DESC
	    LIMIT 1)
	UNION
	(
	    SELECT a.svnr AS soznr, sum(l.honorar) AS gehalt
        FROM Lohnzettel l INNER JOIN Arzt a USING (svnr)
        GROUP BY a.svnr
        ORDER BY sum(l.honorar) ASC
        LIMIT 1
    )) c join Person p ON c.soznr = p.svnr