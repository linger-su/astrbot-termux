package com.termux.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

/**
 * AstrBot APP - Boot Receiver
 * Receives BOOT_COMPLETED broadcast and starts TermuxService
 */
public class BootReceiver extends BroadcastReceiver {

    private static final String TAG = "AstrBotBoot";

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (action == null) return;

        if (Intent.ACTION_BOOT_COMPLETED.equals(action) ||
            "android.intent.action.QUICKBOOT_POWERON".equals(action)) {

            SharedPreferences prefs = context.getSharedPreferences("astrbot_prefs", Context.MODE_PRIVATE);
            boolean autoStart = prefs.getBoolean("auto_start_on_boot", false);

            if (autoStart) {
                Log.i(TAG, "Boot completed, starting AstrBot services...");
                try {
                    // Start Termux service which will run start-services.sh
                    Intent serviceIntent = new Intent(context, TermuxService.class);
                    context.startForegroundService(serviceIntent);

                    // Execute start-services.sh via RunCommandService
                    Intent cmdIntent = new Intent();
                    cmdIntent.setClassName(context.getPackageName(), "com.termux.app.RunCommandService");
                    cmdIntent.setAction(context.getPackageName() + ".RUN_COMMAND");
                    cmdIntent.putExtra("com.termux.RUN_COMMAND_PATH", "/data/data/com.termux/files/home/start-services.sh");
                    cmdIntent.putExtra("com.termux.RUN_COMMAND_BACKGROUND", true);
                    context.startService(cmdIntent);
                } catch (Exception e) {
                    Log.e(TAG, "Failed to start services on boot", e);
                }
            }
        }
    }
}
