import { WebPlugin } from '@capacitor/core';

import type { Geofence, GeoFenceWithHttpPlugin } from './definitions';

export class GeoFenceWithHttpWeb
  extends WebPlugin
  implements GeoFenceWithHttpPlugin {
  

  onTransitionReceived: (geofences: Geofence[]) => void = () => { return; };
  onNotificationClicked: (notificationData: any) => void = () => { return; };

  initialize(): Promise<any> {
    throw new Error('Method not implemented.');
  }
  addOrUpdate(): Promise<any> {
    throw new Error('Method not implemented.');
  }
  remove(): Promise<any> {
    throw new Error('Method not implemented.');
  }
  removeAll(): Promise<any> {
    throw new Error('Method not implemented.');
  }
  requestLocationPermission(): Promise<{ foreground: boolean; background: boolean; }> {
    throw new Error('Method not implemented.');
  }
  permissionStatus(): Promise<{ foreground: boolean; background: boolean; }> {
    throw new Error('Method not implemented.');
  }
  removeForIds(): Promise<any> {
    throw new Error('Method not implemented.');
  }
  onTransition(): Promise<any> {
    throw new Error('Method not implemented.');
  }


}
