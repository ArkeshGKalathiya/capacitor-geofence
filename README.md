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
| **`startTime`**      | <code><a href="#date">Date</a></code>                 |
| **`endTime`**        | <code><a href="#date">Date</a></code>                 |
| **`notification`**   | <code><a href="#notification">Notification</a></code> |
| **`url`**            | <code>string</code>                                   |
| **`headers`**        | <code>{ [key: string]: string; }</code>               |


#### Date

Enables basic storage and retrieval of dates and times.

| Method                 | Signature                                                                                                    | Description                                                                                                                             |
| ---------------------- | ------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| **toString**           | () =&gt; string                                                                                              | Returns a string representation of a date. The format of the string depends on the locale.                                              |
| **toDateString**       | () =&gt; string                                                                                              | Returns a date as a string value.                                                                                                       |
| **toTimeString**       | () =&gt; string                                                                                              | Returns a time as a string value.                                                                                                       |
| **toLocaleString**     | () =&gt; string                                                                                              | Returns a value as a string value appropriate to the host environment's current locale.                                                 |
| **toLocaleDateString** | () =&gt; string                                                                                              | Returns a date as a string value appropriate to the host environment's current locale.                                                  |
| **toLocaleTimeString** | () =&gt; string                                                                                              | Returns a time as a string value appropriate to the host environment's current locale.                                                  |
| **valueOf**            | () =&gt; number                                                                                              | Returns the stored time value in milliseconds since midnight, January 1, 1970 UTC.                                                      |
| **getTime**            | () =&gt; number                                                                                              | Gets the time value in milliseconds.                                                                                                    |
| **getFullYear**        | () =&gt; number                                                                                              | Gets the year, using local time.                                                                                                        |
| **getUTCFullYear**     | () =&gt; number                                                                                              | Gets the year using Universal Coordinated Time (UTC).                                                                                   |
| **getMonth**           | () =&gt; number                                                                                              | Gets the month, using local time.                                                                                                       |
| **getUTCMonth**        | () =&gt; number                                                                                              | Gets the month of a <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                             |
| **getDate**            | () =&gt; number                                                                                              | Gets the day-of-the-month, using local time.                                                                                            |
| **getUTCDate**         | () =&gt; number                                                                                              | Gets the day-of-the-month, using Universal Coordinated Time (UTC).                                                                      |
| **getDay**             | () =&gt; number                                                                                              | Gets the day of the week, using local time.                                                                                             |
| **getUTCDay**          | () =&gt; number                                                                                              | Gets the day of the week using Universal Coordinated Time (UTC).                                                                        |
| **getHours**           | () =&gt; number                                                                                              | Gets the hours in a date, using local time.                                                                                             |
| **getUTCHours**        | () =&gt; number                                                                                              | Gets the hours value in a <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                       |
| **getMinutes**         | () =&gt; number                                                                                              | Gets the minutes of a <a href="#date">Date</a> object, using local time.                                                                |
| **getUTCMinutes**      | () =&gt; number                                                                                              | Gets the minutes of a <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                           |
| **getSeconds**         | () =&gt; number                                                                                              | Gets the seconds of a <a href="#date">Date</a> object, using local time.                                                                |
| **getUTCSeconds**      | () =&gt; number                                                                                              | Gets the seconds of a <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                           |
| **getMilliseconds**    | () =&gt; number                                                                                              | Gets the milliseconds of a <a href="#date">Date</a>, using local time.                                                                  |
| **getUTCMilliseconds** | () =&gt; number                                                                                              | Gets the milliseconds of a <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                      |
| **getTimezoneOffset**  | () =&gt; number                                                                                              | Gets the difference in minutes between the time on the local computer and Universal Coordinated Time (UTC).                             |
| **setTime**            | (time: number) =&gt; number                                                                                  | Sets the date and time value in the <a href="#date">Date</a> object.                                                                    |
| **setMilliseconds**    | (ms: number) =&gt; number                                                                                    | Sets the milliseconds value in the <a href="#date">Date</a> object using local time.                                                    |
| **setUTCMilliseconds** | (ms: number) =&gt; number                                                                                    | Sets the milliseconds value in the <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                              |
| **setSeconds**         | (sec: number, ms?: number \| undefined) =&gt; number                                                         | Sets the seconds value in the <a href="#date">Date</a> object using local time.                                                         |
| **setUTCSeconds**      | (sec: number, ms?: number \| undefined) =&gt; number                                                         | Sets the seconds value in the <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                   |
| **setMinutes**         | (min: number, sec?: number \| undefined, ms?: number \| undefined) =&gt; number                              | Sets the minutes value in the <a href="#date">Date</a> object using local time.                                                         |
| **setUTCMinutes**      | (min: number, sec?: number \| undefined, ms?: number \| undefined) =&gt; number                              | Sets the minutes value in the <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                   |
| **setHours**           | (hours: number, min?: number \| undefined, sec?: number \| undefined, ms?: number \| undefined) =&gt; number | Sets the hour value in the <a href="#date">Date</a> object using local time.                                                            |
| **setUTCHours**        | (hours: number, min?: number \| undefined, sec?: number \| undefined, ms?: number \| undefined) =&gt; number | Sets the hours value in the <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                     |
| **setDate**            | (date: number) =&gt; number                                                                                  | Sets the numeric day-of-the-month value of the <a href="#date">Date</a> object using local time.                                        |
| **setUTCDate**         | (date: number) =&gt; number                                                                                  | Sets the numeric day of the month in the <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                        |
| **setMonth**           | (month: number, date?: number \| undefined) =&gt; number                                                     | Sets the month value in the <a href="#date">Date</a> object using local time.                                                           |
| **setUTCMonth**        | (month: number, date?: number \| undefined) =&gt; number                                                     | Sets the month value in the <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                     |
| **setFullYear**        | (year: number, month?: number \| undefined, date?: number \| undefined) =&gt; number                         | Sets the year of the <a href="#date">Date</a> object using local time.                                                                  |
| **setUTCFullYear**     | (year: number, month?: number \| undefined, date?: number \| undefined) =&gt; number                         | Sets the year value in the <a href="#date">Date</a> object using Universal Coordinated Time (UTC).                                      |
| **toUTCString**        | () =&gt; string                                                                                              | Returns a date converted to a string using Universal Coordinated Time (UTC).                                                            |
| **toISOString**        | () =&gt; string                                                                                              | Returns a date as a string value in ISO format.                                                                                         |
| **toJSON**             | (key?: any) =&gt; string                                                                                     | Used by the JSON.stringify method to enable the transformation of an object's data for JavaScript Object Notation (JSON) serialization. |


#### Notification

| Prop                 | Type                  |
| -------------------- | --------------------- |
| **`id`**             | <code>number</code>   |
| **`title`**          | <code>string</code>   |
| **`text`**           | <code>string</code>   |
| **`smallIcon`**      | <code>string</code>   |
| **`icon`**           | <code>string</code>   |
| **`openAppOnClick`** | <code>boolean</code>  |
| **`vibration`**      | <code>number[]</code> |
| **`data`**           | <code>any</code>      |

</docgen-api>
