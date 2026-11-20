import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: android/key.properties (git-ignored) points at your upload keystore.
// See docs/RELEASE.md. Never commit the keystore or key.properties.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null

// AdMob App ID: pass -PADMOB_APP_ID=ca-app-pub-xxx~yyy (or set it in gradle.properties / env).
// Falls back to Google's public *test* App ID so the Ads SDK never crashes on startup.
val admobAppId: String = (project.findProperty("ADMOB_APP_ID") as String?)
    ?: System.getenv("ADMOB_APP_ID")
    ?: "ca-app-pub-3940256099942544~3347511713"

android {
    namespace = "com.outfitly.outfitly"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Must be globally unique on Google Play and can never change after the first upload.
        applicationId = "com.outfitly.outfitly"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKey) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // Lets `flutter run --release` work locally. Play Console will REJECT an AAB signed this way.
                logger.warn("WARNING: android/key.properties not found - release build is signed with the DEBUG key.")
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
