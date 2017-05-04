package dbs.ws14;

import java.sql.*;
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
            
            connection.setTransactionIsolation(Connection.TRANSACTION_REPEATABLE_READ);

        /*
         * Abfrage 1:
         * Ermitteln fuer das Krankenhaus mit der Nummer '10' fuer jede Abteilung folgende Informationen: 
         * Der Name der Abteilung, die Krankheiten, auf die diese Abteilung spezialisiert ist, 
         * und die Anzahl der Patienten, die zu dieser Krankheit in dieser Abteilung in Behandlung sind. 
         * Das Ergebnis soll nach dem Abteilungsnamen aufsteigend und dann nach der Anzahl der Patienten 
         * absteigend sortiert werden.
         * 
         */
            
            Statement stmt = connection.createStatement();
            
            ResultSet rs1 = stmt.executeQuery("SELECT abteilung.name AS aname, krankheit.name AS kname, count(distinct patient) AS anz " +
                                              "FROM abteilung JOIN spezialisiert ON abteilung.kh_id = spezialisiert.kh_id AND abteilung.abt_id = spezialisiert.abt_id " + 
                                              "JOIN krankheit ON spezialisiert.k_id = krankheit.k_id " +
                                              "LEFT JOIN Behandlung ON Behandlung.krankheit = krankheit.k_id " +
                                              "WHERE abteilung.kh_id = '10' " +
                                              "GROUP BY aname, kname " +
                         				      "ORDER BY aname ASC, anz DESC;");
        
            System.out.println("      Name der Abteilung       |       Name der Krankheit       |     in Behandlung");
            System.out.println("-------------------------------+--------------------------------+-------------------------------");
            while (rs1.next()) {
            	System.out.print(String.format("%-30s",rs1.getString(1)) + " | ");
            	System.out.print(String.format("%-30s",rs1.getString(2)) + " | ");
            	System.out.print(String.format("%-30s",rs1.getString(3)));
            	System.out.println();
            }
            rs1.close();
            
            
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
                  
         ResultSet rs2 = stmt.executeQuery("SELECT abteilung.name AS aname, anz " +
                                           "FROM PatAbt RIGHT JOIN Abteilung ON PatAbt.kh_id = Abteilung.kh_id AND PatAbt.abt_id = Abteilung.abt_id " +
        		                           "WHERE abteilung.kh_id = '10' "+
                                           "ORDER BY aname ASC");
     
         System.out.println("      Name der Abteilung       |      Anz der Patienten");
         System.out.println("-------------------------------+--------------------------------");
         while (rs2.next()) {
         	System.out.print(String.format("%-30s",rs2.getString(1)) + " | ");
         	System.out.print(String.format("%-30s",rs2.getInt(2)));
         	System.out.println();
         }
         rs2.close();
         
            
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
