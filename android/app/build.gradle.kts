plugins {
    id("com.android.application")
}

android {
    namespace = "com.hyo.app"
    compileSdk = 35
    ndkVersion = "29.0.14206865"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            // Include app assets (e.g. fonts), project root src/, and project root packages/
            assets.srcDirs("src/main/assets", "../../src", "../../packages")
        }
    }

    defaultConfig {
        applicationId = "com.hyo.app"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "0.1.0"

        ndk {
            abiFilters.addAll(listOf("arm64-v8a"))
        }

        externalNativeBuild {
            cmake {
                cppFlags += listOf("-std=c++20")
                arguments += listOf("-DANDROID_STL=c++_shared")
            }
        }
    }

    externalNativeBuild {
        cmake {
            path = file("../CMakeLists.txt")
            version = "3.22.1"
        }
    }

    signingConfigs {
        create("hyoRelease") {
            val storePath = project.findProperty("HYOSIGN_STORE_FILE") as String?
            if (storePath != null) {
                storeFile = file(storePath)
                keyAlias = project.findProperty("HYOSIGN_KEY_ALIAS") as String?
                storePassword = project.findProperty("HYOSIGN_STORE_PASS") as String?
                keyPassword = project.findProperty("HYOSIGN_KEY_PASS") as String?
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = if (project.hasProperty("HYOSIGN_STORE_FILE")) {
                signingConfigs.getByName("hyoRelease")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}
