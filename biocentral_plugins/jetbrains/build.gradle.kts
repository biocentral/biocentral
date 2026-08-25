import org.jetbrains.intellij.platform.gradle.TestFrameworkType

plugins {
    id("java")
    id("org.jetbrains.intellij.platform") version "2.1.0"
}

group = "com.biocentral"
version = "0.1.0"

repositories {
    mavenCentral()
    intellijPlatform {
        defaultRepositories()
    }
}

dependencies {
    intellijPlatform {
        // Build against PyCharm Community; the plugin also works in PyCharm
        // Professional and IntelliJ IDEA Ultimate (both ship the Python plugin
        // and expose the `com.intellij.modules.python` module).
        pycharmCommunity("2024.2")

        // Python plugin bundled with PyCharm Community. `Pythonid` is the
        // equivalent in the Professional line; either satisfies the
        // `com.intellij.modules.python` dependency declared in plugin.xml.
        bundledPlugin("PythonCore")

        instrumentationTools()

        testFramework(TestFrameworkType.Platform)
    }

    testImplementation("org.junit.jupiter:junit-jupiter:5.10.2")
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

tasks.withType<JavaCompile>().configureEach {
    options.encoding = "UTF-8"
    options.release.set(21)
}

intellijPlatform {
    pluginConfiguration {
        ideaVersion {
            sinceBuild.set("242")
            untilBuild.set("252.*")
        }
    }
    publishing {
        // Populate BIOCENTRAL_PLUGIN_TOKEN in the environment to enable publishing.
        token.set(providers.environmentVariable("BIOCENTRAL_PLUGIN_TOKEN"))
    }
}

tasks.test {
    useJUnitPlatform()
}
