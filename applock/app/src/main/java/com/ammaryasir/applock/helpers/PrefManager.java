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
