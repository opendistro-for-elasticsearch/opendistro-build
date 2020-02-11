import java.io.File;
import java.io.FileReader;
import java.util.Properties;
import java.util.concurrent.TimeUnit;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.testng.Assert;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

public class Tests {

    private WebDriver driver;
    private String baseURL;
    private Actions actions;
    private AssertPage assertPage;

    @BeforeTest
    public void initialize() {
    	System.out.println("initialize invoked");
        String propertyFilePath = System.getProperty("driverPropertiesFilePath");
        Properties propertiesFile = new Properties();
        try {
            propertiesFile.load(new FileReader(propertyFilePath));
            this.driver = initialiseBrowser(propertiesFile.getProperty("BROWSER"));
            this.driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
            actions = new Actions(this.driver);
            assertPage = new AssertPage(this.driver);
        } catch (Exception e) {
            System.out.println("driver not initialised");
        }
        try {
            this.baseURL = propertiesFile.getProperty("baseURL");

        } catch (Exception e) {
            System.out.println("baseURL not initialised");
        }

    }

    public WebDriver initialiseBrowser(String browser) {
        switch (browser) {
            case "FIREFOX":
                return new FirefoxDriver();
        }
        return null;
    }

    @Test(enabled = true, priority = 0)
    public void loadPage() {
    	if(this.driver == null || this.baseURL==null) {
    		if(this.driver == null) System.out.println("driver not initialised");
    		else System.out.println("baseURL not found");
    		Assert.assertTrue(false);
    	}
        this.driver.get(this.baseURL);
        assertPage.assertPageByTitle("Kibana");
    }

    @Test(enabled = true, priority = 1)
    public void loginTest() {
        Assert.assertTrue(assertPage.assertPageByTitle("Kibana"), "Page Not Found");
        //load the property file to take the input
        String loginPropertiesFilePath = System.getProperty("loginPropertiesFilePath");
        //fill the input to the fields
        actions.fillAllInputFields(new File(loginPropertiesFilePath));
        //Provide the login button id
        String loginbuttonID = "opendistro_security.login";
        //click the login button
        actions.click(loginbuttonID, "ID");
        //Verify the home page by verifying an element(identified by locator[NAME, ID, XPATH] and its value[location])
        Assert.assertTrue(assertPage.assertPageByElement("//*[@id=\"kibana-app\"]/div[4]/div/header/div/h1", "XPATH"), "Page Not Found");
    }

    @Test(enabled = true, priority = 3, dataProvider = "clickOption-data-provider", dataProviderClass = DataProvider.class)
    public void clickOption(String location, String locator) {
        actions.click(location, locator);
    }

    @Test(enabled = true, priority = 4, dataProvider = "verifyPanelElement-data-provider", dataProviderClass = DataProvider.class)
    public void verifyPanelElement(String iconLocation, String iconLocatorType, String expectedElementLocation, String expectedElementLocatorType, String description) {
        actions.click(iconLocation, iconLocatorType);
        Assert.assertTrue(assertPage.assertPageByElement(expectedElementLocation, expectedElementLocatorType), "Page Not Found:"+description);
    }

}
