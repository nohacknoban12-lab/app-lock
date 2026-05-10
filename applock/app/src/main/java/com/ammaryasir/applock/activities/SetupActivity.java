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
