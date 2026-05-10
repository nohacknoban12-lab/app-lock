# AppLock Project Setup Script
# Run this in PowerShell on Desktop

$base = "$env:USERPROFILE\Desktop\applock"

# Create folders
$folders = @(
    "$base\.github\workflows",
    "$base\app\src\main\java\com\ammaryasir\applock\activities",
    "$base\app\src\main\java\com\ammaryasir\applock\services",
    "$base\app\src\main\java\com\ammaryasir\applock\helpers",
    "$base\app\src\main\java\com\ammaryasir\applock\receivers",
    "$base\app\src\main\res\layout",
    "$base\app\src\main\res\values",
    "$base\app\src\main\res\drawable",
    "$base\app\src\main\res\xml",
    "$base\gradle\wrapper"
)
foreach ($f in $folders) { New-Item -ItemType Directory -Force -Path $f | Out-Null }
Write-Host "Folders created..." -ForegroundColor Green

# settings.gradle
@'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "AppLock"
include ':app'
'@ | Set-Content "$base\settings.gradle" -Encoding UTF8

# build.gradle (root)
@'
plugins {
    id 'com.android.application' version '8.2.0' apply false
}
'@ | Set-Content "$base\build.gradle" -Encoding UTF8

# gradle-wrapper.properties
@'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
'@ | Set-Content "$base\gradle\wrapper\gradle-wrapper.properties" -Encoding UTF8

# app/build.gradle
@'
plugins {
    id 'com.android.application'
}
android {
    namespace 'com.ammaryasir.applock'
    compileSdk 34
    defaultConfig {
        applicationId "com.ammaryasir.applock"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.debug
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    buildFeatures {
        viewBinding true
    }
}
dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.recyclerview:recyclerview:1.3.2'
    implementation 'androidx.cardview:cardview:1.0.0'
}
'@ | Set-Content "$base\app\build.gradle" -Encoding UTF8

# proguard-rules.pro
@'
-keep class com.ammaryasir.applock.** { *; }
'@ | Set-Content "$base\app\proguard-rules.pro" -Encoding UTF8

# GitHub Actions workflow
@'
name: Build APK
on:
  push:
    branches: [ main ]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: "17"
          distribution: "temurin"
      - name: Setup Gradle
        uses: gradle/gradle-build-action@v2
        with:
          gradle-version: "8.2"
      - name: Build Release APK
        run: gradle assembleRelease
      - name: Upload APK
        uses: actions/upload-artifact@v3
        with:
          name: AppLock-APK
          path: app/build/outputs/apk/release/app-release.apk
'@ | Set-Content "$base\.github\workflows\build.yml" -Encoding UTF8

# AndroidManifest.xml
@'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" tools:ignore="ProtectedPermissions" xmlns:tools="http://schemas.android.com/tools"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
    <uses-feature android:name="android.hardware.sensor.proximity" android:required="false"/>
    <application
        android:allowBackup="true"
        android:icon="@drawable/ic_lock"
        android:label="@string/app_name"
        android:theme="@style/Theme.AppLock"
        android:usesCleartextTraffic="false">
        <activity android:name=".activities.MainActivity" android:exported="true" android:launchMode="singleTop">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <activity android:name=".activities.SetupActivity" android:exported="false"/>
        <activity android:name=".activities.LockScreenActivity" android:exported="false" android:launchMode="singleTask" android:showOnLockScreen="true" android:excludeFromRecents="true"/>
        <activity android:name=".activities.RecoveryActivity" android:exported="false"/>
        <service android:name=".services.AppMonitorService" android:exported="false" android:foregroundServiceType="dataSync"/>
        <receiver android:name=".receivers.RestartReceiver" android:exported="false">
            <intent-filter>
                <action android:name="com.ammaryasir.applock.RESTART_SERVICE"/>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>
    </application>
</manifest>
'@ | Set-Content "$base\app\src\main\AndroidManifest.xml" -Encoding UTF8

# strings.xml
@'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">AppLock</string>
</resources>
'@ | Set-Content "$base\app\src\main\res\values\strings.xml" -Encoding UTF8

# colors.xml
@'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="purple_500">#FF6200EE</color>
    <color name="purple_700">#FF3700B3</color>
    <color name="white">#FFFFFFFF</color>
    <color name="accent">#7C6AF7</color>
    <color name="bg_dark">#0A0A0F</color>
</resources>
'@ | Set-Content "$base\app\src\main\res\values\colors.xml" -Encoding UTF8

# themes.xml
@'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.AppLock" parent="Theme.MaterialComponents.DayNight.NoActionBar">
        <item name="colorPrimary">@color/accent</item>
        <item name="colorPrimaryVariant">@color/purple_700</item>
        <item name="colorOnPrimary">@color/white</item>
        <item name="android:windowBackground">@color/bg_dark</item>
    </style>
</resources>
'@ | Set-Content "$base\app\src\main\res\values\themes.xml" -Encoding UTF8

# input_bg.xml
@'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android" android:shape="rectangle">
    <solid android:color="#16161F"/>
    <stroke android:width="1dp" android:color="#2A2A3A"/>
    <corners android:radius="10dp"/>
</shape>
'@ | Set-Content "$base\app\src\main\res\drawable\input_bg.xml" -Encoding UTF8

# ic_lock.xml
@'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="24dp" android:height="24dp"
    android:viewportWidth="24" android:viewportHeight="24">
    <path android:fillColor="#A78BFA"
        android:pathData="M18,8h-1V6c0-2.76-2.24-5-5-5S7,3.24 7,6v2H6c-1.1,0-2,0.9-2,2v10c0,1.1 0.9,2 2,2h12c1.1,0 2-0.9 2-2V10c0-1.1-0.9-2-2-2zm-6,9c-1.1,0-2-0.9-2-2s0.9-2 2-2 2,0.9 2,2-0.9,2-2,2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71,0 3.1,1.39 3.1,3.1v2z"/>
