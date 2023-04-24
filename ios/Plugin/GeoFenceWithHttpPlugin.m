#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(GeoFenceWithHttpPlugin, "GeoFenceWithHttp",
    CAP_PLUGIN_METHOD(initialize, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(permissionStatus, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(requestLocationPermission, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(onTransition, CAPPluginReturnCallback);
    CAP_PLUGIN_METHOD(addOrUpdate, CAPPluginReturnPromise);
           
)
