CREATE VIEW PatAbt AS
SELECT kh_id, abt_id, count(patient) AS anzahl
FROM Behandlung b INNER JOIN spezialisiert s ON b.krankheit = s.k_id
GROUP BY s.kh_id,s.abt_id