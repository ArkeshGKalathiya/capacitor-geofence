import Foundation
import Capacitor
import WebKit
import UserNotifications
import CoreLocation

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(GeoFenceWithHttpPlugin)
public class GeoFenceWithHttpPlugin: CAPPlugin, CLLocationManagerDelegate {
    private let implementation = GeoFenceWithHttp();
    lazy var locationManager : CLLocationManager = CLLocationManager();
    var permissionCallbackId : String?;

    
    
    
    
    @objc func initialize(_ call : CAPPluginCall){
        locationManager.delegate = self;
        call.resolve();
    }
    
    @objc func permissionStatus(_ call : CAPPluginCall){
        let status = CLLocationManager.authorizationStatus();
        var foreground = false;
        var background = false
        if status == .authorizedWhenInUse {
            foreground = true;
            background = false;
        }
        if status == .authorizedAlways {
            foreground = true;
            background = true;
        }
        
        call.resolve([
            "foreground" : foreground,
            "background" : background
        ]);
    }
    
    @objc func requestLocationPermission(_ call : CAPPluginCall){
        if CLLocationManager.locationServicesEnabled() {
            bridge?.saveCall(call);
            permissionCallbackId = call.callbackId;
            locationManager.requestAlwaysAuthorization();
        } else {
            permissionStatus(call);
        }
    }
    
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if(permissionCallbackId != nil && bridge != nil){
            let call : CAPPluginCall? = bridge?.savedCall(withID: permissionCallbackId!);
            if(call != nil){
                permissionStatus(call!);
                bridge?.releaseCall(call!);
            }
        }
        permissionCallbackId = nil;
    }

}
