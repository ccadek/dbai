package dbs.ws14;

import java.lang.String;
import java.lang.System;
import java.sql.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;

import dbs.DBConnector;

public class Szenario2 {

    private Connection connection = null;

    public static void main(String[] args) {
        if (args.length <= 6 && args.length >= 4) {
            /*
             * args[0] ... type -> [a|b], 
             * args[1] ... server, 
             * args[2] ... port,
             * args[3] ... database, 
             * args[4] ... username, 
             * args[5] ... password
             */

            Connection conn = null;

            if (args.length == 4) {
                conn = DBConnector.getConnection(args[1], args[2], args[3]);
            } 
            else {
                if (args.length == 5) {
                    conn = DBConnector.getConnection(args[1], args[2], args[3], args[4], "");
                } 
                else {
                    conn = DBConnector.getConnection(args[1], args[2], args[3], args[4], args[5]);
                }
            }

            if (conn != null) {
                Szenario2 s = new Szenario2(conn);

                if (args[0].equals("a")) {
                    s.runTransactionA();
                } else {
                    s.runTransactionB();
                }
            }

        } 
        else {
            System.err.println("Ungueltige Anzahl an Argumenten!");
        }
    }

    public Szenario2(Connection connection) {
        this.connection = connection;
    }

    /*
     * Beschreibung siehe Angabe
     */
    public void runTransactionA() {
        /*
         * Vorgegebener Codeteil
         * ################################################################################
         */
        wait("Druecken Sie <ENTER> zum Starten der Transaktion ...");
        /*
         * ################################################################################
         */

        System.out.println("Transaktion A Start");
        
        /*
         * Setzen Sie das aus Ihrer Sicht passende Isolation-Level:
         */
        
        try {
            
            connection.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);

        /*
         * Abfrage 1:
         * Ermitteln fuer das Krankenhaus mit der Nummer '10' f�r jede Abteilung folgende Informationen: 
         * Der Name der Abteilung, die Krankheiten, auf die diese Abteilung spezialisiert ist, 
         * und die Anzahl der Patienten, die zu dieser Krankheit in dieser Abteilung in Behandlung sind. 
         * Das Ergebnis soll nach dem Abteilungsnamen aufsteigend und dann nach der Anzahl der Patienten 
         * absteigend sortiert werden.
         * 
         */
            Statement stmt = connection.createStatement();
            //Join von Abteilung und PatAbt
            //stmt.addBatch("SELECT name,anzahl,abt_id,a.kh_id FROM (select * from Abteilung where kh_id=10) a INNER join patabt b USING (abt_id,kh_id)");

            // hole anzahl der Patienten mit einer Krankheit aus dem Krankenhaus 10 mit Abteilungen
            ResultSet rs = stmt.executeQuery("SELECT kh_id,abt_id,k_id,anzahl,d.name FROM ((spezialisiert s INNER JOIN Krankheit k USING (k_id)) a INNER JOIN patabt b USING (abt_id,kh_id)) c INNER JOIN Abteilung d USING (kh_id,abt_id) WHERE kh_id =10 \n" +
                    "ORDER BY d.name ASC,anzahl DESC");

            PreparedStatement krankenh = connection.prepareStatement("SELECT name FROM Krankenhaus WHERE kh_id=?");
            //PreparedStatement abtN = connection.prepareStatement("SELECT name FROM Abteilung WHERE kh_id=? AND abt_id=?");
            PreparedStatement k = connection.prepareStatement("SELECT name FROM Krankheit WHERE k_id=?");

            while(rs.next()){
                krankenh.setInt(1, rs.getInt(1));
                ResultSet krankha = krankenh.executeQuery();
                krankha.next();
                String krankenhaus = krankha.getString(1);

                k.setInt(1, rs.getInt(3));
                ResultSet kr = k.executeQuery();
                kr.next();
                String krankheit = kr.getString(1);

                System.out.println("KH: "+krankenhaus+" Abt: "+rs.getString("name")+" Patienten: "+rs.getInt("anzahl")+" Krankheit: "+krankheit);

            }


        /*
         * Vorgegebener Codeteil
         * ################################################################################
         */
         wait("Druecken Sie <ENTER> zum Fortfahren ...");
        /*
         * ################################################################################
         */

        /*
         * Abfrage 2:
         * Anzahl der Patienten pro Abteilung im Krankenhaus mit der Nummer '10'
         */
            rs = stmt.executeQuery("select anzahl,name from patabt join Abteilung using (kh_id,abt_id) where kh_id=10 ORDER BY name ASC");

            while(rs.next()){
                System.out.println("Abt: "+rs.getString("name")+" Anzahl:"+rs.getInt("anzahl"));
            }
         
            
        /*
         * Vorgegebener Codeteil
         * ################################################################################
         */
        wait("Druecken Sie <ENTER> zum Beenden der Transaktion ...");
        /*
         * ################################################################################
         */
            
        /*
         * Beenden Sie die Transaktion
         */
            rs.close();
            stmt.close();
            connection.close();
        
        } 
        catch (SQLException ex) {
            Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
        }

        System.out.println("Transaktion A Ende");
    }

    public void runTransactionB() {
        /*
         * Vorgegebener Codeteil
         * ################################################################################
         */
        wait("Druecken Sie <ENTER> zum Starten der Transaktion ...");

        System.out.println("Transaktion B Start");
        
        try {
            Statement stmt = connection.createStatement();
            
            
            stmt.executeUpdate("INSERT INTO Patient(svnr) VALUES ('5287081081');");
            stmt.executeUpdate("INSERT INTO Behandlung VALUES (" +
                               "'9382030476','5287081081',8,10,FALSE);");

            stmt.close();
            
            System.out.println("Eine Behandlung wurde hinzugefuegt ...");
            
            wait("Druecken Sie <ENTER> zum Beenden der Transaktion ...");

            connection.commit();
            
            wait("Druecken Sie <ENTER> zum Beenden des Szenarios ...");
            stmt = connection.createStatement();
            stmt.executeUpdate("DELETE FROM Behandlung WHERE patient = '5287081081'");
            stmt.executeUpdate("DELETE FROM Patient WHERE svnr = '5287081081'");
            stmt.close();
            connection.commit();
            
        } 
        catch (SQLException ex) {
            Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
        }

        System.out.println("Transaktion B Ende");
        /*
         * ################################################################################
         */
    }

    private static void wait(String message) {
        /* 
         * Vorgegebener Codeteil 
         * ################################################################################
         */
    	System.out.println(message);
    	Scanner scanner = new Scanner(System.in);
        scanner.nextLine();
        /*
         * ################################################################################
         */
    }
}
