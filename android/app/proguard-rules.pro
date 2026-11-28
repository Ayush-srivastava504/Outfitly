# Room creates database implementations by reflection (Class.forName("<Db>_Impl")).
# R8 stripped androidx.work.impl.WorkDatabase_Impl -> release crash at startup:
# "Failed to create an instance of androidx.work.impl.WorkDatabase".
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# WorkManager instantiates workers / input mergers by class name.
-keep class * extends androidx.work.ListenableWorker { <init>(...); }
-keep class * extends androidx.work.InputMerger { <init>(); }

# androidx.startup initializers are created reflectively from the manifest.
-keep class * implements androidx.startup.Initializer { <init>(); }
