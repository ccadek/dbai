CREATE SEQUENCE eintragnr
  START WITH 10
  INCREMENT BY 10
  NO CYCLE;
--CACHE 1;
CREATE SEQUENCE behandlungsnr
  START WITH 10
  INCREMENT BY 10
  NO CYCLE;

CREATE TABLE Person (SVNR integer PRIMARY KEY,
                      Name VARCHAR(30),
                      Anschrift VARCHAR(30));

CREATE TABLE Patient (patient_SVNR integer,
                      geheilt boolean,
                      seit date,
                      FOREIGN KEY (patient_SVNR) REFERENCES Person(SVNR),
                      PRIMARY KEY (patient_SVNR));

CREATE TABLE Mitarbeiter (ma_SVNR integer,
                          Gehalt DECIMAL(7,2) CHECK (Gehalt > 0),
                          beschaeftigt_seit date,
                          FOREIGN KEY (ma_SVNR) REFERENCES Person(SVNR),
                          PRIMARY Key (ma_SVNR));

CREATE TABLE Arzt (arzt_SVNR integer,
                  FOREIGN KEY (arzt_SVNR) REFERENCES Mitarbeiter(ma_SVNR),
                  PRIMARY KEY (arzt_SVNR));

CREATE TABLE Krankheit (Name VARCHAR(30) PRIMARY KEY,
                      Bonus DECIMAL(7,2) CHECK (Bonus > 0));

CREATE TABLE Lohnzettel (lohn_ma integer,
                        Jahr DECIMAL(4,0),
                        Monat DECIMAL(2,0),
                        Honorar integer DEFAULT 0,
                        FOREIGN KEY (lohn_ma) REFERENCES Mitarbeiter(ma_SVNR),
                        PRIMARY KEY (lohn_ma,Jahr,Monat));

CREATE TABLE Krankenhaus (Name VARCHAR(30) PRIMARY KEY,
                        Anschrift VARCHAR(30),
                        geleitet_von integer UNIQUE REFERENCES Mitarbeiter(ma_SVNR));

CREATE TABLE Abteilung (gehoert_zu VARCHAR(30) ,
                        abteilungsname VARCHAR(30) UNIQUE,
                        Anschrift VARCHAR(30),
                        koordiniert integer REFERENCES Mitarbeiter(ma_SVNR),
                        FOREIGN KEY (gehoert_zu) REFERENCES Krankenhaus(Name),
                        PRIMARY KEY(gehoert_zu,abteilungsname));

CREATE TABLE Akteintrag (SVNR integer REFERENCES Person(SVNR),
                        von date,
                        bis date CHECK (von < bis),
                        krankheit VARCHAR(30) REFERENCES Krankheit(Name),
                        behandelt_in VARCHAR(30) REFERENCES Krankenhaus(Name),
                        person integer REFERENCES Person(SVNR),
                        eintragnr integer PRIMARY KEY DEFAULT nextval('eintragnr'));

CREATE TABLE Klasse (Name VARCHAR(30) PRIMARY KEY);

CREATE TABLE hat_krankheit (aktNr integer,
                            krankheit VARCHAR(30),
                            FOREIGN KEY (aktNr) REFERENCES Akteintrag(eintragnr),
                            FOREIGN KEY (krankheit) REFERENCES Krankheit(Name),
                            PRIMARY KEY(aktNr,krankheit));

CREATE TABLE arbeitet (in_abteilung VARCHAR(30),
                      mitarbeiter integer,
                      FOREIGN KEY (in_abteilung) REFERENCES Abteilung(abteilungsname),
                      FOREIGN KEY (mitarbeiter) REFERENCES Mitarbeiter(ma_SVNR),
                      PRIMARY KEY (in_abteilung,mitarbeiter));

--dauer als date machen?
CREATE TABLE behandelt (behandelter_patient integer REFERENCES Patient(patient_SVNR),
                        behandelnder_arzt integer REFERENCES Arzt(arzt_SVNR),
                        krankheit VARCHAR(30) REFERENCES Krankheit(Name),
                        Dauer integer,
                        abgerechnet boolean,
                        behandlungsnr integer PRIMARY KEY);

CREATE TABLE zugeordnet (zu_krankheit VARCHAR(30),
                        zu_klasse VARCHAR(30) ,
                        FOREIGN KEY (zu_krankheit) REFERENCES Krankheit(Name),
                        FOREIGN KEY (zu_klasse) REFERENCES Klasse(Name),
                        PRIMARY KEY (zu_krankheit,zu_klasse));

CREATE TABLE uebergeordnet (unterklasse VARCHAR(30) REFERENCES Klasse(Name) DEFERRABLE INITIALLY DEFERRED,
                            oberklasse VARCHAR(30) REFERENCES Klasse(Name) DEFERRABLE INITIALLY DEFERRED,
                            PRIMARY KEY(unterklasse,oberklasse));

CREATE TABLE spezialisiert (spez_gehoert_zu VARCHAR(30),
                            spez_abteilungsname VARCHAR(30),
                            spez_krankheit VARCHAR(30),
                            FOREIGN KEY (spez_abteilungsname,spez_gehoert_zu) REFERENCES Abteilung(abteilungsname,gehoert_zu),
                            FOREIGN KEY (spez_krankheit) REFERENCES Krankheit(Name),
                            PRIMARY KEY (spez_abteilungsname,spez_gehoert_zu,spez_krankheit));

ALTER TABLE uebergeordnet ADD CONSTRAINT u_fk FOREIGN KEY (unterklasse) REFERENCES Klasse(Name) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE uebergeordnet ADD CONSTRAINT o_fk FOREIGN KEY (oberklasse) REFERENCES Klasse(Name) DEFERRABLE INITIALLY DEFERRED;
