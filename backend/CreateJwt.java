import java.util.Base64;
import java.nio.charset.StandardCharsets;

public class CreateJwt {
    public static void main(String[] args) {
        String header = Base64.getUrlEncoder().withoutPadding().encodeToString("{\"alg\":\"ES256\",\"typ\":\"JWT\"}".getBytes(StandardCharsets.UTF_8));
        String payload = Base64.getUrlEncoder().withoutPadding().encodeToString("{\"aud\":\"authenticated\",\"exp\":1700000000,\"sub\":\"123e4567-e89b-12d3-a456-426614174000\",\"email\":\"test@test.com\"}".getBytes(StandardCharsets.UTF_8));
        String signature = Base64.getUrlEncoder().withoutPadding().encodeToString("dummy".getBytes(StandardCharsets.UTF_8));
        System.out.println(header + "." + payload + "." + signature);
    }
}
