BEGIN;

DELETE FROM Akteneintrag;
DELETE FROM Behandlung;
DELETE FROM spezialisiert;
DELETE FROM zugeordnet;
DELETE FROM Klasse;
DELETE FROM Krankheit;
DELETE FROM Lohnzettel;
DELETE FROM Arzt;
DELETE FROM Abteilung;
DELETE FROM Krankenhaus;
DELETE FROM Mitarbeiter;
DELETE FROM Patient;
DELETE FROM Person;

COMMIT;

INSERT INTO PERSON VALUES
    ('7564280686','Sonnenweg 3','Dr. Claudia Sonnenschein'),   --Leiter KH1
	('9382030476','Winkelgasse 5','Dr. Anna Falschzahn'),    --Arzt KH1 Abt1
	('2731090234','Badeteich 28','Dr. Rudolf Altwienix'),      --Arzt KH1 Abt2
	('1238231257','Baumallee 10','Dr. Wilfried Nimmtsgenau'),  --Leiter KH2
	('2312121063','Sterngasse 8','Dr. Maria Freudenschrei'),   --Arzt KH2 Abt1 
	('4929141172','Baumbachstrasse 21','Dr. Philipp Schmidt'), --Arzt KH2 Abt2
	('5454201053','Wachaustrasse 13','Annett Wolf'),           --Koordinator KH1 Abt1
	('5521210291','Goethestrasse 75','Dr. Bernd Bachmeier'),   --Koordinator/Arzt KH1 Abt2
	('5231100989','Templstrasse 43','Lukas Sommer'),           --Koordinator KH2 Abt1
	('8391031029','Gewerbepark 6','Dr. Eric Biermann'),        --Koordinator/Arzt KH2 Abt2
	('4916080163','Lucasweg 82','Ines Bach'),                   --Patient
	('4539180893','Loewenzahnstrasse 17','Gustav Drechsler'),   --Patient
	('5328090565','Sausestrasse 68','Luca Hofmann'),            --Patient
	('5139210794','Bremschlstrasse 40','Georg Baader'),         --Patient
	('5287081081','An der Bundesstrasse 19','Daniela Scherer'); --Patient
	
INSERT INTO Patient(svnr) VALUES
    ('4916080163'),
	('4539180893'),
	('5328090565'),
	('5139210794'),
	('5287081081');
	
BEGIN;

INSERT INTO Mitarbeiter VALUES
    ('7564280686',200,current_date,10,1),
    ('9382030476',90,current_date,10,1),
	('2731090234',120,current_date,10,2),
	('1238231257',200,current_date,20,1),
    ('2312121063',80,current_date,20,1),
    ('4929141172',30,current_date,20,2),
    ('5454201053',60,current_date,10,1),
	('5521210291',130,current_date,10,2),
	('5231100989',150,current_date,20,1),
	('8391031029',180,current_date,20,2);
 
INSERT INTO Krankenhaus VALUES
    (10,'Quakhausen','Am Entenweg','7564280686'),
    (20,'Vielbeinfelden','Am Felde','1238231257');
	
INSERT INTO Abteilung VALUES
    (10,1,'Psychiatrie','Am Entenweg 2','5454201053'),
    (10,2,'OP','Am Entenweg 3','5521210291'),
    (20,1,'Apotheke','Am Felde 5','5231100989'),
    (20,2,'Spitzzungenabteilung','Am Felde 10','8391031029');	

COMMIT;

INSERT INTO Arzt VALUES
    ('9382030476'),('2731090234'),('2312121063'),('4929141172'),('5521210291'),('8391031029');
	
INSERT INTO Krankheit VALUES
    (1,1,'Aufgeblasene'),
    (2,1,'Haarspalterei'),
	(3,2,'Schmalzstimme'),
	(4,1.2,'Tarnkappe'),
	(5,2.4,'Spitzzuengigkeit'),
	(6,1.8,'Transparenz'),
	(7,1.3,'Gebrochenes Herz'),
	(8,1.6,'Fernsehfieber');
	
INSERT INTO Klasse VALUES
    (1,'Physisch',NULL),
	(2,'Psychisch',NULL),
	(3,'Hautkrankheiten',1),
	(4,'Innere Organe',1),
	(5,'Knochenkrankheiten',1),
	(6,'Herz',4),
	(7,'Lunge',4),
	(8,'HalsNasenOhren',1);
	
INSERT INTO zugeordnet VALUES
    (1,4),(2,3),(3,2),(4,3),(5,8),(6,3),(7,6),(8,2);
	
INSERT INTO spezialisiert VALUES
    (10,2,1),(10,2,2),(10,1,3),(20,1,4),(20,2,5),(20,1,6),(10,2,7),(10,1,8);

INSERT INTO Behandlung VALUES
    ('9382030476','4916080163',3,10,FALSE),
	('8391031029','4539180893',5,2,FALSE),
	('4929141172','4539180893',5,3,FALSE),
	('2312121063','5328090565',6,0.5,FALSE),
	('2731090234','5139210794',2,1,FALSE),
	('5521210291','5139210794',2,1,FALSE),
	('2731090234','5287081081',7,4,FALSE);

INSERT INTO Akteneintrag(svnr,von,bis,behandelt_in,hat) VALUES
    ('5287081081','2014-10-28','2014-11-03',10,5),
	('5287081081','2014-10-05','2014-10-10',10,3),
	('5287081081','2014-10-13','2014-10-14',10,5),
	('4916080163','2014-10-12','2014-10-12',10,1);
	

	
