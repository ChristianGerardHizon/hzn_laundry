// ✅ Required imports
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ✅ Load keystore.properties if it exists
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}

android {
    namespace = "com.hznsystems.hizonelaundry"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.hznsystems.hizonelaundry"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["usesCleartextTraffic"] = "false"
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Hi-Zone Laundry Dev")
            manifestPlaceholders["usesCleartextTraffic"] = "true"
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Hi-Zone Laundry Stg")
            manifestPlaceholders["usesCleartextTraffic"] = "false"
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Hi-Zone Laundry")
            manifestPlaceholders["usesCleartextTraffic"] = "false"
        }
    }

    // ✅ Define the "release" signing config correctly
    // ✅ Define the "release" signing config correctly
    signingConfigs {
        create("release") {
            val envKeystorePath = System.getenv()["CM_KEYSTORE_PATH"]
            
            // Check if we are in CI AND the keystore path is actually set
            if (System.getenv()["CI"] == "true" && !envKeystorePath.isNullOrEmpty()) {
                storeFile = file(envKeystorePath)
                storePassword = System.getenv()["CM_KEYSTORE_PASSWORD"]
                keyAlias = System.getenv()["CM_KEY_ALIAS"]
                keyPassword = System.getenv()["CM_KEY_PASSWORD"]
            } else if (keystorePropertiesFile.exists()) {
                // Fallback to local key.properties if it exists
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            } else {
                // If neither exists, we don't set the release config.
                // This prevents the "path null" crash.
                // Note: Actual 'release' builds will fail signing, but 'debug' builds will work fine.
            }
        }
    }

    buildTypes {
        getByName("release")  {
            // ✅ Use the correct "release" signing config
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
