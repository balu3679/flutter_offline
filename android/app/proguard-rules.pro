# Flutter wrapper classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep your model classes if needed for JSON serialization
# (optional - replace with your package)
-keep class com.example.regres.model.** { *; }

# Prevent warnings for generated files
-dontwarn com.google.protobuf.**
-dontwarn sun.misc.**
