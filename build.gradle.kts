plugins {
    java
    kotlin("jvm") version "1.4.10"
    kotlin("kapt") version "1.4.10"
}

group = "com.hadrienmp.epp"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
    jcenter()
}

dependencies {
    val kotlinVersion = "1.4.20-M2"
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlinVersion")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.4.1")
    implementation("org.jetbrains.kotlinx:kotlinx-collections-immutable-jvm:0.3.3")

    implementation("io.javalin:javalin:3.11.0")
    implementation("org.slf4j:slf4j-simple:1.7.30")
    implementation("de.neuland-bfi:pug4j:2.0.0-alpha-2")
    implementation("com.beust:klaxon:5.0.1")

    val arrowVersion = "0.11.0"
    implementation("io.arrow-kt:arrow-core:$arrowVersion")
    implementation("io.arrow-kt:arrow-syntax:$arrowVersion")
    kapt("io.arrow-kt:arrow-meta:$arrowVersion")

    implementation("com.michael-bull.kotlin-result:kotlin-result:1.1.9")

    val spekVersion = "2.0.9"
    testImplementation("org.spekframework.spek2:spek-dsl-jvm:$spekVersion")
    testRuntimeOnly("org.spekframework.spek2:spek-runner-junit5:$spekVersion")
    testRuntimeOnly("org.jetbrains.kotlin:kotlin-reflect:$kotlinVersion")
    testImplementation("io.mockk:mockk:1.10.2")
    testImplementation("org.assertj:assertj-core:3.18.0")

}

tasks {
    compileKotlin {
        kotlinOptions.jvmTarget = "1.8"
    }
    compileTestKotlin {
        kotlinOptions.jvmTarget = "1.8"
    }
}