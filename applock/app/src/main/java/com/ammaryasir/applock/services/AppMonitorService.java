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
