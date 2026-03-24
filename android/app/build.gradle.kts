import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // If you use Firebase / Crashlytics / Analytics, keep this:
    // id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must come after Android & Kotlin:
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.link_vault"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.link_vault"
        minSdk = 25
        targetSdk = 35
        versionCode = flutter.versionCode.toInt()
        versionName = flutter.versionName
    }

    // ───────────────────────────────────────────────────
    // 1. Enable BuildConfig generation (necessary because we use buildConfigField)
    // ───────────────────────────────────────────────────
    buildFeatures {
        // By default, buildConfig is true, but explicitly enabling it avoids the EvalIssueException
        buildConfig = true
    }

    // ───────────────────────────────────────────────────
    // 1. Declare the flavor dimension before using it
    // ───────────────────────────────────────────────────
    flavorDimensions += "env"

    productFlavors {
        create("production") {
            dimension = "env"
            // If you need a constant in BuildConfig:
            buildConfigField("String", "FLAVOR", "\"prod\"")
            // Put prod-specific resources (including google-services.json) under:
            //   app/src/production/
        }
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            buildConfigField("String", "FLAVOR", "\"dev\"")
            // Override app_name, etc.
            resValue("string", "app_name", "Link Vault (Dev)")
            // Put dev-specific resources (including google-services.json) under:
            //   app/src/dev/
        }
    }

    // ───────────────────────────────────────────────────
    // 2. Signing configurations (load key.properties if it exists)
    // ───────────────────────────────────────────────────
    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProps = Properties().apply {
                    load(keystorePropertiesFile.inputStream())
                }
                // Ensure key.properties has:
                //   storeFile=/absolute/path/to/keystore.jks
                //   storePassword=yourStorePassword
                //   keyAlias=yourKeyAlias
                //   keyPassword=yourKeyPassword
                storeFile = file(keystoreProps.getProperty("storeFile"))
                storePassword = keystoreProps.getProperty("storePassword")
                keyAlias    = keystoreProps.getProperty("keyAlias")
                keyPassword = keystoreProps.getProperty("keyPassword")
            }
        }
    }

    // ───────────────────────────────────────────────────
    // 3. Build types
    // ───────────────────────────────────────────────────
    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled   = false
            isShrinkResources = false
        }
        getByName("release") {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
            isMinifyEnabled   = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }
}

flutter {
    source = "../.."
}
