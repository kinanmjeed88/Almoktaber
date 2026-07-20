pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

// Workaround for AGP 8.0+ requiring namespace for dependencies
gradle.lifecycle.beforeProject {
    val project = this
    if (project.name == "isar_flutter_libs") {
        project.afterEvaluate {
            val androidExtension = project.extensions.findByName("android")
            if (androidExtension != null) {
                val clazz = androidExtension.javaClass
                val method = clazz.getMethod("setNamespace", String::class.java)
                method.invoke(androidExtension, "dev.isar.isar_flutter_libs")
            }
        }
    }
}

gradle.projectsEvaluated {
    allprojects {
        if (hasProperty("android")) {
            val androidExt = extensions.findByName("android")
            if (androidExt != null) {
                val clazz = androidExt.javaClass
                try {
                    val compileSdkVersionMethod = clazz.getMethod("setCompileSdkVersion", Int::class.java)
                    compileSdkVersionMethod.invoke(androidExt, 34) // Force compileSdk to 34 to avoid lStar resource error from higher SDK version
                } catch (e: Exception) {
                    try {
                        val compileSdkMethod = clazz.getMethod("setCompileSdk", Int::class.java)
                        compileSdkMethod.invoke(androidExt, 34)
                    } catch (e2: Exception) {
                    }
                }
            }
        }
    }
}

include(":app")
