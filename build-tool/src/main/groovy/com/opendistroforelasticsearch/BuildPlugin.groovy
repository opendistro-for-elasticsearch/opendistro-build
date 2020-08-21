package com.opendistroforelasticsearch


import org.elasticsearch.gradle.info.BuildParams
import org.elasticsearch.gradle.precommit.CheckstylePrecommitPlugin
import org.gradle.api.InvalidUserDataException
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.Task
import org.gradle.api.plugins.ExtraPropertiesExtension
import org.gradle.api.tasks.Copy
import org.gradle.api.tasks.SourceSet
import org.gradle.api.tasks.TaskProvider
import org.gradle.api.tasks.bundling.Zip
import com.github.jengelman.gradle.plugins.shadow.ShadowPlugin
import org.elasticsearch.gradle.test.RestIntegTestTask
import org.elasticsearch.gradle.testclusters.RunTask
import org.elasticsearch.gradle.testclusters.TestClustersPlugin



class BuildPlugin implements Plugin<Project> {

    @Override
    void apply(Project project) {
        project.pluginManager.apply(TestClustersPlugin)
        project.pluginManager.apply('elasticsearch.java')
        project.pluginManager.apply(CheckstylePrecommitPlugin)

        //extensions to be used by users in their build.gradle
        PluginPropertiesExtension extension = project.extensions.create( 'odfeplugin', PluginPropertiesExtension, project)
        project.extensions.getByType(ExtraPropertiesExtension).set('versions', OdfeVersionProperties.odfe_versions)

        createIntegTestTask(project)
        createBundleTasks(project, extension)
        configureDependencies(project)
        project.tasks.integTest.dependsOn(project.tasks.bundlePlugin)

        boolean isXPackModule = project.path.startsWith(':x-pack:plugin')
        boolean isModule = project.path.startsWith(':modules:') || isXPackModule

        if (isModule) {
            project.testClusters.integTest.module(project.tasks.bundlePlugin.archiveFile)
        } else {
            project.testClusters.integTest.plugin(project.tasks.bundlePlugin.archiveFile)
        }

        project.afterEvaluate {
            project.extensions.getByType(PluginPropertiesExtension).extendedPlugins.each { pluginName ->
                // Auto add dependent modules to the test cluster
                if (project.findProject(":modules:${pluginName}") != null) {
                    project.integTest.dependsOn(project.project(":modules:${pluginName}").tasks.bundlePlugin)
                    project.testClusters.integTest.module(
                            project.project(":modules:${pluginName}").tasks.bundlePlugin.archiveFile
                    )
                }
            }

            PluginPropertiesExtension extension1 = project.getExtensions().getByType(PluginPropertiesExtension.class)
            String name = extension1.name
            project.archivesBaseName = name
            project.description = extension1.description



            if (extension1.name == null) {
                throw new InvalidUserDataException('name is a required setting for odfeplugin')
            }
            if (extension1.description == null) {
                throw new InvalidUserDataException('description is a required setting for odfeplugin')
            }
            if (extension1.classname == null) {
                throw new InvalidUserDataException('classname is a required setting for odfeplugin')
            }

            Map<String, String> properties = [
                    'name'                : extension1.name,
                    'description'         : extension1.description,
                    'version'             : extension1.version,
                    'elasticsearchVersion': OdfeVersionProperties.odfe_versions.get("elasticsearch"),
                    'javaVersion'         : project.targetCompatibility as String,
                    'classname'           : extension1.classname,
                    'extendedPlugins'     : extension1.extendedPlugins.join(','),
                    'hasNativeController' : extension1.hasNativeController,
                    'requiresKeystore'    : extension1.requiresKeystore
            ]
            project.tasks.named('pluginProperties').configure {
                expand(properties)
                inputs.properties(properties)
            }
        }
        //disable integTest task if project has been converted to use yaml or java rest test plugin
        // added as precaution
        project.pluginManager.withPlugin("elasticsearch.yaml-rest-test") {
            project.tasks.integTest.enabled = false
        }
        project.pluginManager.withPlugin("elasticsearch.java-rest-test") {
            project.tasks.integTest.enabled = false
        }

        project.configurations.getByName('default')
                .extendsFrom(project.configurations.getByName('runtimeClasspath'))
        // allow running ES with this plugin in the foreground of a build
        project.tasks.register('run', RunTask) {
            group = 'Build tool'
            dependsOn(project.tasks.bundlePlugin)
            useCluster project.testClusters.integTest
        }
    }

