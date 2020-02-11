import org.openqa.selenium.WebDriver;
import java.util.concurrent.TimeUnit;

public class AssertPage {
    WebDriver driver;

    public AssertPage(WebDriver driver) {
        this.driver = driver;
        this.driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
    }

    public boolean assertPageByTitle(String expectedTitle) {
        Actions actions = new Actions(this.driver);
        return actions.verifyTitle(expectedTitle);
    }

    public boolean assertPageByElement(String location, String locator) {
        Actions actions = new Actions(this.driver);
        return actions.checkElement(location, locator);
    }


}
