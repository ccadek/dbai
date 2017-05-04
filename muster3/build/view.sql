/* View 1 */
CREATE VIEW PatAbt AS
   SELECT  kh_id, abt_id, count(DISTINCT patient)  AS anz
   FROM Abteilung JOIN Mitarbeiter ON arbeitet_kh_id = kh_id AND arbeitet_abt_id = abt_id
                  JOIN Behandlung ON svnr = arzt 
   GROUP BY kh_id, abt_id;


