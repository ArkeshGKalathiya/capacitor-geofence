package com.netgalaxystudios.plugins.geofence;

import android.Manifest;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.os.Build;
import android.util.Log;

import androidx.core.app.ActivityCompat;
import androidx.core.location.LocationManagerCompat;

import com.getcapacitor.PluginCall;
import com.google.android.gms.location.Geofence;
import com.google.android.gms.location.GeofencingClient;
import com.google.android.gms.location.GeofencingRequest;
import com.google.android.gms.location.LocationServices;
import java.util.ArrayList;
import java.util.List;

public class GeoFenceWithHttp {

    private GeofencingClient client;
    private PendingIntent pendingIntent;
    final private Context context;
    final private GeoNotificationStore store;

    GeoFenceWithHttp(Context c){
        this.context = c;
        this.store = new GeoNotificationStore(c);
        this.client = LocationServices.getGeofencingClient(context);
    }

    public Boolean isLocationServicesEnabled() {
        LocationManager lm = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        return LocationManagerCompat.isLocationEnabled(lm);
    }

    public void loadFromStorageAndInitializeGeofences() {
        List<GeoNotification> geoNotifications = store.getAll();
        addOrUpdateGeofence(null,geoNotifications);
    }




    public void addOrUpdateGeofence(PluginCall call,List<GeoNotification> geofenceList) {

        List<Geofence> geofences = new ArrayList<>();
        for (int i = 0; i < geofenceList.size(); i++) {
            GeoNotification gn = geofenceList.get(i);
            geofences.add(gn.toGeofence());
            store.setGeoNotification(gn);
        }

        GeofencingRequest request = new GeofencingRequest.Builder().setInitialTrigger(GeofencingRequest.INITIAL_TRIGGER_ENTER).addGeofences(geofences).build();
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            call.reject("MISSING_PERMISSIONS");
            return;
        }

        this.client.addGeofences(request, getIntent())
                .addOnSuccessListener(unused -> {
                    if(call != null){
                        call.resolve();
                    }
                })
                .addOnFailureListener(e -> {
                    if(call != null){
                        call.reject("FAILED",e);
                    }
                });
    }

    public void removeWithIds(List<String> geofenceIds){
        this.client.removeGeofences(geofenceIds);
        for(int i=0;i<geofenceIds.size();i+=1){
            store.remove(geofenceIds.get(i));
        }
    }

    public void removeAll(){
        store.clear();
        this.client.removeGeofences(getIntent());
    }


    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }

    public PendingIntent getIntent(){
        if(pendingIntent != null){
            return pendingIntent;
        }
        Intent intent = new Intent(context, GeoFenceBroadcastReceiver.class);
        int flag = PendingIntent.FLAG_UPDATE_CURRENT;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flag = flag | PendingIntent.FLAG_MUTABLE;
        }
        pendingIntent = PendingIntent.getBroadcast(context, 0, intent, flag);
        return pendingIntent;
    }
}
