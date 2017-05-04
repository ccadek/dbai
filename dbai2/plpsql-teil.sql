--TRIGGER1
CREATE OR REPLACE FUNCTION patient_eine_krankheit() RETURNS TRIGGER AS $$
DECLARE
    false_count integer;
BEGIN
    SELECT count(*) INTO false_count FROM behandelt WHERE new.patient_SVNR = behandelt.behandelter_patient AND behandelt.abgerechnet = false;
    if(false_count > 0) THEN
        RAISE EXCEPTION'Ein Patient kann nur zu einer Krankheit behandelt werden!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_before_patientbehandlung BEFORE INSERT ON behandelt
FOR EACH ROW EXECUTE PROCEDURE patient_eine_krankheit();

--TRIGGER2
CREATE OR REPLACE FUNCTION arzt_in_abteilung() RETURNS TRIGGER AS $$
DECLARE
    abteilungen RECORD;
    spezialisierung RECORD;
    krankheiten RECORD;
    abteilungen_count integer;
BEGIN
    --in welchen abteilungen arbeitet unser Arzt?
    SELECT * INTO abteilungen FROM arbeitet WHERE new.behandelnder_arzt = mitarbeiter;
    -- welche Krankheiten darf der Arzt daher behandeln?
    -- AND klausel könnte falsch sein...
    SELECT * INTO spezialisierung FROM spezialisiert WHERE abteilungen.abteilungsname = spezialisiert.spez_abteilungsname AND spezialisiert.spez_gehoert_zu = abteilungen.in_abteilung;
    --welche krankheiten soll der arzt behandeln?
    SELECT krankheit INTO krankheiten FROM behandelt WHERE new.behandelnder_arzt = behandelt.behandelnder_arzt;
    SELECT count(*) INTO abteilungen_count FROM krankheiten WHERE krankheiten NOT IN (spezialisierung.spez_krankeit);
    IF(abteilungen_count > 0) THEN
        RAISE EXCEPTION 'Ein Arzt darf nur Krankheiten behandeln, auf die er spezialisiert ist!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER arzt_behandelt BEFORE INSERT ON behandelt
FOR EACH ROW EXECUTE PROCEDURE arzt_in_abteilung();

--TRIGGER3
CREATE OR REPLACE FUNCTION ma_kood() RETURNS TRIGGER AS $$
DECLARE
    ma_abteilungen RECORD;
    ma_newAbt RECORD;
BEGIN
    SELECT * INTO ma_abteilungen FROM arbeitet WHERE new.koordiniert = arbeitet.mitarbeiter;
    -- wenn der Mitarbeiter noch nicht in der Abteilung arbeitet, wird er hinzugefuegt
    IF(new.koordiniert NOT IN (ma_abteilungen)) THEN
        SELECT koordiniert INTO ma_newAbt FROM Abteilung WHERE new.koordiniert = ma_abteilungen;
        INSERT INTO arbeitet VALUES (ma_newAbt,new.koordiniert);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_ma_kood BEFORE INSERT OR UPDATE ON Abteilung
FOR EACH ROW EXECUTE PROCEDURE ma_kood();

--TRIGGER4
CREATE OR REPLACE FUNCTION leiter_in_krankenhaus() RETURNS TRIGGER AS $$
DECLARE
    abteilungen integer;
BEGIN
    SELECT count(*) INTO abteilungen
    FROM Abteilung a NATURAL JOIN arbeitet b
    WHERE a.gehoert_zu = new.geleitet_von AND b.mitarbeiter = new.geleitet_von;

    IF(abteilungen = 0) THEN
        RAISE EXCEPTION 'Mitarbeiter % arbeitet in keiner Abteilung des Krankenhauses!',new.geleitet_von;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER t_leiter_krankenhaus BEFORE INSERT OR UPDATE ON Krankenhaus
FOR EACH ROW EXECUTE PROCEDURE leiter_in_krankenhaus();

--funktionen
CREATE OR REPLACE FUNCTION f_calc_salary(soznr VARCHAR(30),year DECIMAL(4,0),month DECIMAL(2,0)) RETURNS DECIMAL(7,2) AS $$
DECLARE
    ma_r RECORD;
    ma_month DECIMAL(2,0);
    ma_year DECIMAL(4,0);
    lohn RECORD;
BEGIN
    IF NOT EXISTS (SELECT * FROM Mitarbeiter WHERE SVNR = soznr) THEN
        RAISE EXCEPTION 'Mitarbeiter mit folgender Sozialversicherungsnummer nicht vorhanden:%',soznr;
    END IF;

    SELECT * FROM Mitarbeiter INTO ma_r WHERE SVNR = soznr;
    SELECT EXTRACT(MONTH FROM ma_r.beschaeftigt_seit) INTO ma_month;
    SELECT EXTRACT(YEAR FROM ma_r.beschaeftigt_seit) INTO ma_year;
    SELECT * FROM Lohnzettel WHERE lohn_ma = soznr INTO lohn;

    IF (ma_year > year ) THEN
        RAISE EXCEPTION 'Mitarbeiter % war noch nicht einmal zu %-% angestellt!',soznr,year,month;
    ELSIF (ma_year = year AND ma_month > month) THEN
        RAISE EXCEPTION 'Mitarbeiter % war noch nicht einmal zu %-% angestellt!',soznr,year,month;
    END IF;

    IF (lohn.Honorar = 0) THEN
        RETURN 167*ma_r.Gehalt;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION p_move_healed() RETURNS VOID AS $$
DECLARE
BEGIN
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION p_calc_salary() RETURNS VOID AS $$
DECLARE
BEGIN
END;
$$ LANGUAGE plpgsql;