</vector>
'@ | Set-Content "$base\app\src\main\res\drawable\ic_lock.xml" -Encoding UTF8

# PrefManager.java
@'
package com.ammaryasir.applock.helpers;
import android.content.Context;
import android.content.SharedPreferences;
import java.util.HashSet;
import java.util.Set;
public class PrefManager {
    private static final String PREF_NAME = "AppLockPrefs";
    private static final String KEY_LOCK_TYPE = "lock_type";
    private static final String KEY_PATTERN = "pattern";
    private static final String KEY_PIN = "pin";
    private static final String KEY_PASSWORD = "password";
    private static final String KEY_RECOVERY_EMAIL = "recovery_email";
    private static final String KEY_RECOVERY_ANSWER = "recovery_answer";
    private static final String KEY_LOCKED_APPS = "locked_apps";
    private static final String KEY_SETUP_DONE = "setup_done";
    private static final String KEY_PROXIMITY_ENABLED = "proximity_enabled";
    public static final String LOCK_TYPE_PATTERN = "pattern";
    public static final String LOCK_TYPE_PIN = "pin";
    public static final String LOCK_TYPE_PASSWORD = "password";
    private final SharedPreferences prefs;
    public PrefManager(Context context) { prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE); }
    public boolean isSetupDone() { return prefs.getBoolean(KEY_SETUP_DONE, false); }
    public void setSetupDone(boolean done) { prefs.edit().putBoolean(KEY_SETUP_DONE, done).apply(); }
    public String getLockType() { return prefs.getString(KEY_LOCK_TYPE, LOCK_TYPE_PIN); }
    public void setLockType(String type) { prefs.edit().putString(KEY_LOCK_TYPE, type).apply(); }
    public String getPattern() { return prefs.getString(KEY_PATTERN, ""); }
    public void setPattern(String pattern) { prefs.edit().putString(KEY_PATTERN, pattern).apply(); }
    public String getPin() { return prefs.getString(KEY_PIN, ""); }
    public void setPin(String pin) { prefs.edit().putString(KEY_PIN, pin).apply(); }
    public String getPassword() { return prefs.getString(KEY_PASSWORD, ""); }
    public void setPassword(String password) { prefs.edit().putString(KEY_PASSWORD, password).apply(); }
    public String getRecoveryEmail() { return prefs.getString(KEY_RECOVERY_EMAIL, ""); }
    public void setRecoveryEmail(String email) { prefs.edit().putString(KEY_RECOVERY_EMAIL, email).apply(); }
    public String getRecoveryAnswer() { return prefs.getString(KEY_RECOVERY_ANSWER, ""); }
    public void setRecoveryAnswer(String answer) { prefs.edit().putString(KEY_RECOVERY_ANSWER, answer).apply(); }
    public Set<String> getLockedApps() { return prefs.getStringSet(KEY_LOCKED_APPS, new HashSet<>()); }
    public void setLockedApps(Set<String> apps) { prefs.edit().putStringSet(KEY_LOCKED_APPS, apps).apply(); }
    public void addLockedApp(String packageName) { Set<String> apps = new HashSet<>(getLockedApps()); apps.add(packageName); setLockedApps(apps); }
    public void removeLockedApp(String packageName) { Set<String> apps = new HashSet<>(getLockedApps()); apps.remove(packageName); setLockedApps(apps); }
    public boolean isAppLocked(String packageName) { return getLockedApps().contains(packageName); }
    public boolean isProximityEnabled() { return prefs.getBoolean(KEY_PROXIMITY_ENABLED, true); }
    public void setProximityEnabled(boolean enabled) { prefs.edit().putBoolean(KEY_PROXIMITY_ENABLED, enabled).apply(); }
    public boolean verifyLock(String input) {
        switch (getLockType()) {
            case LOCK_TYPE_PATTERN: return input.equals(getPattern());
            case LOCK_TYPE_PIN: return input.equals(getPin());
            case LOCK_TYPE_PASSWORD: return input.equals(getPassword());
            default: return false;
        }
    }
}
'@ | Set-Content "$base\app\src\main\java\com\ammaryasir\applock\helpers\PrefManager.java" -Encoding UTF8

