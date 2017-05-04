DROP TRIGGER t_before_patientbehandlung on behandelt;
DROP FUNCTION patient_eine_krankheit();
DROP TRIGGER t_ma_kood on Abteilung;
DROP FUNCTION ma_kood();
DROP TRIGGER t_leiter_krankenhaus ON Krankenhaus;
DROP FUNCTION leiter_in_krankenhaus();
DROP TRIGGER arzt_behandelt on behandelt;
DROP FUNCTION arzt_in_abteilung();

DROP FUNCTION f_calc_salary(VARCHAR(30),DECIMAL(4,0),DECIMAL(2,0));
DROP FUNCTION p_move_healed();
DROP FUNCTION p_calc_salary();

DROP TABLE behandelt;
DROP TABLE arbeitet;
DROP TABLE hat_krankheit;
DROP TABLE zugeordnet;
DROP TABLE uebergeordnet;
DROP TABLE spezialisiert;
DROP TABLE Abteilung;
DROP TABLE Akteintrag;
DROP TABLE Krankenhaus;
DROP TABLE Klasse;
DROP TABLE Krankheit;
DROP TABLE Arzt;
DROP TABLE Lohnzettel;
DROP TABLE Mitarbeiter;
DROP TABLE Patient;
DROP TABLE Person;

DROP SEQUENCE eintragnr;
DROP SEQUENCE behandlungsnr;