    private static void configureDependencies(Project project) {
        project.dependencies {
            if (BuildParams.internal) {
                compileOnly project.project(':server')
                testImplementation project.project(':test:framework')
            } else {
                compileOnly "org.elasticsearch:elasticsearch:${project.versions.elasticsearch}"
                testCompile "org.elasticsearch.test:framework:${project.versions.elasticsearch}"
            }
            // we "upgrade" these optional deps to provided for plugins, since they will run
            // with a full elasticsearch server that includes optional deps
            compileOnly "org.locationtech.spatial4j:spatial4j:${project.versions.spatial4j}"
            compileOnly "org.locationtech.jts:jts-core:${project.versions.jts}"
            compileOnly "org.apache.logging.log4j:log4j-api:${project.versions.log4j}"
            compileOnly "org.apache.logging.log4j:log4j-core:${project.versions.log4j}"
            compileOnly "org.elasticsearch:jna:${project.versions.jna}"
        }
    }

    /** Adds an integTest task which runs rest tests */
    private static void createIntegTestTask(Project project) {
        RestIntegTestTask integTest = project.tasks.create('integTest', RestIntegTestTask.class)
        integTest.mustRunAfter('precommit', 'test')
        project.check.dependsOn(integTest)
    }

    /**
     * Adds a bundlePlugin task which builds the zip containing the plugin jars,
     * metadata, properties, and packaging files
     */
    private static void createBundleTasks(Project project, PluginPropertiesExtension extension) {
        File pluginMetadata = project.file('src/main/plugin-metadata')
        File templateFile = new File(project.buildDir, "templates/plugin-descriptor.properties")

        // create tasks to build the properties file for this plugin
        TaskProvider<Task> copyPluginPropertiesTemplate = project.tasks.register('copyPluginPropertiesTemplate') {
            group = 'Build tool'
            outputs.file(templateFile)
            doLast {
                InputStream resourceTemplate = BuildPlugin.getResourceAsStream("/${templateFile.name}") //gets the file from resources dir
                templateFile.setText(resourceTemplate.getText('UTF-8'), 'UTF-8')
            }
        }

        // Copy the plugin-descriptor file to generated-resources folder
        TaskProvider<Copy> buildProperties = project.tasks.register('pluginProperties', Copy) {
            group = 'Build tool'
            dependsOn(copyPluginPropertiesTemplate)
            from(templateFile)
            into("${project.buildDir}/generated-resources")
        }

        // add the plugin properties and metadata to test resources, so unit tests can
        // know about the plugin (used by test security code to statically initialize the plugin in unit tests)
        SourceSet testSourceSet = project.sourceSets.test
        testSourceSet.output.dir("${project.buildDir}/generated-resources", builtBy: buildProperties)
        testSourceSet.resources.srcDir(pluginMetadata)

        // create the actual bundle task, which zips up all the files for the plugin
        TaskProvider<Zip> bundle = project.tasks.register('bundlePlugin', Zip) {
            group = 'Build tool'
            from buildProperties
            from pluginMetadata // metadata (eg custom security policy)
            /*
             * If the plugin is using the shadow plugin then we need to bundle
             * that shadow jar.
             */
            from { project.plugins.hasPlugin(ShadowPlugin) ? project.shadowJar : project.jar }
            from project.configurations.runtimeClasspath - project.configurations.compileOnly
            // extra files for the plugin to go into the zip
            from('src/main/packaging') // TODO: move all config/bin/_size/etc into packaging
            from('src/main') {
                include 'config/**'
                include 'bin/**'
            }
        }
        project.tasks.named('assemble').configure {
            dependsOn(bundle)
        }

        // also make the zip available as a configuration (used when depending on this project)
        // Not needed for ODFE
//        project.configurations.create('zip')
//        project.artifacts.add('zip', bundle)
    }
}