# PatternView.java
@'
package com.ammaryasir.applock.helpers;
import android.content.Context;
import android.graphics.*;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import java.util.ArrayList;
import java.util.List;
public class PatternView extends View {
    public interface OnPatternListener { void onPatternComplete(String pattern); }
    private final float[] dotX = new float[9];
    private final float[] dotY = new float[9];
    private final boolean[] selected = new boolean[9];
    private final List<Integer> selectedDots = new ArrayList<>();
    private float touchX, touchY;
    private boolean drawing = false;
    private Paint dotPaint, linePaint, selectedDotPaint;
    private OnPatternListener listener;
    public PatternView(Context context) { super(context); init(); }
    public PatternView(Context context, AttributeSet attrs) { super(context, attrs); init(); }
    private void init() {
        dotPaint = new Paint(Paint.ANTI_ALIAS_FLAG); dotPaint.setColor(0xFFAAAAAA); dotPaint.setStyle(Paint.Style.FILL);
        selectedDotPaint = new Paint(Paint.ANTI_ALIAS_FLAG); selectedDotPaint.setColor(0xFF7C6AF7); selectedDotPaint.setStyle(Paint.Style.FILL);
        linePaint = new Paint(Paint.ANTI_ALIAS_FLAG); linePaint.setColor(0xFF7C6AF7); linePaint.setStrokeWidth(6f); linePaint.setStyle(Paint.Style.STROKE);
    }
    @Override
    protected void onSizeChanged(int w, int h, int oldW, int oldH) {
        float cellW = w / 3f, cellH = h / 3f; int i = 0;
        for (int r = 0; r < 3; r++) for (int c = 0; c < 3; c++) { dotX[i] = cellW*c+cellW/2; dotY[i] = cellH*r+cellH/2; i++; }
    }
    @Override
    protected void onDraw(Canvas canvas) {
        float dotRadius = Math.min(getWidth(), getHeight()) / 12f;
        for (int i = 0; i < selectedDots.size()-1; i++) { int a=selectedDots.get(i),b=selectedDots.get(i+1); canvas.drawLine(dotX[a],dotY[a],dotX[b],dotY[b],linePaint); }
        if (drawing && !selectedDots.isEmpty()) { int last=selectedDots.get(selectedDots.size()-1); canvas.drawLine(dotX[last],dotY[last],touchX,touchY,linePaint); }
        for (int i = 0; i < 9; i++) canvas.drawCircle(dotX[i],dotY[i],dotRadius,selected[i]?selectedDotPaint:dotPaint);
    }
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        touchX=event.getX(); touchY=event.getY();
        switch(event.getAction()) {
            case MotionEvent.ACTION_DOWN: clearPattern(); drawing=true; checkDot(); break;
            case MotionEvent.ACTION_MOVE: checkDot(); break;
            case MotionEvent.ACTION_UP: drawing=false; if(listener!=null&&selectedDots.size()>=4) listener.onPatternComplete(getPatternString()); break;
        }
        invalidate(); return true;
    }
    private void checkDot() {
        float r = Math.min(getWidth(),getHeight())/12f;
        for (int i=0;i<9;i++) if(!selected[i]) { float dx=touchX-dotX[i],dy=touchY-dotY[i]; if(Math.sqrt(dx*dx+dy*dy)<r*1.5f){selected[i]=true;selectedDots.add(i);break;} }
    }
    private String getPatternString() { StringBuilder sb=new StringBuilder(); for(int d:selectedDots)sb.append(d); return sb.toString(); }
    public void clearPattern() { for(int i=0;i<9;i++)selected[i]=false; selectedDots.clear(); invalidate(); }
    public void setOnPatternListener(OnPatternListener l) { this.listener=l; }
}
'@ | Set-Content "$base\app\src\main\java\com\ammaryasir\applock\helpers\PatternView.java" -Encoding UTF8

# AppListAdapter.java
@'
package com.ammaryasir.applock.helpers;
import android.content.Context;
import android.content.pm.*;
import android.view.*;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import com.ammaryasir.applock.R;
import java.util.List;
public class AppListAdapter extends RecyclerView.Adapter<AppListAdapter.VH> {
    private final Context ctx;
    private final List<ResolveInfo> apps;
    private final PrefManager prefManager;
    private final PackageManager pm;
    public AppListAdapter(Context ctx, List<ResolveInfo> apps, PrefManager prefManager) { this.ctx=ctx; this.apps=apps; this.prefManager=prefManager; this.pm=ctx.getPackageManager(); }
    @NonNull @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) { return new VH(LayoutInflater.from(ctx).inflate(R.layout.item_app, parent, false)); }
    @Override
    public void onBindViewHolder(@NonNull VH h, int pos) {
        ResolveInfo ri=apps.get(pos); String pkg=ri.activityInfo.packageName, name=ri.loadLabel(pm).toString();
        h.tvName.setText(name); h.tvPkg.setText(pkg);
        try { h.ivIcon.setImageDrawable(ri.loadIcon(pm)); } catch(Exception e){ h.ivIcon.setImageResource(android.R.drawable.sym_def_app_icon); }
        h.swLock.setOnCheckedChangeListener(null);
        h.swLock.setChecked(prefManager.isAppLocked(pkg));
        h.swLock.setOnCheckedChangeListener((btn,checked)->{ if(checked){prefManager.addLockedApp(pkg);Toast.makeText(ctx,name+" locked",Toast.LENGTH_SHORT).show();}else{prefManager.removeLockedApp(pkg);Toast.makeText(ctx,name+" unlocked",Toast.LENGTH_SHORT).show();} });
    }
    @Override public int getItemCount() { return apps.size(); }
    static class VH extends RecyclerView.ViewHolder {
        ImageView ivIcon; TextView tvName,tvPkg; Switch swLock;
        VH(View v) { super(v); ivIcon=v.findViewById(R.id.iv_app_icon); tvName=v.findViewById(R.id.tv_app_name); tvPkg=v.findViewById(R.id.tv_app_pkg); swLock=v.findViewById(R.id.sw_app_lock); }
    }
}
'@ | Set-Content "$base\app\src\main\java\com\ammaryasir\applock\helpers\AppListAdapter.java" -Encoding UTF8

# RestartReceiver.java
@'
package com.ammaryasir.applock.receivers;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import com.ammaryasir.applock.services.AppMonitorService;
public class RestartReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) context.startForegroundService(new Intent(context, AppMonitorService.class));
        else context.startService(new Intent(context, AppMonitorService.class));
    }
}
'@ | Set-Content "$base\app\src\main\java\com\ammaryasir\applock\receivers\RestartReceiver.java" -Encoding UTF8

