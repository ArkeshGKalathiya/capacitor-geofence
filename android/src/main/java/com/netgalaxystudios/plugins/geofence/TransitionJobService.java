package com.netgalaxystudios.plugins.geofence;

import android.app.job.JobParameters;
import android.app.job.JobService;
import android.os.Build;
import android.os.PersistableBundle;
import android.util.Log;

import com.google.gson.Gson;

import java.io.BufferedWriter;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Collections;
import java.util.Map;

/**
 * Created by jupe on 22-02-18.
 */

public class TransitionJobService extends JobService {

    @Override
    public boolean onStartJob(final JobParameters jobParameters) {
        PersistableBundle params = jobParameters.getExtras();
        final String url = params.getString("url");
        final String headers = params.getString("headers");
        final String id = params.getString("id");
        final String transition = params.getString("transition");
        final String date = params.getString("date");

        Thread thread = new Thread(() -> {
            try {
                sendTransitionToServer(url, headers, id, transition, date);
                jobFinished(jobParameters, false);
            } catch (Exception exception) {
                // It is possible to have no network during transition from Cellular to Wifi
                Log.e(GeoFenceWithHttpPlugin.TAG, "Error while sending geofence transition, rescheduling", exception);
                jobFinished(jobParameters, true);
            }
        });
        thread.start();

        return true; // Async
    }

    @Override
    public boolean onStopJob(JobParameters jobParameters) {
        return false;
    }

    private void sendTransitionToServer(String urlString, String headers, String id, String transition, String date) throws Exception {
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setReadTimeout(10000);
        conn.setConnectTimeout(15000);
        conn.setRequestMethod("POST");
        conn.setDoInput(true);
        conn.setDoOutput(true);

        conn.setRequestProperty("Content-Type", "application/json");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            Map map = new Gson().fromJson(headers, Map.class);
            if(map != null){
                map.forEach((Object K,Object V) -> conn.setRequestProperty(K.toString(),V.toString()));
            }
        }


        OutputStream os = conn.getOutputStream();
        BufferedWriter writer = new BufferedWriter(
                new OutputStreamWriter(os, "UTF-8"));
        String json = "{ \"geofenceId\": \"" + id + "\",  \"transition\": \"" + transition + "\", \"date\": \"" + date +"\" }";
        Log.i(GeoFenceWithHttpPlugin.TAG, "Sending Geofence transition to server: " + json);
        writer.write(json);
        writer.flush();
        writer.close();
        os.close();

        conn.connect();
        int responseCode = conn.getResponseCode();
        Log.i(GeoFenceWithHttpPlugin.TAG, "Send Geofence transition to server: " + responseCode);
    }
}
