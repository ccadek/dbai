/* Trigger 1 */

CREATE OR REPLACE FUNCTION check_behandelt() RETURNS TRIGGER AS $$
DECLARE
    krankheit INTEGER;
BEGIN
    SELECT Behandlung.krankheit INTO krankheit 
	FROM Behandlung 
	WHERE new.patient = Behandlung.patient;

    IF (FOUND AND new.krankheit <> krankheit) THEN
        RAISE EXCEPTION 'Der zu behandelnde Patient ist bereits mit einer anderen Krankheit in Behandlung!';
    END IF;

    PERFORM spezialisiert.k_id
    FROM spezialisiert JOIN Mitarbeiter ON kh_id = arbeitet_kh_id AND abt_id = arbeitet_abt_id
	WHERE Mitarbeiter.svnr = new.arzt AND spezialisiert.k_id = new.krankheit;
	
	IF (NOT FOUND) THEN
	    RAISE EXCEPTION 'Der Arzt kann nur Krankheiten behandeln auf die die Abteilung in der er arbeitet, spezialisiert sind.';
	END IF;
	
	RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_check_behandelt BEFORE INSERT ON Behandlung
FOR EACH ROW EXECUTE PROCEDURE check_behandelt();

/* Trigger 2 */
CREATE OR REPLACE FUNCTION check_koordiniert() RETURNS TRIGGER AS $$
DECLARE
   kh_id INTEGER;
   abt_id INTEGER;
BEGIN
   IF (new.koordinator IS NOT NULL) THEN 
       SELECT Mitarbeiter.arbeitet_kh_id, Mitarbeiter.arbeitet_abt_id INTO kh_id, abt_id
       FROM Mitarbeiter
       WHERE Mitarbeiter.svnr = new.koordinator;
   
       IF (new.kh_id <> kh_id OR new.abt_id <> abt_id) THEN
           RAISE EXCEPTION 'Koordinator muss in der Abteilung arbeiten, die er koordiniert!';
       END IF;
    END IF;
   
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_check_koordiniert BEFORE INSERT OR UPDATE ON Abteilung
FOR EACH ROW EXECUTE PROCEDURE check_koordiniert();

/* Trigger 3 */
CREATE OR REPLACE FUNCTION check_leitet() RETURNS TRIGGER AS $$
DECLARE
   kh_id INTEGER;
BEGIN
   IF (new.leiter IS NOT NULL) THEN 
       SELECT Mitarbeiter.arbeitet_kh_id INTO kh_id
       FROM Mitarbeiter
       WHERE Mitarbeiter.svnr = new.leiter;
   
       IF (new.kh_id <> kh_id) THEN
           RAISE EXCEPTION 'Leiter muss in einer der Abteilung dieses Krankenhauses arbeiten!';
       END IF;
    END IF;
   
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_check_leitet BEFORE INSERT OR UPDATE ON Krankenhaus
FOR EACH ROW EXECUTE PROCEDURE check_leitet();

/* Function 1 */
CREATE OR REPLACE FUNCTION f_calc_salary(sv VARCHAR(10), m VARCHAR(2) DEFAULT to_char(current_date,'MM'), 
                                         j VARCHAR(4) DEFAULT to_char(current_date,'YYYY')) RETURNS NUMERIC(7,2) AS $$
DECLARE
    gehalt NUMERIC(7,2);
	tage INTEGER;
