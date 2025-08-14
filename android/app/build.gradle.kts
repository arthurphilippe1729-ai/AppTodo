plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_todo_plus"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.app_todo_plus"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    // 📌 IMPORTANT : pour compatibilité avec emoji_picker & image_picker
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

kotlin {
    jvmToolchain(17)
}
