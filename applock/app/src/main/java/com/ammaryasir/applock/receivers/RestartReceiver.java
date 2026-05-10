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