BEGIN
    IF NOT EXISTS (SELECT * FROM Mitarbeiter WHERE Mitarbeiter.svnr = sv) THEN
	   RAISE EXCEPTION 'Mitarbeiter mit der SVNR % nicht vorhanden', sv;
	END IF;
	
	IF NOT (m IN ('01','02','03','04','05','06','07','08','09','10','11','12')) THEN
	   RAISE EXCEPTION 'Monat % ist ungültig!', m;
	END IF;
	
    IF EXISTS (SELECT * FROM Arzt WHERE Arzt.svnr = sv) THEN
    --Mitarbeiter is Arzt
	   SELECT SUM(Krankheit.bonus*Behandlung.Dauer*Mitarbeiter.gehalt) INTO gehalt
	   FROM ((Behandlung JOIN Mitarbeiter ON Behandlung.arzt = mitarbeiter.svnr) 
	                     JOIN Krankheit ON Krankheit.k_id = Behandlung.Krankheit)
						 JOIN Patient ON Behandlung.patient = Patient.svnr
	   WHERE abgerechnet = FALSE AND Behandlung.arzt=sv AND Patient.geheilt = TRUE;
	   IF gehalt IS NOT NULL THEN RETURN gehalt; END IF;
    ELSE
    --Mitarbeiter ist kein Arzt
       IF NOT EXISTS (SELECT * 
	                  FROM Lohnzettel 
					  WHERE Lohnzettel.svnr = sv AND
						    Lohnzettel.monat = m AND
							Lohnzettel.jahr = j AND
							Lohnzettel.honorar <> 0) THEN
			SELECT Mitarbeiter.gehalt INTO gehalt 
	        FROM Mitarbeiter WHERE Mitarbeiter.svnr = sv;
		    RETURN gehalt*167;
		END IF;		
    END IF;
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;

/* Procedure 1 */
CREATE OR REPLACE FUNCTION p_move_healed () 
	RETURNS void AS $$
DECLARE
    doctor RECORD;
    beh RECORD;
BEGIN
   
   --Krankenakten anlegen
    FOR beh IN (SELECT DISTINCT Behandlung.patient, Behandlung.Krankheit, Patient.seit, Mitarbeiter.arbeitet_kh_id as kh_id, bool_and(Behandlung.abgerechnet) AS abg
               FROM (Behandlung JOIN Patient ON Behandlung.patient = Patient.svnr) JOIN Mitarbeiter ON Behandlung.arzt = Mitarbeiter.svnr
			   WHERE Patient.geheilt = TRUE 
			   GROUP BY Behandlung.patient, Behandlung.Krankheit, Patient.seit, Mitarbeiter.arbeitet_kh_id 
			   HAVING  bool_and(Behandlung.abgerechnet) = TRUE) LOOP
	INSERT INTO Akteneintrag(svnr,von,bis,behandelt_in,hat) VALUES (beh.patient, beh.seit, current_date, beh.kh_id, beh.Krankheit);
	--geheilte und abgerechnete Patienten loeschen
	DELETE FROM Behandlung WHERE patient = beh.patient;
	DELETE FROM Patient WHERE svnr = beh.patient;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

/* Procedure 2 */
CREATE OR REPLACE FUNCTION p_calc_salary ()
    RETURNS void AS $$
DECLARE
    m VARCHAR(2) DEFAULT to_char(current_date,'MM');
    j VARCHAR(4) DEFAULT to_char(current_date,'YYYY');
	mit RECORD;
BEGIN
    FOR mit IN SELECT * FROM Mitarbeiter LOOP
	    IF NOT EXISTS (SELECT * FROM Lohnzettel 
	                   WHERE Lohnzettel.svnr=mit.svnr AND Lohnzettel.monat=m AND Lohnzettel.jahr=j) THEN
            INSERT INTO Lohnzettel VALUES (mit.svnr, j, m, 0); 
        END IF;	 
	    UPDATE Lohnzettel SET honorar = honorar + f_calc_salary(mit.svnr,m,j) 
	                      WHERE Lohnzettel.svnr=mit.svnr AND Lohnzettel.monat=m AND Lohnzettel.jahr=j;
	    UPDATE Behandlung SET abgerechnet = TRUE WHERE patient IN (SELECT svnr FROM Patient WHERE geheilt = TRUE) AND arzt = mit.svnr;
	END LOOP;
END;
$$ LANGUAGE plpgsql;


