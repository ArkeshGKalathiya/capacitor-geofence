var capacitorGeoFenceWithHttp = (function (exports, core) {
    'use strict';

    const GeoFenceWithHttp = core.registerPlugin('GeoFenceWithHttp', {
        web: () => Promise.resolve().then(function () { return web; }).then(m => new m.GeoFenceWithHttpWeb()),
    });

    class GeoFenceWithHttpWeb extends core.WebPlugin {
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

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        GeoFenceWithHttpWeb: GeoFenceWithHttpWeb
    });

    exports.GeoFenceWithHttp = GeoFenceWithHttp;

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