# AppMonitorService.java
@'
package com.ammaryasir.applock.services;
import android.app.*;
import android.app.usage.*;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.*;
import androidx.core.app.NotificationCompat;
import com.ammaryasir.applock.R;
import com.ammaryasir.applock.activities.LockScreenActivity;
import com.ammaryasir.applock.helpers.PrefManager;
public class AppMonitorService extends Service {
    private static final String CHANNEL_ID = "applock_channel";
    private static final int NOTIF_ID = 1001;
    private PrefManager prefManager;
    private Handler handler;
    private String lastLockedPackage = "";
    private UsageStatsManager usageStatsManager;
    @Override public void onCreate() {
        super.onCreate();
        prefManager = new PrefManager(this);
        usageStatsManager = (UsageStatsManager) getSystemService(Context.USAGE_STATS_SERVICE);
        handler = new Handler(Looper.getMainLooper());
        createNotificationChannel();
        startForeground(NOTIF_ID, buildNotification());
        handler.postDelayed(new Runnable() {
            @Override public void run() {
                String pkg = getForegroundApp();
                if (pkg != null && !pkg.equals(getPackageName())) {
                    if (prefManager.isAppLocked(pkg) && !pkg.equals(lastLockedPackage)) { lastLockedPackage=pkg; showLockScreen(pkg); }
                    else if (!prefManager.isAppLocked(pkg)) lastLockedPackage="";
                }
                handler.postDelayed(this, 500);
            }
        }, 500);
    }
    private String getForegroundApp() {
        long now = System.currentTimeMillis();
        UsageEvents events = usageStatsManager.queryEvents(now-5000, now);
        UsageEvents.Event event = new UsageEvents.Event(); String pkg = null;
        while (events.hasNextEvent()) { events.getNextEvent(event); if(event.getEventType()==UsageEvents.Event.MOVE_TO_FOREGROUND) pkg=event.getPackageName(); }
        return pkg;
    }
    private void showLockScreen(String packageName) {
        String appName = packageName;
        try { PackageManager pm=getPackageManager(); appName=pm.getApplicationLabel(pm.getApplicationInfo(packageName,0)).toString(); } catch(Exception ignored){}
        Intent intent = new Intent(this, LockScreenActivity.class);
        intent.putExtra(LockScreenActivity.EXTRA_PACKAGE, packageName);
        intent.putExtra(LockScreenActivity.EXTRA_APP_NAME, appName);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK|Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
    }
    private Notification buildNotification() {
        return new NotificationCompat.Builder(this, CHANNEL_ID).setContentTitle("AppLock Active").setContentText("Your apps are protected").setSmallIcon(R.drawable.ic_lock).setOngoing(true).build();
    }
    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel ch = new NotificationChannel(CHANNEL_ID,"AppLock",NotificationManager.IMPORTANCE_LOW);
            NotificationManager nm = getSystemService(NotificationManager.class);
            if(nm!=null) nm.createNotificationChannel(ch);
        }
    }
    @Override public int onStartCommand(Intent intent, int flags, int startId) { return START_STICKY; }
    @Override public IBinder onBind(Intent intent) { return null; }
    @Override public void onDestroy() { super.onDestroy(); handler.removeCallbacksAndMessages(null); sendBroadcast(new Intent("com.ammaryasir.applock.RESTART_SERVICE")); }
}
'@ | Set-Content "$base\app\src\main\java\com\ammaryasir\applock\services\AppMonitorService.java" -Encoding UTF8

# MainActivity.java
@'
package com.ammaryasir.applock.activities;
import android.content.Intent;
import android.content.pm.*;
import android.os.Bundle;
import android.provider.Settings;
import android.widget.*;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.ammaryasir.applock.R;
import com.ammaryasir.applock.helpers.AppListAdapter;
import com.ammaryasir.applock.helpers.PrefManager;
import com.ammaryasir.applock.services.AppMonitorService;
import java.util.*;
public class MainActivity extends AppCompatActivity {
    private PrefManager prefManager;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        prefManager = new PrefManager(this);
        if (!prefManager.isSetupDone()) { startActivity(new Intent(this, SetupActivity.class)); finish(); return; }
        setContentView(R.layout.activity_main);
        Switch swProximity = findViewById(R.id.sw_proximity);
        swProximity.setChecked(prefManager.isProximityEnabled());
        swProximity.setOnCheckedChangeListener((btn,checked)->{ prefManager.setProximityEnabled(checked); Toast.makeText(this,"Proximity "+(checked?"enabled":"disabled"),Toast.LENGTH_SHORT).show(); });
        findViewById(R.id.btn_change_lock).setOnClickListener(v->{ prefManager.setSetupDone(false); startActivity(new Intent(this,SetupActivity.class)); });
        if (!hasUsagePermission()) new AlertDialog.Builder(this).setTitle("Permission Required").setMessage("AppLock needs Usage Access permission.\n\nTap OK to open settings.").setPositiveButton("OK",(d,w)->startActivity(new Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))).setNegativeButton("Cancel",null).show();
        loadApps();
        startService(new Intent(this, AppMonitorService.class));
    }
    private boolean hasUsagePermission() {
        try { android.app.AppOpsManager a=(android.app.AppOpsManager)getSystemService(APP_OPS_SERVICE); return a.checkOpNoThrow(android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,android.os.Process.myUid(),getPackageName())==android.app.AppOpsManager.MODE_ALLOWED; } catch(Exception e){ return false; }
    }
    private void loadApps() {
        PackageManager pm = getPackageManager();
        List<ResolveInfo> apps = pm.queryIntentActivities(new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER),0);
        apps.sort((a,b)->a.loadLabel(pm).toString().compareToIgnoreCase(b.loadLabel(pm).toString()));
        List<ResolveInfo> filtered = new ArrayList<>();
        for (ResolveInfo ri : apps) if (!ri.activityInfo.packageName.equals(getPackageName())) filtered.add(ri);
        RecyclerView rv = findViewById(R.id.rv_apps);
        rv.setLayoutManager(new LinearLayoutManager(this));
        rv.setAdapter(new AppListAdapter(this, filtered, prefManager));
    }
}
'@ | Set-Content "$base\app\src\main\java\com\ammaryasir\applock\activities\MainActivity.java" -Encoding UTF8

