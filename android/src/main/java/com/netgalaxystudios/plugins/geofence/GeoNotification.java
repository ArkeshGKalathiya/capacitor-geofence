package com.netgalaxystudios.plugins.geofence;

import com.google.android.gms.location.Geofence;
import com.google.gson.annotations.Expose;
import java.util.Map;

public class GeoNotification {
    @Expose public String id;
    @Expose public double latitude;
    @Expose public double longitude;
    @Expose public int radius;
    @Expose public int transitionType;
    @Expose public int loiteringDelay;

    @Expose public String url;
    @Expose public Map<String,Object> headers;


    @Expose public Notification notification;

    public GeoNotification() {
    }

    public Geofence toGeofence() {
        return new Geofence.Builder()
                .setRequestId(id)
                .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_ENTER | Geofence.GEOFENCE_TRANSITION_EXIT)
                .setCircularRegion(latitude, longitude, radius)
                .setLoiteringDelay(loiteringDelay == 0 ? 60 * 60 * 1000 : loiteringDelay)
                .setNotificationResponsiveness(1000)
                .setExpirationDuration(Long.MAX_VALUE).build();
    }

    public String toJson() {
        return Gson.get().toJson(this);
    }

    public static GeoNotification fromJson(String json) {
        return Gson.get().fromJson(json,GeoNotification.class);
    }
}
