package com.netgalaxystudios.plugins.geofence;

import com.google.android.gms.location.Geofence;
import com.google.gson.Gson;
import com.google.gson.annotations.Expose;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

public class GeoNotification {
    @Expose public String id;
    @Expose public double latitude;
    @Expose public double longitude;
    @Expose public int radius;
    @Expose public int transitionType;
    @Expose public int loiteringDelay;

    @Expose public String url;
    @Expose public Map<String,Object> headers;
    @Expose public String startTime;
    @Expose public String endTime;


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
        return new Gson().toJson(this);
    }

    public static GeoNotification fromJson(String json) {
        return new Gson().fromJson(json,GeoNotification.class);
    }

    public Date getStartTime() {
        return parseDate(this.startTime);
    }

    public Date getEndTime() {
        return parseDate(this.endTime);
    }

    public boolean isWithinTimeRange() {
        Date now = new Date();
        Date startTime = getStartTime();
        Date endTime = getEndTime();
        boolean greaterThanOrEqualToStartTime = true;
        boolean lessThanEndTime = true;
        if (startTime != null) {
            greaterThanOrEqualToStartTime = now.after(startTime) || now.getTime() == startTime.getTime();
        }
        if (endTime != null) {
            lessThanEndTime = now.before(endTime);
        }
        return greaterThanOrEqualToStartTime && lessThanEndTime;
    }

    private Date parseDate(String date) {
        if (date == null) {
            return null;
        }
        try {
            SimpleDateFormat format = new SimpleDateFormat(
                    "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);
            format.setTimeZone(TimeZone.getTimeZone("UTC"));
            return format.parse(date);
        } catch (ParseException e) {
            return null;
        }
    }
}