# SetupActivity.java
@'
package com.ammaryasir.applock.activities;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.ammaryasir.applock.R;
import com.ammaryasir.applock.helpers.PatternView;
import com.ammaryasir.applock.helpers.PrefManager;
public class SetupActivity extends AppCompatActivity {
    private PrefManager prefManager;
    private String selectedLockType = PrefManager.LOCK_TYPE_PIN;
    private RadioGroup rgLockType;
    private LinearLayout layoutPin, layoutPassword, layoutPattern;
    private EditText etPin, etPinConfirm, etPassword, etPasswordConfirm, etRecoveryEmail, etRecoveryAnswer;
    private PatternView patternView;
    private String patternFirst = null;
    private TextView tvPatternHint;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_setup);
        prefManager = new PrefManager(this);
        rgLockType=findViewById(R.id.rg_lock_type); layoutPin=findViewById(R.id.layout_pin); layoutPassword=findViewById(R.id.layout_password); layoutPattern=findViewById(R.id.layout_pattern);
        etPin=findViewById(R.id.et_pin); etPinConfirm=findViewById(R.id.et_pin_confirm); etPassword=findViewById(R.id.et_password); etPasswordConfirm=findViewById(R.id.et_password_confirm);
        etRecoveryEmail=findViewById(R.id.et_recovery_email); etRecoveryAnswer=findViewById(R.id.et_recovery_answer);
        patternView=findViewById(R.id.pattern_view); tvPatternHint=findViewById(R.id.tv_pattern_hint);
        showPin();
        rgLockType.setOnCheckedChangeListener((g,id)->{ if(id==R.id.rb_pin){selectedLockType=PrefManager.LOCK_TYPE_PIN;showPin();}else if(id==R.id.rb_password){selectedLockType=PrefManager.LOCK_TYPE_PASSWORD;showPassword();}else{selectedLockType=PrefManager.LOCK_TYPE_PATTERN;showPattern();} });
        patternView.setOnPatternListener(p->{ if(patternFirst==null){patternFirst=p;tvPatternHint.setText("Draw again to confirm");patternView.clearPattern();}else{if(patternFirst.equals(p))tvPatternHint.setText("Pattern confirmed!");else{patternFirst=null;tvPatternHint.setText("Did not match. Try again.");patternView.clearPattern();}} });
        findViewById(R.id.btn_save_setup).setOnClickListener(v->save());
    }
    private void showPin(){layoutPin.setVisibility(View.VISIBLE);layoutPassword.setVisibility(View.GONE);layoutPattern.setVisibility(View.GONE);}
    private void showPassword(){layoutPin.setVisibility(View.GONE);layoutPassword.setVisibility(View.VISIBLE);layoutPattern.setVisibility(View.GONE);}
    private void showPattern(){layoutPin.setVisibility(View.GONE);layoutPassword.setVisibility(View.GONE);layoutPattern.setVisibility(View.VISIBLE);patternFirst=null;tvPatternHint.setText("Draw your unlock pattern");}
    private void save() {
        String email=etRecoveryEmail.getText().toString().trim(), ans=etRecoveryAnswer.getText().toString().trim();
        if(email.isEmpty()||ans.isEmpty()){Toast.makeText(this,"Fill recovery options",Toast.LENGTH_SHORT).show();return;}
        if(selectedLockType.equals(PrefManager.LOCK_TYPE_PIN)){String p=etPin.getText().toString(),c=etPinConfirm.getText().toString();if(p.length()<4){Toast.makeText(this,"PIN min 4 digits",Toast.LENGTH_SHORT).show();return;}if(!p.equals(c)){Toast.makeText(this,"PINs dont match",Toast.LENGTH_SHORT).show();return;}prefManager.setPin(p);}
        else if(selectedLockType.equals(PrefManager.LOCK_TYPE_PASSWORD)){String p=etPassword.getText().toString(),c=etPasswordConfirm.getText().toString();if(p.length()<6){Toast.makeText(this,"Password min 6 chars",Toast.LENGTH_SHORT).show();return;}if(!p.equals(c)){Toast.makeText(this,"Passwords dont match",Toast.LENGTH_SHORT).show();return;}prefManager.setPassword(p);}
        else{if(patternFirst==null){Toast.makeText(this,"Draw and confirm pattern",Toast.LENGTH_SHORT).show();return;}prefManager.setPattern(patternFirst);}
        prefManager.setLockType(selectedLockType); prefManager.setRecoveryEmail(email); prefManager.setRecoveryAnswer(ans.toLowerCase()); prefManager.setSetupDone(true);
        Toast.makeText(this,"Setup complete!",Toast.LENGTH_SHORT).show();
        startActivity(new Intent(this,MainActivity.class)); finish();
    }
}
'@ | Set-Content "$base\app\src\main\java\com\ammaryasir\applock\activities\SetupActivity.java" -Encoding UTF8

