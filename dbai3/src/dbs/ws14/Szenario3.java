package dbs.ws14;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;

import dbs.DBConnector;

public class Szenario3 {

    private Connection connection = null;
    private PreparedStatement pstmt = null;
    
    public static void main(String[] args) {
        if (args.length <= 5 && args.length >= 3) {
            /*
             * args[1] ... server, 
             * args[2] ... port,
             * args[3] ... database, 
             * args[4] ... username, 
             * args[5] ... password
             */

            Connection conn = null;

            if (args.length == 3) {
                conn = DBConnector.getConnection(args[0], args[1], args[2]);
            } 
            else {
                if (args.length == 4) {
                    conn = DBConnector.getConnection(args[0], args[1], args[2], args[3], "");
                } 
                else {
                    conn = DBConnector.getConnection(args[0], args[1], args[2], args[3], args[4]);
                }
            }

            if (conn != null) {
                Szenario3 s = new Szenario3(conn);

                s.prepareStatement();
                s.run();
            }

        } 
        else {
            System.err.println("Ungueltige Anzahl an Argumenten!");
        }
    }

	public Szenario3(Connection connection) {
        this.connection = connection;
    }
	
	/*
     * Hier das Prepared Statement erstellen
     */
	private void prepareStatement() {
        try {
            // Hole alle Akteneinträge einer bestimmten SVNR
            this.pstmt = this.connection.prepareStatement("SELECT svnr, count(svnr) AS anzahl, MAX(bis-von) AS maxDauer,MIN(bis-von) AS minDauer FROM Akteneintrag WHERE svnr = ? GROUP BY svnr");
        }
        catch (SQLException ex){
            Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
        }
		
	}

    /*
     * Fuer jeden Mitarbeiter printAkteneintrag aufrufen
     */
    public void run() {
    	try{
            Statement stmt = connection.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT svnr from Person");

            while(rs.next()){
                // Gehe alle Einträge durch
                printAkteneintrag(rs.getString("svnr"));
            }
            rs.close();
            stmt.close();
            pstmt.close();
            connection.close();
        }
        catch (SQLException ex){
            Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
        }

    	
    }
    
    /*
     * Akteneintrag + Statistik ausgeben
     */
    public void printAkteneintrag(String svnr) {

        try {
            //Hole alle Akteneinträge mit svnr
            this.pstmt.setString(1, svnr);
            ResultSet rs = this.pstmt.executeQuery();

            // Gehe alle Einträge durch
            while (rs.next()) {
                System.out.println("SVNR:"+rs.getString("svnr")+", #Einträge:"+rs.getInt("anzahl")+", Maximale Dauer:"+rs.getInt("maxdauer")+", Minimale Dauer:"+rs.getInt("mindauer"));
            }
            rs.close();
        }
        catch(SQLException ex ){
            Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
