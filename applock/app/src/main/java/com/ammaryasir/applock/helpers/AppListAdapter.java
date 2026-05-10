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