# LockScreenActivity.java
@'
package com.ammaryasir.applock.activities;
import android.content.Context;
import android.content.Intent;
import android.hardware.*;
import android.os.*;
import android.view.*;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.ammaryasir.applock.R;
import com.ammaryasir.applock.helpers.PatternView;
import com.ammaryasir.applock.helpers.PrefManager;
public class LockScreenActivity extends AppCompatActivity implements SensorEventListener {
    public static final String EXTRA_PACKAGE = "package_name";
    public static final String EXTRA_APP_NAME = "app_name";
    private PrefManager prefManager;
    private SensorManager sensorManager;
    private Sensor proximitySensor;
    private TextView tvAppName, tvAttempts, tvProxHint;
    private LinearLayout layoutPin, layoutPassword, layoutPattern;
    private EditText etPinInput, etPasswordInput;
    private PatternView patternView;
    private int failedAttempts = 0;
    private boolean proxCovered = false;
    private Handler proxHandler = new Handler(Looper.getMainLooper());
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED|WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        setContentView(R.layout.activity_lock_screen);
        prefManager = new PrefManager(this);
        String appName = getIntent().getStringExtra(EXTRA_APP_NAME);
        tvAppName=findViewById(R.id.tv_app_name); tvAttempts=findViewById(R.id.tv_attempts); tvProxHint=findViewById(R.id.tv_prox_hint);
        layoutPin=findViewById(R.id.layout_pin_lock); layoutPassword=findViewById(R.id.layout_password_lock); layoutPattern=findViewById(R.id.layout_pattern_lock);
        etPinInput=findViewById(R.id.et_pin_input); etPasswordInput=findViewById(R.id.et_password_input);
        patternView=findViewById(R.id.pattern_view_lock);
        tvAppName.setText(appName!=null?appName:"App");
        setupUI();
        if(prefManager.isProximityEnabled()){tvProxHint.setVisibility(View.VISIBLE);tvProxHint.setText("Cover proximity sensor for 3 sec to unlock");sensorManager=(SensorManager)getSystemService(Context.SENSOR_SERVICE);if(sensorManager!=null)proximitySensor=sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);}
        findViewById(R.id.btn_unlock).setOnClickListener(v->tryUnlock());
        findViewById(R.id.btn_forgot).setOnClickListener(v->startActivity(new Intent(this,RecoveryActivity.class)));
        patternView.setOnPatternListener(p->{if(prefManager.verifyLock(p))unlock();else{onWrong();patternView.clearPattern();}});
    }
    private void setupUI(){
        String t=prefManager.getLockType(); layoutPin.setVisibility(View.GONE); layoutPassword.setVisibility(View.GONE); layoutPattern.setVisibility(View.GONE); findViewById(R.id.btn_unlock).setVisibility(View.VISIBLE);
        if(t.equals(PrefManager.LOCK_TYPE_PIN))layoutPin.setVisibility(View.VISIBLE);
        else if(t.equals(PrefManager.LOCK_TYPE_PASSWORD))layoutPassword.setVisibility(View.VISIBLE);
        else{layoutPattern.setVisibility(View.VISIBLE);findViewById(R.id.btn_unlock).setVisibility(View.GONE);}
    }
    private void tryUnlock(){String t=prefManager.getLockType(),input=t.equals(PrefManager.LOCK_TYPE_PIN)?etPinInput.getText().toString():etPasswordInput.getText().toString();if(prefManager.verifyLock(input))unlock();else onWrong();}
    private void unlock(){Toast.makeText(this,"Unlocked!",Toast.LENGTH_SHORT).show();finish();}
    private void onWrong(){failedAttempts++;tvAttempts.setText("Wrong! Attempts: "+failedAttempts);tvAttempts.setTextColor(0xFFFF5252);if(failedAttempts>=5)findViewById(R.id.btn_forgot).setVisibility(View.VISIBLE);Vibrator v=(Vibrator)getSystemService(VIBRATOR_SERVICE);if(v!=null)v.vibrate(300);}
    @Override protected void onResume(){super.onResume();if(sensorManager!=null&&proximitySensor!=null)sensorManager.registerListener(this,proximitySensor,SensorManager.SENSOR_DELAY_NORMAL);}
    @Override protected void onPause(){super.onPause();if(sensorManager!=null)sensorManager.unregisterListener(this);proxHandler.removeCallbacksAndMessages(null);}
    @Override public void onSensorChanged(SensorEvent e){
        if(e.sensor.getType()==Sensor.TYPE_PROXIMITY){boolean covered=e.values[0]<e.sensor.getMaximumRange();
        if(covered&&!proxCovered){proxCovered=true;tvProxHint.setText("Keep covering... (3 sec)");proxHandler.postDelayed(()->{if(proxCovered){tvProxHint.setText("Unlocked via sensor!");unlock();}},3000);}
        else if(!covered){proxCovered=false;proxHandler.removeCallbacksAndMessages(null);tvProxHint.setText("Cover proximity sensor for 3 sec to unlock");}}
    }
    @Override public void onAccuracyChanged(Sensor s,int a){}
    @Override public void onBackPressed(){startActivity(new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME));}
}
'@ | Set-Content "$base\app\src\main\java\com\ammaryasir\applock\activities\LockScreenActivity.java" -Encoding UTF8

# RecoveryActivity.java
@'
package com.ammaryasir.applock.activities;
import android.content.Intent;
import android.os.Bundle;
import android.widget.*;
import androidx.appcompat.app.AppCompatActivity;
import com.ammaryasir.applock.R;
import com.ammaryasir.applock.helpers.PrefManager;
public class RecoveryActivity extends AppCompatActivity {
    private PrefManager prefManager;
    @Override protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recovery);
        prefManager = new PrefManager(this);
        EditText etEmail=findViewById(R.id.et_rec_email), etAns=findViewById(R.id.et_rec_answer);
        String e=prefManager.getRecoveryEmail(); String masked=e.contains("@")?e.charAt(0)+"***@"+e.split("@")[1]:"***";
        ((TextView)findViewById(R.id.tv_recovery_info)).setText("Recovery: "+masked+"\nAnswer security question to reset.");
        findViewById(R.id.btn_verify_recovery).setOnClickListener(v->{
            String email=etEmail.getText().toString().trim(), ans=etAns.getText().toString().trim().toLowerCase();
            if(email.equals(prefManager.getRecoveryEmail())&&ans.equals(prefManager.getRecoveryAnswer())){
                Toast.makeText(this,"Verified! Set new lock.",Toast.LENGTH_LONG).show();
                prefManager.setSetupDone(false); startActivity(new Intent(this,SetupActivity.class)); finishAffinity();
            } else Toast.makeText(this,"Wrong email or answer!",Toast.LENGTH_SHORT).show();
        });
    }
}
'@ | Set-Content "$base\app\src\main\java\com\ammaryasir\applock\activities\RecoveryActivity.java" -Encoding UTF8

