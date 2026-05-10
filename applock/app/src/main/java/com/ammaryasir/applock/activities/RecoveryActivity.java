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
