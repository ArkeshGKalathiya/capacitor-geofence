package com.netgalaxystudios.plugins.geofence;

import android.Manifest;
import android.annotation.TargetApi;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.core.app.ActivityCompat;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.getcapacitor.annotation.PermissionCallback;
import com.google.android.gms.location.Geofence;
import com.google.gson.Gson;

import org.json.JSONException;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;

@CapacitorPlugin(
        name = "GeoFenceWithHttp",
        permissions = {
                @Permission(
                        alias = "foreground",
                        strings = {
                                Manifest.permission.ACCESS_COARSE_LOCATION,
                                Manifest.permission.ACCESS_FINE_LOCATION,
                        }
                ),
                @Permission(
                        alias = "background",
                        strings = {
                                Manifest.permission.ACCESS_BACKGROUND_LOCATION,
                        }
                )
        }
)
public class GeoFenceWithHttpPlugin extends Plugin {

    public static final String TAG = "Geofence.http";

    public static PluginCall callback;

    private GeoFenceWithHttp implementation;;

    private int getPermissionStatus(String permission){
        return ActivityCompat.checkSelfPermission(bridge.getActivity(),permission);
    }

    private boolean hasGrantedPermission(String permission){
        return getPermissionStatus(permission) == PackageManager.PERMISSION_GRANTED;
    }

    private boolean shouldRequestBackgroundSeparately(){
        return Build.VERSION.SDK_INT >= 29;
    }

    private boolean hasForegroundLocationAccess(){
        return hasGrantedPermission(Manifest.permission.ACCESS_COARSE_LOCATION)
                || hasGrantedPermission(Manifest.permission.ACCESS_FINE_LOCATION);
    }

    private boolean hasBackgroundLocationAccess(){
        return hasGrantedPermission(Manifest.permission.ACCESS_BACKGROUND_LOCATION);
    }


    @PluginMethod
    public void initialize(PluginCall call) {
        Logger.setLogger(new Logger(TAG,getContext(),false));
        implementation = new GeoFenceWithHttp(getContext());
        call.resolve();
    }

    @PluginMethod
    public void onTransition(PluginCall call){
        call.setKeepAlive(true);
        if(callback != null){
            callback.release(getBridge());
        }
        callback = call;
    }


    @PluginMethod
    public void requestLocationPermission(PluginCall call){
        boolean hasForeground = hasForegroundLocationAccess();
        boolean hasBackground = hasBackgroundLocationAccess();
        if(hasForeground && Build.VERSION.SDK_INT <= 28){
            afterPermissionRequest(call);
        }else if(hasForeground && hasBackground){
            afterPermissionRequest(call);
        }else if(shouldRequestBackgroundSeparately()){
            if(hasForeground){
                requestPermissionForAlias("background",call,"afterPermissionRequest");
            }else{
                requestPermissionForAlias("foreground",call,"afterForegroundPermissionRequest");
            }
        }else{
            requestPermissionForAlias("foreground",call,"afterPermissionRequest");
        }
    }


    @PluginMethod
    public void permissionStatus(PluginCall call){
        afterPermissionRequest(call);
    }

    @PluginMethod
    public void addOrUpdate(PluginCall call) throws JSONException {
        JSArray fences = call.getArray("fences");
        List<GeoNotification> gList = new ArrayList<>();

        for (int i = 0; i < fences.length(); i++) {
            String str = fences.get(i).toString();
            GeoNotification not = GeoNotification.fromJson(str);
            if (not != null) {
                gList.add(not);
            }
        }
        implementation.addOrUpdateGeofence(call,gList);
    }

    @PluginMethod
    public void removeForIds(PluginCall call) throws JSONException{
        JSArray ids = call.getArray("fenceIds");
        List<String> fenceIds = new ArrayList<>();
        if(ids != null){
            for(int i=0;i<ids.length();i+=1){
                fenceIds.add(ids.get(i).toString());
            }
        }
        implementation.removeWithIds(fenceIds);
        call.resolve();
    }

    @PluginMethod
    public void removeAll(PluginCall call){
        implementation.removeAll();
        call.resolve();
    }

    @PermissionCallback
    public void afterForegroundPermissionRequest(PluginCall call){
        if(hasForegroundLocationAccess()){
            if(shouldRequestBackgroundSeparately()){
                requestPermissionForAlias("background",call,"afterPermissionRequest");
            }else{
                afterPermissionRequest(call);
            }
        }else{
            afterPermissionRequest(call);
        }
    }

    @PermissionCallback
    public void afterPermissionRequest(PluginCall call){
        boolean hasForeground = hasGrantedPermission(Manifest.permission.ACCESS_COARSE_LOCATION)
                || hasGrantedPermission(Manifest.permission.ACCESS_FINE_LOCATION) ;

        boolean hasBackground = hasGrantedPermission(Manifest.permission.ACCESS_BACKGROUND_LOCATION);

        if(Build.VERSION.SDK_INT <= 28){
            hasBackground = hasForeground;
        }

        JSObject ob = new JSObject();
        ob.put("foreground",hasForeground);
        ob.put("background",hasBackground);
        Logger.getLogger().log(ob.toString(),null);
        call.resolve(ob);
    }


}