# Layouts
@'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:background="#0A0A0F">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:background="#16161F" android:padding="20dp" android:orientation="vertical">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="AppLock" android:textColor="#A78BFA" android:textSize="24sp" android:textStyle="bold"/>
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
            android:text="by Ammar Yasir" android:textColor="#64748B" android:textSize="12sp"/>
    </LinearLayout>
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content"
        android:background="#111118" android:padding="16dp" android:gravity="center_vertical">
        <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical">
            <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
                android:text="Proximity Unlock" android:textColor="#E2E8F0" android:textSize="14sp" android:textStyle="bold"/>
            <TextView android:layout_width="wrap_content" android:layout_height="wrap_content"
                android:text="Cover sensor for 3 sec" android:textColor="#64748B" android:textSize="11sp"/>
        </LinearLayout>
        <Switch android:id="@+id/sw_proximity" android:layout_width="wrap_content" android:layout_height="wrap_content"/>
    </LinearLayout>
    <Button android:id="@+id/btn_change_lock" android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_margin="16dp" android:text="Change Lock Method" android:backgroundTint="#2A2A3A" android:textColor="#A78BFA"/>
    <TextView android:layout_width="match_parent" android:layout_height="wrap_content"
        android:text="INSTALLED APPS" android:textColor="#64748B" android:textSize="11sp" android:padding="16dp"/>
    <androidx.recyclerview.widget.RecyclerView android:id="@+id/rv_apps"
        android:layout_width="match_parent" android:layout_height="0dp" android:layout_weight="1"/>
</LinearLayout>
'@ | Set-Content "$base\app\src\main\res\layout\activity_main.xml" -Encoding UTF8

@'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="wrap_content"
    android:orientation="horizontal" android:gravity="center_vertical"
    android:padding="14dp" android:background="#16161F">
    <ImageView android:id="@+id/iv_app_icon" android:layout_width="44dp" android:layout_height="44dp" android:layout_marginEnd="14dp"/>
    <LinearLayout android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:orientation="vertical">
        <TextView android:id="@+id/tv_app_name" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="#E2E8F0" android:textSize="14sp" android:textStyle="bold"/>
        <TextView android:id="@+id/tv_app_pkg" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="#64748B" android:textSize="10sp" android:maxLines="1" android:ellipsize="end"/>
    </LinearLayout>
    <Switch android:id="@+id/sw_app_lock" android:layout_width="wrap_content" android:layout_height="wrap_content"/>
</LinearLayout>
'@ | Set-Content "$base\app\src\main\res\layout\item_app.xml" -Encoding UTF8

@'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:gravity="center" android:background="#0A0A0F" android:padding="32dp">
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="🔒" android:textSize="56sp" android:layout_marginBottom="12dp"/>
    <TextView android:id="@+id/tv_app_name" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="#FFFFFF" android:textSize="22sp" android:textStyle="bold" android:layout_marginBottom="4dp"/>
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Enter your lock to continue" android:textColor="#64748B" android:textSize="13sp" android:layout_marginBottom="32dp"/>
    <LinearLayout android:id="@+id/layout_pin_lock" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:visibility="gone">
        <EditText android:id="@+id/et_pin_input" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Enter PIN" android:inputType="numberPassword" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:gravity="center" android:textSize="20sp" android:layout_marginBottom="16dp"/>
    </LinearLayout>
    <LinearLayout android:id="@+id/layout_password_lock" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:visibility="gone">
        <EditText android:id="@+id/et_password_input" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Enter Password" android:inputType="textPassword" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:layout_marginBottom="16dp"/>
    </LinearLayout>
    <LinearLayout android:id="@+id/layout_pattern_lock" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:visibility="gone" android:gravity="center">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Draw your pattern" android:textColor="#64748B" android:textSize="13sp" android:layout_marginBottom="16dp"/>
        <com.ammaryasir.applock.helpers.PatternView android:id="@+id/pattern_view_lock" android:layout_width="240dp" android:layout_height="240dp" android:layout_marginBottom="16dp"/>
    </LinearLayout>
    <Button android:id="@+id/btn_unlock" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="UNLOCK" android:backgroundTint="#7C6AF7" android:textColor="#FFFFFF" android:textStyle="bold" android:layout_marginBottom="12dp"/>
    <TextView android:id="@+id/tv_attempts" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="#64748B" android:textSize="12sp" android:layout_marginBottom="12dp"/>
    <TextView android:id="@+id/tv_prox_hint" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="#4ADE80" android:textSize="12sp" android:gravity="center" android:layout_marginBottom="16dp" android:visibility="gone"/>
    <Button android:id="@+id/btn_forgot" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Forgot? Recover Access" android:backgroundTint="@android:color/transparent" android:textColor="#A78BFA" android:textSize="13sp"/>
</LinearLayout>
'@ | Set-Content "$base\app\src\main\res\layout\activity_lock_screen.xml" -Encoding UTF8

