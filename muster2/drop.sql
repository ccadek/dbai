/* Trigger */
DROP TRIGGER t_check_behandelt ON Behandlung;
DROP FUNCTION check_behandelt();
DROP TRIGGER t_check_koordiniert ON Abteilung;
DROP FUNCTION check_koordiniert();
DROP TRIGGER t_check_leitet ON Krankenhaus;
DROP FUNCTION check_leitet();

/* Functions and Procedures */
DROP FUNCTION f_calc_salary(VARCHAR(10),VARCHAR(2),VARCHAR(4));
DROP FUNCTION p_move_healed();
DROP FUNCTION p_calc_salary();

DROP TABLE Akteneintrag;
DROP TABLE Behandlung;
DROP TABLE spezialisiert;
DROP TABLE zugeordnet;
DROP TABLE Klasse;
DROP TABLE Krankheit;
DROP TABLE Lohnzettel;
DROP TABLE Arzt;
ALTER TABLE Mitarbeiter DROP CONSTRAINT fk_arbeitet;
DROP TABLE Abteilung;
DROP TABLE Krankenhaus;
DROP TABLE Mitarbeiter;
DROP TABLE Patient;
DROP TABLE Person;

DROP SEQUENCE seq_akteintrag;
DROP SEQUENCE seq_krankheit;
DROP SEQUENCE seq_abteilung;
DROP SEQUENCE seq_krankenhaus;
DROP SEQUENCE seq_klasse;
