import { WebPlugin } from '@capacitor/core';
export class GeoFenceWithHttpWeb extends WebPlugin {
    constructor() {
        super(...arguments);
        this.onTransitionReceived = () => { return; };
        this.onNotificationClicked = () => { return; };
    }
    initialize() {
        throw new Error('Method not implemented.');
    }
    addOrUpdate() {
        throw new Error('Method not implemented.');
    }
    remove() {
        throw new Error('Method not implemented.');
    }
    removeAll() {
        throw new Error('Method not implemented.');
    }
    requestLocationPermission() {
        throw new Error('Method not implemented.');
    }
    permissionStatus() {
        throw new Error('Method not implemented.');
    }
    removeForIds() {
        throw new Error('Method not implemented.');
    }
    onTransition() {
        throw new Error('Method not implemented.');
    }
}
//# sourceMappingURL=web.js.map