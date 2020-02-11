public class DataProvider {
    @org.testng.annotations.DataProvider(name = "verifyPanelElement-data-provider")
    public Object[][] dataProviderVerifyPanelElement()
    {
        String[][] data = new String[8][5];
        //for discover
        data[0][0] = "/html/body/div[1]/div/div[2]/div[2]/div[1]/div/ul[3]/li[1]/span/a";
        data[0][1] = "XPATH";
        data[0][2] = "//*[@id=\"createIndexPatternReact\"]/div[1]/div[1]/h1";
        data[0][3] = "XPATH";
        data[0][4] = "Discover Option";

        //visualize
        data[1][0] = "/html/body/div[1]/div/div[2]/div[2]/div[1]/div/ul[3]/li[2]/span/a";
        data[1][1] = "XPATH";
        data[1][2] = "//*[@id=\"createIndexPatternReact\"]/div[1]/div[1]/h1";
        data[1][3] = "XPATH";
        data[1][4] = "Visualize Option";

        //index management kibana
        data[2][0] = "/html/body/div[1]/div/div[2]/div[2]/div[1]/div/ul[3]/li[4]/span/a";
        data[2][1] = "XPATH";
        data[2][2] = "/html/body/div[1]/div/div[3]/div/div[3]/div/div[1]/nav/div/div/a";
        //data[2][2] = "//*[@id=\"kibana-body\"]/div/div[3]/div/div[3]/div/div[2]/div/div/div[1]/div[1]/h3";
        data[2][3] = "XPATH";
        data[2][4] = "Index Management Option";

        //alerting
        data[3][0] = "/html/body/div[1]/div/div[2]/div[2]/div[1]/div/ul[3]/li[5]/span/a";
        data[3][1] = "XPATH";
        data[3][2] = "//*[@id=\"kibana-body\"]/div/div[3]/div/div[3]/div/div/div[2]/div/div[1]/div[1]/h3";
        data[3][3] = "XPATH";
        data[3][4] = "Alerting Option";

        //DevTools
        data[4][0] = "/html/body/div[1]/div/div[2]/div[2]/div[1]/div/ul[3]/li[6]/span/a";
        data[4][1] = "XPATH";
        data[4][2] = "/html/body/div[1]/div/div[2]/div[1]/nav/a";
        data[4][3] = "XPATH";
        data[4][4] = "DevTools Option";

        //management
        data[5][0] = "/html/body/div[1]/div/div[2]/div[2]/div[1]/div/ul[3]/li[7]/span/a";
        data[5][1] = "XPATH";
        data[5][2] = "/html/body/div[1]/div/div[2]/div[1]/nav/a";
        data[5][3] = "XPATH";
        data[5][4] = "Management Option";

        //security
        data[6][0] = "/html/body/div[1]/div/div[2]/div[2]/div[1]/div/ul[3]/li[8]/span/a";
        data[6][1] = "XPATH";
        data[6][2] = "opendistro_security.link.securityconfig";
        data[6][3] = "ID";
        data[6][4] = "Security Option";

        //tenants
        data[7][0] = "/html/body/div[1]/div/div[2]/div[2]/div[1]/div/ul[3]/li[9]/span/a";
        data[7][1] = "XPATH";
        data[7][2] = "opendistro_security.button.show_dashboard.private";
        data[7][3] = "ID";
        data[7][4] = "Tenants Option";
        return data;
    }

    @org.testng.annotations.DataProvider(name = "clickOption-data-provider")
    public Object[][] dataProviderClickOption(){
        String[][] data = new String[1][2];
        data[0][0] = "//*[@id=\"kibana-app\"]/div[4]/div/div/div/div/div/span[3]/footer/button/span/span";
        data[0][1] = "XPATH";
        return data;
    }
}
