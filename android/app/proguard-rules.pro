# Proguard/R8 rules для VasoLog
# Цель: успешная сборка release AAB с Huawei AGC SDK + Firebase

# Huawei AGConnect (App Linking) - игнорируем missing classes,
# которые подгружаются только на HMS-устройствах через runtime check
-dontwarn com.huawei.hms.analytics.connector.ConnectorManager
-dontwarn com.huawei.hms.analytics.instance.CallBack
-dontwarn org.bouncycastle.crypto.BlockCipher
-dontwarn org.bouncycastle.crypto.engines.AESEngine
-dontwarn org.bouncycastle.crypto.prng.SP800SecureRandom
-dontwarn org.bouncycastle.crypto.prng.SP800SecureRandomBuilder

# Сохранить классы AGConnect
-keep class com.huawei.agconnect.** { *; }
-keep class com.huawei.hms.** { *; }

# Flutter Local Notifications (используется десугаринг)
-keep class com.dexterous.** { *; }
