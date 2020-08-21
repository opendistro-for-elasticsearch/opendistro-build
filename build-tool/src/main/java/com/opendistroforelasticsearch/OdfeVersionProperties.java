package com.opendistroforelasticsearch;

import org.elasticsearch.gradle.VersionProperties;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
/**
 * Accessor for shared dependency versions used by elasticsearch. Imports the VersionProperties.java class (version.properties file stats)
 * and adds additional ODFE version stated in resources/odfe-version.properties file
 */
public class OdfeVersionProperties {
    private static Map<String, String> odfe_versions = new HashMap<String, String>();
    private static final String opendistroforelasticsearch;

    static {
        odfe_versions = VersionProperties.getVersions(); //getting all ES versions from their version.properties
        Properties odprops = getOdfeVersionProperties();

        //GetSet properties from odfe-version.properties
        opendistroforelasticsearch = odprops.getProperty("opendistroforelasticsearch");

        for (String property : odprops.stringPropertyNames()) { //get all keys from properties
            odfe_versions.put(property, odprops.getProperty(property)); //put or add everything to dictionary
        }

    }

    private static Properties getOdfeVersionProperties() {
        Properties props = new Properties();
        InputStream propsStream = OdfeVersionProperties.class.getResourceAsStream("/odfe-version.properties");
        if (propsStream == null) {
            throw new IllegalStateException("/odfe-version.properties resource missing");
        }
        try {
            props.load(propsStream);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load odfe-version properties", e);
        }
        return props;
    }

    // Read-Only (getter) access
    public static Map<String, String> getOdfe_versions() {
        return odfe_versions;
    }

    public static String getOpendistroVersion() {
        return opendistroforelasticsearch;
    }
}
