import com.sun.source.tree.AssertTree;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.testng.Assert;

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

    public void assertPageByElement(String location, String locator) {
        Actions actions = new Actions(this.driver);
        Assert.assertTrue(actions.checkElement(location, locator), "Expected Page Not Found: Element mismatched-"+location+" "+locator);
    }
    public void assertPageByElement(By locator) {
        Actions actions = new Actions(this.driver);
        Assert.assertTrue(actions.checkElement(locator), "Expected Page Not Found: Element mismatched-"+locator);
    }


}
