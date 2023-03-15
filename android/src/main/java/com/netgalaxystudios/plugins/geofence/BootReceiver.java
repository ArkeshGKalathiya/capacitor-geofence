package com.netgalaxystudios.plugins.geofence;



import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class BootReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Logger.setLogger(new Logger(GeoFenceWithHttpPlugin.TAG, context, false));
        Logger.getLogger().log("Caught the startup",null);
        GeoFenceWithHttp implementation = new GeoFenceWithHttp(context);
        implementation.loadFromStorageAndInitializeGeofences();
    }
}