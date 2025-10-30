pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    repositories {
        // plugin artifacts can be published to multiple repositories; include all
        // typical repositories and the Gradle Plugin Portal. Add explicit
        // Google Maven URL as a fallback for environments with repository
        // resolution issues.
        google()
        maven { url = uri("https://maven.google.com") }
        // Gradle Plugin Portal as maven repository (helps resolving kotlin-dsl and
        // other plugins in some network/proxy environments)
        maven { url = uri("https://plugins.gradle.org/m2/") }
        mavenCentral()
        gradlePluginPortal()
    }

    // include the Flutter plugin build after repositories so that plugin
    // resolution can consult the declared repositories first.
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    // Force resolution to known published modules for Gradle plugins. This
    // helps environments where the plugin block cannot automatically locate
    // the plugin artifact (network/proxy or repository ordering issues).
    resolutionStrategy {
        eachPlugin {
            when (requested.id.id) {
                // prefer newer AGP/Kotlin that match modern Gradle wrappers and
                // the runtime environment; adjust if network cannot resolve
                // these artifacts.
                "com.android.application" -> useModule("com.android.tools.build:gradle:8.9.1")
                "org.jetbrains.kotlin.android" -> useModule("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.20")
                // ensure kotlin-dsl plugin can be resolved when requested by
                // Flutter's gradle scripts
                "org.gradle.kotlin.kotlin-dsl" -> useModule("org.gradle.kotlin.kotlin-dsl:org.gradle.kotlin.kotlin-dsl.gradle.plugin:5.1.2")
                // keep flutter plugin loader mapping
                "dev.flutter.flutter-plugin-loader" -> useModule("dev.flutter:flutter-plugin-loader:1.0.0")
            }
        }
    }
}

// Ensure all projects use the correct repositories for dependency resolution.
dependencyResolutionManagement {
    repositoriesMode.set(org.gradle.api.initialization.resolve.RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        maven { url = uri("https://maven.google.com") }
        mavenCentral()
        maven { url = uri("https://plugins.gradle.org/m2/") }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.4" apply false
    id("org.jetbrains.kotlin.android") version "1.9.10" apply false
}

include(":app")
