# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Hive classes
-keep class hive.** { *; }
-keep class **$HiveFieldAdapter { *; }

# Keep model classes
-keep class com.studify.app.models.** { *; }

# Keep Riverpod classes
-keep class riverpod.** { *; }

# General Android optimizations
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Optimization
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile