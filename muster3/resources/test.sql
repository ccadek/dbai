/* Teil 1 - Lohnberechnet */

--Berechne das Gehalt der Mitarbeiter (noch kein Patient geheilt)
SELECT svnr, f_calc_salary(svnr) FROM Mitarbeiter;

--Heile Patienten
UPDATE Patient SET geheilt = TRUE WHERE svnr IN ('5139210794','5287081081');

--Berechne nochmal das Gehalt
SELECT svnr, f_calc_salary(svnr) FROM Mitarbeiter; 

--Noch keine Lohnzettel angelegt
SELECT * FROM Lohnzettel;
SELECT p_calc_salary();

--Lohnzettel angelegt, Behandlungen abgerechnet
SELECT * FROM Lohnzettel;
SELECT * FROM Behandlung;

--Neuberechnung des Gehalts sollte keine neuen Honorare ausgeben
SELECT svnr, f_calc_salary(svnr) FROM Mitarbeiter;

/* Teil 2 - Krankenakte */
SELECT p_move_healed();

SELECT * FROM Akteneintrag;
SELECT * FROM Behandlung;

/* Teil 3 - Trigger/Constraints */

-- Andere Krankheit
INSERT INTO Behandlung VALUES ('2312121063','4539180893','6',1,FALSE);

-- Arzt/Abteilung falsch
INSERT INTO Behandlung VALUES ('2312121063','4539180893','5',1,FALSE);

-- Koordinator einer Abteilung
UPDATE Abteilung SET koordinator = '2312121063' WHERE kh_id=10 AND abt_id=1;

-- Leiter eines Krankenhauses
UPDATE Krankenhaus SET leiter = '2312121063' WHERE kh_id=10;

-- Bonus Krankheit >= 1
INSERT INTO Krankheit VALUES (10,0.8,'Geteerte Lungen');

-- Gehalt > 0
UPDATE Mitarbeiter SET gehalt = -1;

-- Akteneintrag von <= bis
UPDATE Akteneintrag SET bis = TO_DATE('01/01/1970','DD/MM/YYYY');
