import org.openqa.selenium.By;

public class DataProvider {

    @org.testng.annotations.DataProvider(name = "clickOption-data-provider")
    public Object[][] dataProviderClickOption(){
        String[][] data = new String[1][2];
        data[0][0] = "//*[@id=\"kibana-app\"]/div[4]/div/div/div/div/div/span[3]/footer/button/span/span";
        data[0][1] = "XPATH";
        return data;
    }


    @org.testng.annotations.DataProvider(name = "verifyPanelElement-data-provider-2")
    public Object[][] dataProviderVerifyPanelElement2()
    {
        Object[][] data = new Object[9][3];
        //for discover
        data[0][0] = By.xpath("//*[@id=\"navDrawerMenu\"]/ul[3]/li[1]/span/a");
        data[0][1] = By.partialLinkText("Create index pattern");
        data[0][2] = "Discover Option";

        //visualize
        data[1][0] = By.xpath("//*[@id=\"navDrawerMenu\"]/ul[3]/li[2]/span/a");
        data[1][1] = By.partialLinkText("Create index pattern");
        data[1][2] = "Visualize Option";

        //dashboard
        data[2][0] = By.xpath("//*[@id=\"navDrawerMenu\"]/ul[3]/li[3]/span/a");
        data[2][1] = By.partialLinkText("Create index pattern");
        data[2][2] = "Visualize Option";

        //index management kibana
        data[3][0] = By.xpath("//*[@id=\"navDrawerMenu\"]/ul[3]/li[4]/span/a");
        data[3][1] = By.partialLinkText("Index Policies");
        data[3][2] = "Index Management Option";

        //alerting
        data[4][0] = By.xpath("//*[@id=\"navDrawerMenu\"]/ul[3]/li[5]/span/a");
        data[4][1] = By.partialLinkText("Alerting");
        data[4][2] = "Alerting Option";

        //DevTools
        data[5][0] = By.xpath("//*[@id=\"navDrawerMenu\"]/ul[3]/li[6]/span/a");
        data[5][1] = By.partialLinkText("Dev Tools");
        data[5][2] = "DevTools Option";

        //management
        data[6][0] = By.xpath("//*[@id=\"navDrawerMenu\"]/ul[3]/li[7]/span/a");
        data[6][1] = By.partialLinkText("Management");
        data[6][2] = "Management Option";

        //security
        data[7][0] = By.xpath("//*[@id=\"navDrawerMenu\"]/ul[3]/li[8]/span/a");
        data[7][1] = By.partialLinkText("Role Mappings");
        data[7][2] = "Security Option";

        //tenants
        data[8][0] = By.xpath("//*[@id=\"navDrawerMenu\"]/ul[3]/li[9]/span/a");
        data[8][1] = By.partialLinkText("Global");
        data[8][2] = "Tenant";
        return data;
    }


}
