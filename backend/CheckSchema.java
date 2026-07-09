import java.sql.*;

public class CheckSchema {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres";
        String user = "dev_user.vsmlzmwgqyaduavrisme";
        String pass = "Minhtb!2108";
        
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(
                 "SELECT table_name, column_name, data_type, character_maximum_length, is_nullable " +
                 "FROM information_schema.columns " +
                 "WHERE table_schema = 'public' " +
                 "ORDER BY table_name, ordinal_position;")) {
                 
            String currentTable = "";
            while (rs.next()) {
                String table = rs.getString("table_name");
                if (!table.equals(currentTable)) {
                    System.out.println("\n--- TABLE: " + table + " ---");
                    currentTable = table;
                }
                String col = rs.getString("column_name");
                String type = rs.getString("data_type");
                String maxLen = rs.getString("character_maximum_length");
                String isNullable = rs.getString("is_nullable");
                System.out.printf("  %s %s%s (Nullable: %s)\n", col, type, (maxLen != null ? "(" + maxLen + ")" : ""), isNullable);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
