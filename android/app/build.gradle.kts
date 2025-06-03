import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.catsoupstudios.solo_leveling"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    val keystoreProperties = Properties()
    val keystorePropertiesFile = File("E:/FlutterApps/solo_leveling/android/key.properties")

    if (keystorePropertiesFile.exists()) {
        println("✅ key.properties encontrado")
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    } else {
        throw Exception("❌ key.properties NO encontrado")
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = File(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    defaultConfig {
    applicationId = "com.catsoupstudios.solo_leveling"
    minSdk = 21
    targetSdk = 34
    versionCode = 18
    versionName = "1.1.18"
}

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}
