plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.emzaro.liquidglasslauncher"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.emzaro.liquidglasslauncher"
        minSdk = 26
        targetSdk = 35
        versionCode = 2
        versionName = "1.1-liquid-glass"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.15.0")
}
