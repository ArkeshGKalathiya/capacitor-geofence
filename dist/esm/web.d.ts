import { WebPlugin } from '@capacitor/core';
import type { Geofence, GeoFenceWithHttpPlugin } from './definitions';
export declare class GeoFenceWithHttpWeb extends WebPlugin implements GeoFenceWithHttpPlugin {
    onTransitionReceived: (geofences: Geofence[]) => void;
    onNotificationClicked: (notificationData: any) => void;
    initialize(): Promise<any>;
    addOrUpdate(): Promise<any>;
    remove(): Promise<any>;
    removeAll(): Promise<any>;
    requestLocationPermission(): Promise<{
        foreground: boolean;
        background: boolean;
    }>;
    permissionStatus(): Promise<{
        foreground: boolean;
        background: boolean;
    }>;
    removeForIds(): Promise<any>;
    onTransition(): Promise<any>;
}
