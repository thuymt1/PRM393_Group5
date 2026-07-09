import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.nio.charset.StandardCharsets;

public class TestJwt {
    public static void main(String[] args) {
        String payloadJson = "{\"aud\":\"authenticated\",\"exp\":1700000000,\"sub\":\"123e4567-e89b-12d3-a456-426614174000\",\"email\":\"test@test.com\"}";
        String sub = null;
        Matcher mSub = Pattern.compile("\"sub\"\\s*:\\s*\"([^\"]+)\"").matcher(payloadJson);
        if (mSub.find()) sub = mSub.group(1);
        System.out.println("Sub: " + sub);
    }
}
