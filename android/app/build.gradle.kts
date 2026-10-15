import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.mercansoftware.wallet_elite"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mercansoftware.wallet_elite"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion // Flutter 3.47: en az 24 (Android 7.0)
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

// Release AAB'nin sürüm numaralı bir kopyası da bırakılır
// (ör. wallet_elite-1.1.2+5.aab); eski sürümlerin dosyaları üzerine yazılmaz.
// Flutter kendi kontrolleri için app-release.aab adını beklediği için o dosya
// olduğu gibi kalır.
tasks.matching { it.name == "bundleRelease" }.configureEach {
    val bundleDir = layout.buildDirectory.dir("outputs/bundle/release")
    val versionedName = "wallet_elite-${flutter.versionName}+${flutter.versionCode}.aab"
    doLast {
        val dir = bundleDir.get().asFile
        val source = File(dir, "app-release.aab")
        if (source.exists()) {
            val target = File(dir, versionedName)
            source.copyTo(target, overwrite = true)
            println("Sürüm numaralı AAB: ${target.absolutePath}")
        }
    }
}
