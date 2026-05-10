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
