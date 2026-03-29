# Stripe rules for R8 minification
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }

-keep class com.stripe.** { *; }
-keep interface com.stripe.** { *; }
-dontwarn com.stripe.**

-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**
