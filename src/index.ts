import { registerPlugin } from '@capacitor/core';

import type { GeoFenceWithHttpPlugin } from './definitions';

const GeoFenceWithHttp = registerPlugin<GeoFenceWithHttpPlugin>(
  'GeoFenceWithHttp',
  {
    
    web: () => import('./web').then(m => new m.GeoFenceWithHttpWeb()),
  },
);

export * from './definitions';
export { GeoFenceWithHttp };
