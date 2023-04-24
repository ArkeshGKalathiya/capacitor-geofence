export interface GeoFenceWithHttpPlugin {
    initialize(): Promise<any>;
    addOrUpdate(geofence: {
        fences: Geofence | Geofence[];
    }): Promise<any>;
    removeForIds({ fenceIds, }: {
        fenceIds: string[];
    }): Promise<any>;
    removeAll(): Promise<any>;
    onTransition(): Promise<any>;
    requestLocationPermission(): Promise<{
        foreground: boolean;
        background: boolean;
    }>;
    permissionStatus(): Promise<{
        foreground: boolean;
        background: boolean;
    }>;
}
export interface PermissionStatus {
    geofence: boolean;
}
export interface Geofence {
    id: string;
    latitude: number;
    longitude: number;
    radius: number;
    transitionType: number;
    notification?: Notification;
    url?: string;
    headers?: {
        [key: string]: string;
    };
}
export interface Notification {
    id?: number;
    title: string;
    text: string;
    smallIcon?: string;
    icon?: string;
    openAppOnClick?: boolean;
    vibration?: number[];
    data?: any;
}
