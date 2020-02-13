import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.testng.Assert;
import java.io.File;
import java.io.FileReader;
import java.util.Enumeration;
import java.util.Properties;
import java.util.concurrent.TimeUnit;

public class Actions {
    WebDriver driver;

    public Actions(WebDriver driver) {
        this.driver = driver;
        this.driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);
    }

    public boolean fillAllInputFields(File inputFile) {
        Properties loginProperties = new Properties();
        try {
            loginProperties.load(new FileReader(inputFile));
            Enumeration fields = loginProperties.keys();
            while (fields.hasMoreElements()) {
                String field = (String) fields.nextElement();
                String value = loginProperties.getProperty(field);
                this.type(field, value);
            }
        } catch (Exception e) {
            Assert.assertTrue(false, "loginProperties file not found");
            return false;
        }
        return true;
    }

    public boolean type(String field, String value) {
        String locator = field.split("[.]")[1];
        String locatorValue = field.split("[.]")[0];

        switch (locator) {
            case "ID":
                typeByID(locatorValue, value);
                break;
            case "XPATH":
                typeByXPATH(locatorValue, value);
                break;
            case "NAME":
                typeByNAME(locatorValue, value);
                break;
            default:
                Assert.assertTrue(false, "Input Field Unknown:" + locator);
                return false;
        }
        return true;
    }

    public boolean click(String location, String locator) {
        try {
            switch (locator) {
                case "ID":
                    return clickByID(location);
                case "NAME":
                    return clickByNAME(location);
                case "XPATH":
                    return clickByXPATH(location);
                default:
                    Assert.assertTrue(false, "Unknown locator" + locator);
            }
        } catch (Exception e) {
            Assert.assertTrue(false, "Invalid location:" + location);
        }
        return false;
    }

    public boolean click(By locator){
        if(this.driver.findElements(locator).size()==0){
            System.out.println("Button Not Found:"+locator);
            return false;
        }
        WebElement button = this.driver.findElement(locator);
        button.click();
        return true;
    }

    public boolean typeByID(String locatorValue, String value) {
        try {
            WebElement element = this.driver.findElement((By.id(locatorValue)));
            element.sendKeys(value);
        } catch (Exception e) {
            Assert.assertTrue(false, "Could not locate element:" + locatorValue);
            return false;
        }
        return true;
    }

    public boolean typeByNAME(String locatorValue, String value) {
        try {
            WebElement element = this.driver.findElement((By.name(locatorValue)));
            element.sendKeys(value);
        } catch (Exception e) {
            Assert.assertTrue(false, "Could not locate element:" + locatorValue);
            return false;
        }
        return true;
    }

    public boolean typeByXPATH(String locatorValue, String value) {
        try {
            WebElement element = this.driver.findElement((By.xpath(locatorValue)));
            element.sendKeys(value);
        } catch (Exception e) {
            Assert.assertTrue(false, "Could not locate element:" + locatorValue);
            return false;
        }
        return true;
    }

    public boolean clickByID(String locatorValue) {
        try {
            WebElement button = this.driver.findElement((By.id(locatorValue)));
            button.click();
        } catch (Exception e) {
            Assert.assertTrue(false, "Could not locate element:" + locatorValue);
            return false;
        }
        return true;
    }

    public boolean clickByNAME(String locatorValue) {
        try {
            WebElement button = this.driver.findElement((By.name(locatorValue)));
            button.click();
        } catch (Exception e) {
            Assert.assertTrue(false, "Could not locate element:" + locatorValue);
            return false;
        }
        return true;
    }

    public boolean clickByXPATH(String locatorValue) {
        try {
            WebElement button = this.driver.findElement((By.xpath(locatorValue)));
            button.click();
        } catch (Exception e) {
            Assert.assertTrue(false, "Could not locate element:" + locatorValue);
            return false;
        }
        return true;
    }

    //Locator:{NAME, ID, XPATH}
    public boolean checkElement(String location, String locator) {
        try {
            switch (locator) {
                case "ID":
                    if (this.driver.findElements(By.id(location)).size() > 0) {
                        return true;
                    }
                    break;
                case "NAME":
                    if (this.driver.findElements(By.name(location)).size() > 0) {
                        return true;
                    }
                    break;
                case "XPATH":
                    if (this.driver.findElements(By.xpath(location)).size() > 0) {
                        return true;
                    }
                    break;
            }
        } catch (Exception e) {
            System.out.println("Invalid location:" + location);
        }
        System.out.println("Element not found:"+location+":"+locator);
        return false;
    }
    public boolean checkElement(By locator){
        if(this.driver.findElements(locator).size()>0)return true;
        return false;
    }
    public boolean verifyTitle(String expectedTitle) {
        try {
            String actualTitle = this.driver.getTitle();
            Assert.assertEquals(actualTitle, expectedTitle, "Title mismatched");
            return true;
        } catch (Exception e) {
            Assert.assertTrue(false, "Could not get Title of the page");
            return false;
        }
    }
}
