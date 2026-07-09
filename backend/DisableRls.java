import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DisableRls {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://aws-1-ap-northeast-1.pooler.supabase.com:5432/postgres";
        String user = "dev_user.vsmlzmwgqyaduavrisme";
        String pass = "Minhtb!2108";
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             Statement stmt = conn.createStatement()) {
            stmt.execute("ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;");
            System.out.println("Disabled RLS on profiles");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
