CREATE SEQUENCE seq_klasse;
CREATE SEQUENCE seq_krankenhaus INCREMENT BY 10 MINVALUE 10 NO CYCLE;
CREATE SEQUENCE seq_abteilung;
CREATE SEQUENCE seq_krankheit;
CREATE SEQUENCE seq_akteintrag;

CREATE TABLE Person (
	svnr VARCHAR(10) PRIMARY KEY,
	anschrift VARCHAR(40) NOT NULL,
	name VARCHAR(40) NOT NULL
);

CREATE TABLE Patient (
	svnr VARCHAR(10) PRIMARY KEY REFERENCES Person(svnr),
	-- Angabe: Beim Anlegen eines Patienten wird das aktuelle Datum gespeichert und geheilt auf falsch gesetzt
	geheilt BOOLEAN DEFAULT FALSE,
	seit DATE DEFAULT current_date
);

--BEGIN;

CREATE TABLE Mitarbeiter (
	svnr VARCHAR(10) PRIMARY KEY REFERENCES Person(svnr),
	gehalt NUMERIC(7,2) NOT NULL CHECK (gehalt > 0),
	beschaeftigt_seit DATE NOT NULL,
	arbeitet_kh_id INTEGER NOT NULL,
	arbeitet_abt_id INTEGER NOT NULL
);

CREATE TABLE Krankenhaus (
    kh_id INTEGER PRIMARY KEY DEFAULT nextval('seq_krankenhaus'),
	name VARCHAR(40) NOT NULL,
	anschrift VARCHAR(40) NOT NULL,
	leiter VARCHAR(10) NOT NULL REFERENCES Mitarbeiter(svnr) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE Abteilung (
	kh_id INTEGER REFERENCES Krankenhaus(kh_id),
	abt_id INTEGER DEFAULT nextval('seq_abteilung'),
	name VARCHAR(40) NOT NULL,
	anschrift VARCHAR(40) NOT NULL,
	koordinator VARCHAR(10) NOT NULL REFERENCES Mitarbeiter(svnr) DEFERRABLE INITIALLY DEFERRED,

	PRIMARY KEY (kh_id, abt_id)
);

ALTER TABLE Mitarbeiter ADD CONSTRAINT fk_arbeitet FOREIGN KEY (arbeitet_kh_id, arbeitet_abt_id) REFERENCES Abteilung(kh_id, abt_id) DEFERRABLE INITIALLY DEFERRED;

--COMMIT;

CREATE TABLE Arzt (
    svnr VARCHAR(10) PRIMARY KEY REFERENCES Mitarbeiter(svnr)
);

CREATE TABLE Lohnzettel (
    svnr VARCHAR(10) REFERENCES Mitarbeiter(svnr),
	jahr VARCHAR(4) NOT NULL,
	monat VARCHAR(2) NOT NULL,
	honorar NUMERIC(7,2) NOT NULL CHECK (honorar >= 0),

	PRIMARY KEY(svnr, jahr, monat)
);

CREATE TABLE Krankheit (
    k_id INTEGER PRIMARY KEY DEFAULT nextval('seq_krankheit'),
	bonus NUMERIC(7,2) NOT NULL CHECK (bonus >= 1),
	name VARCHAR(40) NOT NULL
);

CREATE TABLE Klasse (
    kl_id INTEGER PRIMARY KEY DEFAULT nextval('seq_klasse'),
	name VARCHAR(40) NOT NULL,
	uebergeordnet INTEGER REFERENCES Klasse(kl_id) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE zugeordnet (
    k_id INTEGER REFERENCES Krankheit(k_id),
	kl_id INTEGER REFERENCES Klasse(kl_id),

	PRIMARY KEY (k_id,kl_id)
);

CREATE TABLE spezialisiert (
    kh_id INTEGER,
	abt_id INTEGER,
	k_id INTEGER REFERENCES Krankheit(k_id),

	FOREIGN KEY (kh_id, abt_id) REFERENCES Abteilung(kh_id, abt_id),
	PRIMARY KEY (kh_id,abt_id,k_id)
);

CREATE TABLE Behandlung (
    arzt VARCHAR(10) REFERENCES Arzt(svnr),
	patient VARCHAR(10) REFERENCES Patient(svnr),
	krankheit INTEGER REFERENCES Krankheit(k_id),
	dauer INTEGER NOT NULL CHECK (dauer > 0),
	abgerechnet BOOLEAN NOT NULL DEFAULT FALSE,

	PRIMARY KEY (arzt, patient, krankheit)
);

CREATE TABLE Akteneintrag (
    svnr VARCHAR(10) REFERENCES Person(svnr),
	ak_id INTEGER DEFAULT nextval('seq_akteintrag'),
	von DATE NOT NULL,
	bis DATE NOT NULL,
	behandelt_in INTEGER REFERENCES Krankenhaus(kh_id),
	hat INTEGER REFERENCES Krankheit(k_id),

	PRIMARY KEY (svnr, ak_id),
	CHECK (von <= bis)
);
