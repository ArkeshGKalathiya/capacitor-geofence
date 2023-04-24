import Foundation
import AudioToolbox
import Capacitor
import WebKit
import UserNotifications
import CoreLocation


let TAG = "GeofencePlugin"
let iOS8 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)

func log(_ message: String){
    NSLog("%@ - %@", TAG, message)
}

func log(_ messages: [String]) {
    for message in messages {
        log(message);
    }
}

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(GeoFenceWithHttpPlugin)
public class GeoFenceWithHttpPlugin: CAPPlugin, CLLocationManagerDelegate {
    private let implementation = GeoFenceWithHttp();
    private let decoder = JSONDecoder();
    private let geoNotificationManager : GeoNotificationManager;
    let priority = DispatchQoS.QoSClass.default
    
    private let locationManager : CLLocationManager;
    var permissionCallbackId : String?;
    var transitionCallbackId : String?;
    var localNotificationCallbackId : String?;
    
    
    public override init(bridge: CAPBridgeProtocol, pluginId: String, pluginName: String) {
        self.locationManager = CLLocationManager();
        self.geoNotificationManager = GeoNotificationManager();
        super.init(bridge: bridge, pluginId: pluginId, pluginName: pluginName);
        
        self.locationManager.delegate = self;
        
        
        
    }
    
    
    @objc func initialize(_ call : CAPPluginCall){
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(GeoFenceWithHttpPlugin.didReceiveLocalNotification(_:)),
//            name: NSNotification.Name(rawValue: "CDVLocalNotification"),
//            object: nil
//        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(GeoFenceWithHttpPlugin.didReceiveTransition(_:)),
            name: NSNotification.Name(rawValue: "handleTransition"),
            object: nil
        )
        
        self.geoNotificationManager.isActive = true;
        self.geoNotificationManager.startUpdatingLocation();
        call.resolve();
        
    }
    
    @objc func onTransition(_ call:CAPPluginCall){
        if transitionCallbackId != nil{
            let call = bridge?.savedCall(withID: transitionCallbackId!);
            if(call != nil){
                bridge?.releaseCall(call!);
            }
        }
        bridge?.saveCall(call);
        transitionCallbackId = call.callbackId;
    }
    
    @objc func permissionStatus(_ call : CAPPluginCall){
        let status = CLLocationManager.authorizationStatus();
        var foreground = false;
        var background = false
        if status == .authorizedWhenInUse {
            foreground = true;
            background = false;
        }else if status == .authorizedAlways {
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
            
            let status = CLLocationManager.authorizationStatus();
            if status == .denied || status == .authorizedWhenInUse || status == .authorizedAlways{
                permissionStatus(call);
                return;
            }
            
            
            bridge?.saveCall(call);
            permissionCallbackId = call.callbackId;
            locationManager.requestAlwaysAuthorization();
        } else {
            permissionStatus(call);
        }
    }
    
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if(permissionCallbackId != nil && bridge != nil){
            let status = CLLocationManager.authorizationStatus();
            if(status != .denied && status != .notDetermined){
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){ granted, error in
                }
            }
            let call : CAPPluginCall? = bridge?.savedCall(withID: permissionCallbackId!);
            if(call != nil){
                permissionStatus(call!);
                bridge?.releaseCall(call!);
            }
        }
        permissionCallbackId = nil;
    }
    
    @objc func didReceiveTransition (_ notification: Notification) {
        if notification.object is String {
            if(transitionCallbackId == nil){
                return;
            }
            let call = bridge?.savedCall(withID: transitionCallbackId!);
            if(call == nil){
                return;
            }
            call?.resolve(JSON(stringLiteral: notification.object as! String).dictionaryObject ?? [:]);
        }
    }
    
    @objc func addOrUpdate(_ call: CAPPluginCall) {
        let fences : JSArray? = call.getArray("fences");
        for fence in fences!{
            self.geoNotificationManager.addOrUpdateGeoNotification(JSON(fence))
        }
//
        log("asd");
//        call.get
//        DispatchQueue.global(qos: priority).async {
//            for geo in command.arguments {
//                self.geoNotificationManager.addOrUpdateGeoNotification(JSON(geo))
//            }
//            DispatchQueue.main.async {
//                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
//                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
//            }
//        }
    }
    
}


