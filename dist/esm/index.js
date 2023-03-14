import { registerPlugin } from '@capacitor/core';
const GeoFenceWithHttp = registerPlugin('GeoFenceWithHttp', {
    web: () => import('./web').then(m => new m.GeoFenceWithHttpWeb()),
});
export * from './definitions';
export { GeoFenceWithHttp };
//# sourceMappingURL=index.js.map