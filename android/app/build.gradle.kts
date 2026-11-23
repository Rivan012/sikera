import java.util.Base64

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun loadDotEnv(envFile: java.io.File): Map<String, String> {
    if (!envFile.exists()) return emptyMap()
    val values = mutableMapOf<String, String>()
    envFile.readLines().forEach { rawLine ->
        val line = rawLine.trim()
        if (line.isEmpty() || line.startsWith("#")) return@forEach
        val separator = line.indexOf('=')
        if (separator <= 0) return@forEach
        val key = line.substring(0, separator).trim()
        var value = line.substring(separator + 1).trim()
        if (value.length >= 2 &&
            ((value.startsWith("\"") && value.endsWith("\"")) ||
                (value.startsWith("'") && value.endsWith("'")))
        ) {
            value = value.substring(1, value.length - 1).trim()
        }
        values[key] = value
    }
    return values
}

fun loadDartDefines(rawDefines: String?): Map<String, String> {
    if (rawDefines.isNullOrBlank()) return emptyMap()
    val values = mutableMapOf<String, String>()
    rawDefines.split(',').forEach { encoded ->
        val trimmed = encoded.trim()
        if (trimmed.isEmpty()) return@forEach
        try {
            val decoded = String(Base64.getDecoder().decode(trimmed), Charsets.UTF_8)
            val separator = decoded.indexOf('=')
            if (separator > 0) {
                val key = decoded.substring(0, separator).trim()
                val value = decoded.substring(separator + 1).trim()
                values[key] = value
            }
        } catch (_: IllegalArgumentException) {
            // Abaikan entri dart-defines yang tidak valid.
        }
    }
    return values
}

fun resolveGoogleAuthRedirectScheme(
    dartDefines: Map<String, String>,
    dotEnv: Map<String, String>,
): String {
    fun readConfig(key: String): String {
        val fromDefine = dartDefines[key]?.trim().orEmpty()
        if (fromDefine.isNotEmpty()) return fromDefine
        return dotEnv[key]?.trim().orEmpty()
    }

    val explicitRedirect = listOf(
        readConfig("GOOGLE_ANDROID_REDIRECT_URI"),
        readConfig("GOOGLE_REDIRECT_URI"),
    ).firstOrNull { it.isNotEmpty() }

    if (!explicitRedirect.isNullOrEmpty() && explicitRedirect.contains(':')) {
        val scheme = explicitRedirect.substringBefore(':').trim().lowercase()
        if (scheme.isNotEmpty() && scheme != "http" && scheme != "https") {
            return scheme
        }
    }

    val clientId = listOf(
        readConfig("GOOGLE_ANDROID_CLIENT_ID"),
        readConfig("GOOGLE_CLIENT_ID"),
    ).firstOrNull { it.isNotEmpty() }

    val googleSuffix = ".apps.googleusercontent.com"
    if (!clientId.isNullOrEmpty() && clientId.lowercase().endsWith(googleSuffix)) {
        val prefix = clientId.dropLast(googleSuffix.length).lowercase()
        if (prefix.isNotEmpty()) {
            return "com.googleusercontent.apps.$prefix"
        }
    }

    return "com.sikera.app.sikera"
}

val dartDefinesMap = loadDartDefines(project.findProperty("dart-defines") as? String)
val dotEnvMap = loadDotEnv(rootProject.file("../.env"))
val googleAuthRedirectScheme = resolveGoogleAuthRedirectScheme(dartDefinesMap, dotEnvMap)

android {
    namespace = "com.sikera.app.sikera"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.sikera.app.sikera"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleAuthRedirectScheme"] = googleAuthRedirectScheme
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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
