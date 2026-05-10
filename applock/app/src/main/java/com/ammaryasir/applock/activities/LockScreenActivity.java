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
