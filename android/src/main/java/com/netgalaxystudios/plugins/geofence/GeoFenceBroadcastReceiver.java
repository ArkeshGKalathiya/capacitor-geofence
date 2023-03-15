package com.netgalaxystudios.plugins.geofence;

import android.app.NotificationManager;
import android.app.job.JobInfo;
import android.app.job.JobScheduler;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.PersistableBundle;
import android.util.Log;

import com.getcapacitor.PluginResult;
import com.google.android.gms.location.Geofence;
import com.google.android.gms.location.GeofencingEvent;
import com.google.gson.Gson;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

public class GeoFenceBroadcastReceiver extends BroadcastReceiver {
    protected BeepHelper beepHelper;
    protected GeoNotificationNotifier notifier;
    protected GeoNotificationStore store;

    @Override
    public void onReceive(Context context, Intent intent) {
        beepHelper = new BeepHelper();
        store = new GeoNotificationStore(context);
        Logger.setLogger(new Logger(GeoFenceWithHttpPlugin.TAG, context, false));
        Logger logger = Logger.getLogger();
        logger.log(Log.DEBUG, "ReceiveTransitionsIntentService - onHandleIntent");
        notifier = new GeoNotificationNotifier(
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE),
                context
        );

        GeofencingEvent geofencingEvent = GeofencingEvent.fromIntent(intent);
        Logger.getLogger().log(geofencingEvent.toString(),null);
        if(geofencingEvent == null){
            return;
        }


        Logger.getLogger().log(geofencingEvent.getGeofenceTransition()+" <--- transition ,"+geofencingEvent.getTriggeringLocation().toString(),null);
        if(geofencingEvent.hasError() == false){
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                geofencingEvent.getTriggeringGeofences().forEach(geofence -> handleTrigger(context,geofence,geofencingEvent.getGeofenceTransition()));
            }
        }

    }

    public void handleTrigger(Context context, Geofence fence, int transitionType){
        String fenceId = fence.getRequestId();

        GeoNotification geoNotification = store.getGeoNotification(fenceId);
        if(geoNotification == null){
            return;
        }

        String transition = "";
        boolean isDwell = transitionType == Geofence.GEOFENCE_TRANSITION_DWELL;
        if(isDwell){
            transition = "DWELL";
        }
        if(transitionType == Geofence.GEOFENCE_TRANSITION_ENTER){
            transition = "ENTER";
        }
        if(transitionType == Geofence.GEOFENCE_TRANSITION_EXIT){
            transition = "EXIT";
        }

        if(isDwell != false || geoNotification.notification != null){
            notifier.notify(
                    geoNotification.notification,
                    transitionType == Geofence.GEOFENCE_TRANSITION_ENTER ? "enter" : "exit"
            );
        }

        Logger.getLogger().log(transition+" "+transitionType+" "+fence.getRequestId(),null);

        if(GeoFenceWithHttpPlugin.callback != null){
            PluginResult result = new PluginResult();
            result.put("fence",new Gson().fromJson(new Gson().toJson(geoNotification), Map.class) );
            GeoFenceWithHttpPlugin.callback.successCallback(result);
        }

        TimeZone tz = TimeZone.getTimeZone("UTC");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
        df.setTimeZone(tz);


        PersistableBundle bundle = new PersistableBundle();
        bundle.putString("id", geoNotification.id);
        bundle.putString("url", geoNotification.url);
        bundle.putString("sessionToken",new Gson().toJson(geoNotification.headers));
        bundle.putString("transition", transition);
        bundle.putString("date", df.format(new Date()));

        JobScheduler jobScheduler =
                (JobScheduler) context.getSystemService(Context.JOB_SCHEDULER_SERVICE);
        jobScheduler.schedule(
                new JobInfo.Builder(1, new ComponentName(context, TransitionJobService.class))
                        .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
                        .setMinimumLatency(1)
                        .setOverrideDeadline(1)
                        .setExtras(bundle)
                        .build());

    }
}