@available(iOS 8.0, *)
class GeoNotificationManager : NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    let locationManager : CLLocationManager;
    let store = GeoNotificationStore()
    var snoozedFences = [String : Double]()
    var isActive = false
    
    override init() {
        self.locationManager = CLLocationManager();
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }
    
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func addOrUpdateGeoNotification(_ geoNotification: JSON) {
        var geoNotification = geoNotification
        log("GeoNotificationManager addOrUpdate")
        
        let (_, warnings, errors) = checkRequirements()
        
        log(warnings)
        log(errors)
        
        let location = CLLocationCoordinate2DMake(
            geoNotification["latitude"].doubleValue,
            geoNotification["longitude"].doubleValue
        )
        log("AddOrUpdate geo: \(geoNotification)")
        let radius = geoNotification["radius"].doubleValue as CLLocationDistance
        let id = geoNotification["id"].stringValue
        
        let region = CLCircularRegion(center: location, radius: radius, identifier: id)
        
        var transitionType = 0
        if let i = geoNotification["transitionType"].int {
            transitionType = i
        }
        region.notifyOnEntry = 0 != transitionType & 1
        region.notifyOnExit = 0 != transitionType & 2
        
        geoNotification["isInside"] = false
        //store
        store.addOrUpdate(geoNotification)
        locationManager.startMonitoring(for: region)
    }
    
    func checkRequirements() -> (Bool, [String], [String]) {
        var errors = [String]()
        var warnings = [String]()
        
        if (!CLLocationManager.isMonitoringAvailable(for: CLRegion.self)) {
            errors.append("Geofencing not available")
        }
        
        if (!CLLocationManager.locationServicesEnabled()) {
            errors.append("Error: Locationservices not enabled")
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus != .authorizedAlways {
            if authStatus != .authorizedWhenInUse {
                errors.append("Error: Location when in use permissions not granted")
            } else {
                warnings.append("Warning: Location always permissions not granted")
            }
        }
        
        let ok = (errors.count == 0)
        return (ok, warnings, errors)
    }
    
    func getWatchedGeoNotifications() -> [JSON]? {
        return store.getAll()
    }
    
    func getMonitoredRegion(_ id: String) -> CLRegion? {
        for object in locationManager.monitoredRegions {
            let region = object
            
            if (region.identifier == id) {
                return region
            }
        }
        return nil
    }
    
    func removeGeoNotification(_ id: String) {
        store.remove(id)
        let region = getMonitoredRegion(id)
        if (region != nil) {
            log("Stoping monitoring region \(id)")
            locationManager.stopMonitoring(for: region!)
        }
        //resetting snoozed fence
        snoozeFence(id, duration: 0)
    }
    
    func removeAllGeoNotifications() {
        store.clear()
        for object in locationManager.monitoredRegions {
            let region = object
            log("Stoping monitoring region \(region.identifier)")
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func handleTransition(_ id: String, transitionType: Int) {
        if var geoNotification = store.findById(id),
           !isSnoozed(id),
           isWithinTimeRange(geoNotification) {
            geoNotification["transitionType"].int = transitionType
            
            if geoNotification["notification"].isExists() && canBeTriggered(geoNotification) {
                notifyAbout(geoNotification,transitionType: transitionType)
            }
            
            if geoNotification["url"].isExists() {
                log("Should post to " + geoNotification["url"].stringValue)
                let url = URL(string: geoNotification["url"].stringValue)!
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                //formatter.locale = Locale(identifier: "en_US")
                
                let jsonDict = ["geofenceId": geoNotification["id"].stringValue, "transition": geoNotification["transitionType"].intValue == 1 ? "ENTER" : "EXIT", "date": dateFormatter.string(from: Date())]
                let jsonData = try! JSONSerialization.data(withJSONObject: jsonDict, options: [])
                
                var request = URLRequest(url: url)
                request.httpMethod = "post"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(geoNotification["applicationId"].stringValue, forHTTPHeaderField: "X-Parse-Application-Id")
                request.setValue(geoNotification["javascriptId"].stringValue, forHTTPHeaderField: "X-Parse-Javascript-Key")
                request.setValue(geoNotification["sessionToken"].stringValue, forHTTPHeaderField: "X-Parse-Session-Token")
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error {
                        print("error:", error)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "handleTransition"), object: geoNotification.rawString(String.Encoding.utf8.rawValue, options: []))
                        return
                    }
                    
                    do {
                        guard let data = data else { return }
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else { return }
                        print("json:", json)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "handleTransition"), object: geoNotification.rawString(String.Encoding.utf8.rawValue, options: []))
                    } catch {
                        print("error:", error)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "handleTransition"), object: geoNotification.rawString(String.Encoding.utf8.rawValue, options: []))
                    }
                }
                
                task.resume()
            }
            
            
        }
    }
    
    func canBeTriggered(_ geo: JSON) -> Bool {
        let store = GeoNotificationStore()
        if(geo["notification"]["lastTriggered"].isExists() && geo["notification"]["frequency"].isExists()) {
            if(Int(NSDate().timeIntervalSince1970) < geo["notification"]["lastTriggered"].int! + geo["notification"]["frequency"].int!) {
                log("Frequency control. Skip notification")
                return false
            }
        }
        store.updateLastTriggeredByNotificationId(geo["notification"]["id"].stringValue)
        return true
    }
    
    func isWithinTimeRange(_ geoNotification: JSON) -> Bool {
        let now = Date()
        var greaterThanOrEqualToStartTime: Bool = true
        var lessThanEndTime: Bool = true
        if geoNotification["startTime"].isExists() {
            if let startTime = parseDate(dateStr: geoNotification["startTime"].stringValue) {
                greaterThanOrEqualToStartTime = (now.compare(startTime) == ComparisonResult.orderedDescending || now.compare(startTime) == ComparisonResult.orderedSame)
            }
        }
        if geoNotification["endTime"].isExists() {
            if let endTime = parseDate(dateStr: geoNotification["endTime"].stringValue) {
                lessThanEndTime = now.compare(endTime) == ComparisonResult.orderedAscending
            }
        }
        return greaterThanOrEqualToStartTime && lessThanEndTime
    }
    
    func parseDate(dateStr: String?) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: dateStr!)
    }
    
    func notifyAbout(_ geo: JSON, transitionType : Int) {
        if #available(iOS 10.0, *) {
            log("Creating notification iOS > 10")
            let content = UNMutableNotificationContent()
            if let title = geo["notification"]["title"] as JSON? {
                content.title = title.stringValue
            }
            content.body = "This is dummy body......."
            if(transitionType == 1){
                if let text = geo["notification"]["enterText"] as JSON? {
                    content.body = text.stringValue
                }
            }else if(transitionType == 2){
                if let text = geo["notification"]["leaveText"] as JSON? {
                    content.body = text.stringValue
                }
            }
            
            content.sound = UNNotificationSound.default
            if let json = geo["notification"]["data"] as JSON? {
                content.userInfo = ["geofence.notification.data": json.rawString(String.Encoding.utf8.rawValue, options: [])!]
            }
            let identifier = "asdfasdfasdfasdfasdfdfdfdfdf234e234234"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: nil)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if error != nil {
                    log("Couldn't create notification")
                }
            })
        } else {
            log("Creating notification iOS < 10")
            let notification = UILocalNotification()
            notification.timeZone = TimeZone.current
            let dateTime = Date()
            notification.fireDate = dateTime
            notification.soundName = UILocalNotificationDefaultSoundName
            if let title = geo["notification"]["title"] as JSON? {
                notification.alertTitle = title.stringValue
            }
            notification.alertBody = "This is body";
            if(transitionType == 1){
                if let text = geo["notification"]["enterText"] as JSON? {
                    notification.alertBody = text.stringValue
                }
            }else if(transitionType == 2){
                if let text = geo["notification"]["leaveText"] as JSON? {
                    notification.alertBody = text.stringValue
                }
            }
            notification.userInfo = [:];
            if let json = geo["notification"]["data"] as JSON? {
                notification.userInfo = ["geofence.notification.data": json.rawString(String.Encoding.utf8.rawValue, options: [])!]
            }
            UIApplication.shared.scheduleLocalNotification(notification)
            if let vibrate = geo["notification"]["vibrate"].array {
                if (!vibrate.isEmpty && vibrate[0].intValue > 0) {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
            }
        }
    }
    
    func dismissNotifications(_ ids: [String]) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
    
    func snoozeFence(_ id: String, duration: Double) {
        snoozedFences[id] = NSTimeIntervalSince1970 + duration
    }
    
    func isSnoozed(_ id: String?) -> Bool {
        guard let id = id, let fenceTime = snoozedFences[id] else {
            return false
        }
        return fenceTime > NSTimeIntervalSince1970
    }
    
    func checkTransition(_ location: CLLocation) {
        if let allStored = store.getAll() {
            for var json in allStored {
                let radius = json["radius"].doubleValue as CLLocationDistance
                let coord = CLLocation(latitude: json["latitude"].doubleValue, longitude: json["longitude"].doubleValue)
                
                
                if location.distance(from: coord) <= radius {
                    if !json["isInside"].boolValue {
                        if json["transitionType"].intValue == 1 || json["transitionType"].intValue == 3 {
                            handleTransition(json["id"].stringValue, transitionType: 1)
                        }
                        json["isInside"] = true
                        store.addOrUpdate(json)
                    }
                } else {
                    if json["isInside"].boolValue {
                        if json["transitionType"].intValue == 2 || json["transitionType"].intValue == 3 {
                            handleTransition(json["id"].stringValue, transitionType: 2)
                        }
                        json["isInside"] = false
                        store.addOrUpdate(json)
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        log("update location \(locations[0])")
        if isActive {
            checkTransition(locations[0])
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log("fail with error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        log("deferred fail error: \(String(describing: error))")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        log("Entering region \(region.identifier)")
        if !isActive {
            handleTransition(region.identifier, transitionType: 1)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        log("Exiting region \(region.identifier)")
        if !isActive {
            handleTransition(region.identifier, transitionType: 2)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region is CLCircularRegion {
            let lat = (region as! CLCircularRegion).center.latitude
            let lng = (region as! CLCircularRegion).center.longitude
            let radius = (region as! CLCircularRegion).radius
            
            log("Starting monitoring for region \(region) lat \(lat) lng \(lng) of radius \(radius)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        log("State for region " + region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        log("Monitoring region " + region!.identifier + " failed \(error)" )
    }
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.content.userInfo["geofence.notification.data"] != nil {
            // Play sound and show alert to the user if it is a geofence notification
            completionHandler([.alert,.sound])
        } else if (notification.request.content.userInfo["foreground"] != nil) {
            // Play sound and show alert to the user if the notification has foreground property
            completionHandler([.alert,.sound])
        } else {
            completionHandler([])
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Determine the user action
        log(response.actionIdentifier)
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            log("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            if let data = response.notification.request.content.userInfo["geofence.notification.data"] {
                log("userNotificationCenter didReceive: \(data)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "CDVLocalNotification"), object: data)
            }
        case "Snooze":
            snoozeFence(response.notification.request.identifier, duration: 86400)
        case "Delete":
            snoozeFence(response.notification.request.identifier, duration: 300)
        default:
            log("Unknown action")
        }
        completionHandler()
    }
}

class GeoNotificationStore {
    init() {
        createDBStructure()
    }
    
    func createDBStructure() {
        let (tables, err) = SD.existingTables()
        
        if (err != nil) {
            log("Cannot fetch sqlite tables: \(String(describing: err))")
            return
        }
        
        if (tables.filter { $0 == "GeoNotifications" }.count == 0) {
            if let err = SD.executeChange("CREATE TABLE GeoNotifications (ID TEXT PRIMARY KEY, Data TEXT)") {
                //there was an error during this function, handle it here
                log("Error while creating GeoNotifications table: \(err)")
            } else {
                //no error, the table was created successfully
                log("GeoNotifications table was created successfully")
            }
        }
    }
    
    func addOrUpdate(_ geoNotification: JSON) {
        NSLog("geoNotification.description: %@", geoNotification.description)
        if (findById(geoNotification["id"].stringValue) != nil) {
            update(geoNotification)
        }
        else {
            add(geoNotification)
        }
    }
    
    func add(_ geoNotification: JSON) {
        let id = geoNotification["id"].stringValue
        var notificationCopy = geoNotification
        notificationCopy["lastTriggered"] = 0
        let err = SD.executeChange("INSERT INTO GeoNotifications (Id, Data) VALUES(?, ?)",
                                   withArgs: [id as AnyObject, notificationCopy.description as AnyObject])
        
        if err != nil {
            log("Error while adding \(id) GeoNotification: \(String(describing: err))")
        }
    }
    
    func update(_ geoNotification: JSON) {
        let id = geoNotification["id"].stringValue
        let err = SD.executeChange("UPDATE GeoNotifications SET Data = ? WHERE Id = ?",
                                   withArgs: [geoNotification.description as AnyObject, id as AnyObject])
        
        if err != nil {
            log("Error while adding \(id) GeoNotification: \(String(describing: err))")
        }
    }
    
    func updateLastTriggeredByNotificationId(_ id: String) {
        if let allStored = getAll() {
            for var json in allStored {
                if json["notification"]["id"].stringValue == id {
                    json["notification"]["lastTriggered"] = JSON(NSDate().timeIntervalSince1970)
                    update(json)
                }
            }
        }
    }
    
    func findById(_ id: String) -> JSON? {
        let (resultSet, err) = SD.executeQuery("SELECT * FROM GeoNotifications WHERE Id = ?", withArgs: [id as AnyObject])
        
        if err != nil {
            //there was an error during the query, handle it here
            log("Error while fetching \(id) GeoNotification table: \(String(describing: err))")
            return nil
        } else {
            if (resultSet.count > 0) {
                let jsonString = resultSet[0]["Data"]!.asString()!
                return JSON(data: jsonString.data(using: String.Encoding.utf8)!)
            }
            else {
                return nil
            }
        }
    }
    
    func getAll() -> [JSON]? {
        let (resultSet, err) = SD.executeQuery("SELECT * FROM GeoNotifications")
        
        if err != nil {
            //there was an error during the query, handle it here
            log("Error while fetching from GeoNotifications table: \(String(describing: err))")
            return nil
        } else {
            var results = [JSON]()
            for row in resultSet {
                if let data = row["Data"]?.asString() {
                    results.append(JSON(data: data.data(using: String.Encoding.utf8)!))
                }
            }
            return results
        }
    }
    
    func remove(_ id: String) {
        let err = SD.executeChange("DELETE FROM GeoNotifications WHERE Id = ?", withArgs: [id as AnyObject])
        
        if err != nil {
            log("Error while removing \(id) GeoNotification: \(String(describing: err))")
        }
    }
    
    func clear() {
        let err = SD.executeChange("DELETE FROM GeoNotifications")
        
        if err != nil {
            log("Error while deleting all from GeoNotifications: \(String(describing: err))")
        }
    }
}
