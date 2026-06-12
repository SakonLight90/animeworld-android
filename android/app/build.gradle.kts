plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    ndkVersion = "28.2.13676358"
    namespace = "com.savage.anime"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    signingConfigs {
        create("release") {
            val keystoreBase64: String? = System.getenv("CM_KEYSTORE")
            if (keystoreBase64 != null) {
                storeFile = File("$projectDir/upload-keystore.jks")
                storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("CM_KEY_ALIAS")
                keyPassword = System.getenv("CM_KEY_PASSWORD")
            }
        }
    }

    defaultConfig {
        applicationId = "com.savage.anime"
        minSdk = 31
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
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

tasks.register("prepareKeystore") {
    doLast {
        val keystoreBase64 = System.getenv("CM_KEYSTORE")
        if (keystoreBase64 != null) {
            val keystoreFile = File("$projectDir/upload-keystore.jks")
            keystoreFile.writeBytes(java.util.Base64.getDecoder().decode(keystoreBase64))
        }
    }
}

tasks.whenTaskAdded {
    if (name == "preReleaseBuild") {
        dependsOn("prepareKeystore")
    }
}
