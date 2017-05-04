package dbs.ws14;

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.Date;

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
     * Hier das Statement erstellen
     */
	private void prepareStatement() {
		// TODO Write your code here
		
		try {
			pstmt = connection.prepareStatement("SELECT ak_id, von, bis, krankenhaus.name AS name, krankheit.name AS krank, (bis - von)+1 as dauer " +
                    "FROM akteneintrag JOIN krankenhaus ON behandelt_in = kh_id " +
                                      "JOIN krankheit ON hat = k_id WHERE svnr = ? ORDER BY von ASC");	
		} catch (SQLException ex) {
			Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
		}
	}

    /*
     * Fuer jeden Mitarbeiter printAkteneintrag aufrufen
     */
    public void run() {
    	// TODO Write your code here

    	try {
			Statement stmt = connection.createStatement();
			
			ResultSet rs_svnr = stmt.executeQuery("SELECT svnr, name FROM Person;");
			
			while (rs_svnr.next()) {
				String svnr = rs_svnr.getString(1);
				String name = rs_svnr.getString(2);
				
				System.out.println("Akteneintraege der Person " + svnr + ": " + name);
				System.out.println("-----------------------------------------------");
				
				printAkteneintrag(svnr);
				
				System.out.println();
			}
				
		} catch (SQLException ex) {
			Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
		}		
    }
    
    /*
     * Akteneintrag + Statistik ausgeben
     */
    public void printAkteneintrag(String svnr) {
    	// TODO Write your code here
    	
    	ResultSet rs_akten;
    	int max = 0;
		int min = 0;
		int sum = 0;
		int cnt = 0;
		
		try {
			pstmt.setString(1, svnr);
			rs_akten = pstmt.executeQuery();
		
			if (rs_akten.next()) {
				System.out.println("    Name des Krankenhauses     |            Krankheit           |    von     |    bis     ");
				System.out.println("-------------------------------+--------------------------------+------------+------------");
				do {
			
					int dauer = rs_akten.getInt("dauer");
					String kh_name = rs_akten.getString("name");
					String krank = rs_akten.getString("krank");
					String von = rs_akten.getString("von");
					String bis = rs_akten.getString("bis");
			
					System.out.print(String.format("%-30s",kh_name) + " | ");
					System.out.print(String.format("%-30s",krank) + " | ");
					System.out.print(String.format("%-10s",von) + " | ");
					System.out.println(String.format("%-10s",bis));
			
			
					/* Fuer die Statistiken */
					if (cnt == 0) {
						max = dauer;
						min = dauer;
					} else {
						if (dauer > max) max=dauer;
						if (dauer < min) min=dauer;
					}
			
					sum += dauer;
					cnt++;
				} while (rs_akten.next());
			}
		
			System.out.println();
			System.out.println("Statistik:");
			System.out.println("----------");
			System.out.println("Anzahl der Akteneintraege:                     " + cnt);
			System.out.println("Maximale Krankenhausaufenthaltsdauer:          " + max);
			System.out.println("Minimale Krankenhausaufenthaltsdauer:          " + min);
			System.out.print("Durchschnittliche Krankenhausaufenthaltsdauer: ");
			if (cnt > 0)
				System.out.println(String.format("%.2f", (double)sum/cnt));
			else
				System.out.println("-");

		} catch (SQLException ex) {
			Logger.getLogger(Szenario1.class.getName()).log(Level.SEVERE, null, ex);
		}
    }
}
