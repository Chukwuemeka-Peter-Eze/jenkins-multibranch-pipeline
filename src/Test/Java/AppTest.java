import com.example.Application;
import org.junit.Test;
import static org.junit.Assert.*;

public class AppTest {
    Application myApp = ne Application();

    string result = myApp.getSttus();

    assertEquals("OK", result);
}