@'
<?xml version="1.0" encoding="utf-8"?>
<ScrollView xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent" android:background="#0A0A0F">
    <LinearLayout android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:padding="24dp">
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Setup AppLock" android:textColor="#A78BFA" android:textSize="26sp" android:textStyle="bold" android:layout_marginBottom="6dp"/>
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Choose your lock method and recovery options" android:textColor="#64748B" android:textSize="13sp" android:layout_marginBottom="28dp"/>
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="LOCK TYPE" android:textColor="#64748B" android:textSize="11sp" android:layout_marginBottom="10dp"/>
        <RadioGroup android:id="@+id/rg_lock_type" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="horizontal" android:layout_marginBottom="24dp">
            <RadioButton android:id="@+id/rb_pin" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="PIN" android:textColor="#E2E8F0" android:buttonTint="#7C6AF7" android:checked="true"/>
            <RadioButton android:id="@+id/rb_password" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="Password" android:textColor="#E2E8F0" android:buttonTint="#7C6AF7"/>
            <RadioButton android:id="@+id/rb_pattern" android:layout_width="0dp" android:layout_height="wrap_content" android:layout_weight="1" android:text="Pattern" android:textColor="#E2E8F0" android:buttonTint="#7C6AF7"/>
        </RadioGroup>
        <LinearLayout android:id="@+id/layout_pin" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical">
            <EditText android:id="@+id/et_pin" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Enter PIN (min 4 digits)" android:inputType="numberPassword" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:layout_marginBottom="12dp"/>
            <EditText android:id="@+id/et_pin_confirm" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Confirm PIN" android:inputType="numberPassword" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:layout_marginBottom="24dp"/>
        </LinearLayout>
        <LinearLayout android:id="@+id/layout_password" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:visibility="gone">
            <EditText android:id="@+id/et_password" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Enter Password (min 6 chars)" android:inputType="textPassword" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:layout_marginBottom="12dp"/>
            <EditText android:id="@+id/et_password_confirm" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Confirm Password" android:inputType="textPassword" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:layout_marginBottom="24dp"/>
        </LinearLayout>
        <LinearLayout android:id="@+id/layout_pattern" android:layout_width="match_parent" android:layout_height="wrap_content" android:orientation="vertical" android:gravity="center" android:visibility="gone">
            <TextView android:id="@+id/tv_pattern_hint" android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Draw your unlock pattern" android:textColor="#A78BFA" android:textSize="13sp" android:layout_marginBottom="12dp"/>
            <com.ammaryasir.applock.helpers.PatternView android:id="@+id/pattern_view" android:layout_width="250dp" android:layout_height="250dp" android:layout_marginBottom="24dp"/>
        </LinearLayout>
        <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="RECOVERY OPTIONS" android:textColor="#64748B" android:textSize="11sp" android:layout_marginBottom="10dp"/>
        <EditText android:id="@+id/et_recovery_email" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Recovery Email" android:inputType="textEmailAddress" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:layout_marginBottom="12dp"/>
        <EditText android:id="@+id/et_recovery_answer" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Security Answer (e.g. mother name)" android:inputType="text" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:layout_marginBottom="28dp"/>
        <Button android:id="@+id/btn_save_setup" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="SAVE AND CONTINUE" android:backgroundTint="#7C6AF7" android:textColor="#FFFFFF" android:textStyle="bold" android:padding="16dp"/>
    </LinearLayout>
</ScrollView>
'@ | Set-Content "$base\app\src\main\res\layout\activity_setup.xml" -Encoding UTF8

@'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent" android:layout_height="match_parent"
    android:orientation="vertical" android:gravity="center" android:background="#0A0A0F" android:padding="28dp">
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="🔑" android:textSize="52sp" android:layout_marginBottom="12dp"/>
    <TextView android:layout_width="wrap_content" android:layout_height="wrap_content" android:text="Account Recovery" android:textColor="#FFFFFF" android:textSize="22sp" android:textStyle="bold" android:layout_marginBottom="8dp"/>
    <TextView android:id="@+id/tv_recovery_info" android:layout_width="wrap_content" android:layout_height="wrap_content" android:textColor="#64748B" android:textSize="13sp" android:gravity="center" android:layout_marginBottom="28dp"/>
    <EditText android:id="@+id/et_rec_email" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Enter your recovery email" android:inputType="textEmailAddress" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:layout_marginBottom="12dp"/>
    <EditText android:id="@+id/et_rec_answer" android:layout_width="match_parent" android:layout_height="wrap_content" android:hint="Enter security answer" android:inputType="text" android:textColor="#E2E8F0" android:textColorHint="#64748B" android:background="@drawable/input_bg" android:padding="14dp" android:layout_marginBottom="24dp"/>
    <Button android:id="@+id/btn_verify_recovery" android:layout_width="match_parent" android:layout_height="wrap_content" android:text="VERIFY AND RESET" android:backgroundTint="#7C6AF7" android:textColor="#FFFFFF" android:textStyle="bold" android:padding="14dp"/>
</LinearLayout>
'@ | Set-Content "$base\app\src\main\res\layout\activity_recovery.xml" -Encoding UTF8

Write-Host "All files created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Now opening Git Bash - run these commands:" -ForegroundColor Yellow
Write-Host "  cd Desktop/applock" -ForegroundColor Cyan
Write-Host "  git init" -ForegroundColor Cyan
Write-Host "  git add ." -ForegroundColor Cyan
Write-Host "  git commit -m 'AppLock initial commit'" -ForegroundColor Cyan
Write-Host "  git branch -M main" -ForegroundColor Cyan
Write-Host "  git remote add origin https://github.com/nohacknoban12-lab/applock.git" -ForegroundColor Cyan
Write-Host "  git push -u origin main" -ForegroundColor Cyan
Write-Host ""
Write-Host "Done! Check GitHub after push - APK will build automatically." -ForegroundColor Green