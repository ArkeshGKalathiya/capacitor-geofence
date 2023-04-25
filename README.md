# capacitor-geofence-http

This plugin is derived from okode/cordova-plugin-geofence with added support for making http requests

## Install

```bash
npm install capacitor-geofence-http
npx cap sync
```

## API

<docgen-index>

* [`initialize()`](#initialize)
* [`addOrUpdate(...)`](#addorupdate)
* [`removeForIds(...)`](#removeforids)
* [`removeAll()`](#removeall)
* [`onTransition(...)`](#ontransition)
* [`requestLocationPermission()`](#requestlocationpermission)
* [`permissionStatus()`](#permissionstatus)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initialize()

```typescript
initialize() => Promise<any>
```

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### addOrUpdate(...)

```typescript
addOrUpdate(geofence: { fences: Geofence | Geofence[]; }) => Promise<any>
```

| Param          | Type                                                                     |
| -------------- | ------------------------------------------------------------------------ |
| **`geofence`** | <code>{ fences: <a href="#geofence">Geofence</a> \| Geofence[]; }</code> |

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### removeForIds(...)

```typescript
removeForIds({ fenceIds, }: { fenceIds: string[]; }) => Promise<any>
```

| Param     | Type                                 |
| --------- | ------------------------------------ |
| **`__0`** | <code>{ fenceIds: string[]; }</code> |

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### removeAll()

```typescript
removeAll() => Promise<any>
```

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### onTransition(...)

```typescript
onTransition(callback: (fence: Geofence, error: any) => void) => Promise<any>
```

| Param          | Type                                                                          |
| -------------- | ----------------------------------------------------------------------------- |
| **`callback`** | <code>(fence: <a href="#geofence">Geofence</a>, error: any) =&gt; void</code> |

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### requestLocationPermission()

```typescript
requestLocationPermission() => Promise<{ foreground: boolean; background: boolean; }>
```

**Returns:** <code>Promise&lt;{ foreground: boolean; background: boolean; }&gt;</code>

--------------------


### permissionStatus()

```typescript
permissionStatus() => Promise<{ foreground: boolean; background: boolean; }>
```

**Returns:** <code>Promise&lt;{ foreground: boolean; background: boolean; }&gt;</code>

--------------------


### Interfaces


#### Geofence

| Prop                 | Type                                                  |
| -------------------- | ----------------------------------------------------- |
| **`id`**             | <code>string</code>                                   |
| **`latitude`**       | <code>number</code>                                   |
| **`longitude`**      | <code>number</code>                                   |
| **`radius`**         | <code>number</code>                                   |
| **`transitionType`** | <code>number</code>                                   |
| **`notification`**   | <code><a href="#notification">Notification</a></code> |
| **`url`**            | <code>string</code>                                   |
| **`headers`**        | <code>{ [key: string]: string; }</code>               |


#### Notification

| Prop                 | Type                  |
| -------------------- | --------------------- |
| **`id`**             | <code>number</code>   |
| **`title`**          | <code>string</code>   |
| **`text`**           | <code>string</code>   |
| **`entryText`**      | <code>string</code>   |
| **`leaveText`**      | <code>string</code>   |
| **`smallIcon`**      | <code>string</code>   |
| **`icon`**           | <code>string</code>   |
| **`openAppOnClick`** | <code>boolean</code>  |
| **`vibration`**      | <code>number[]</code> |
| **`data`**           | <code>any</code>      |

</docgen-api>
