## Flutter - Vod Upload

Flutter Vod Upload SDK

### Environment Setup

- Flutter:
    - Flutter 2.5.0 and above
    - Dart 2.19.2 and below 3.0
- Android:
    - Android Studio 3.5 and above
    - Android 4.1 and above
- iOS:
    - Xcode 11.0 and above
    - iOS 9.0 and above
    - Make sure your project has a valid developer signature set up

### Quick Integration

#### Add Dependencies

1. Copy the SDK source code to your project directory.

2. Add the SDK to `pubspec.yaml`

```yaml
vod_upload_flutter:
  path: ./vod_upload
```

3. Run the command `flutter pub get` in the root directory of your project to refresh the dependencies.

> Note:
> 1. It is recommended to run `flutter pub get` command separately in the `root directory`, `SDK directory`, and `SDK Example directory` to avoid potential errors.
> The `SDK Example directory` is the test project for the SDK. You can delete it if not needed.

#### Add Native Configurations

##### Android

Add the following configurations to `AndroidManifest.xml`

```xml
<!-- Network permissions -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```

**Allow App to Send HTTP Requests**: Starting from Android P, Google requires that app requests use encrypted connections for security reasons. The SDK requires network requests for uploading. If your app has `targetSdkVersion >= 28` and needs to use the HTTP protocol for uploading, you can enable sending HTTP requests through network security configuration. Otherwise, you may encounter the `java.io.IOException: Cleartext HTTP traffic to xxx not permitted` error, which prevents uploading. Follow these steps to configure it:

1. Create a `res/xml/network_security_config.xml` file in your project to set up network security configuration

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<network-security-config>
    <base-config cleartextTrafficPermitted="ture" />
</network-security-config>
```

> Note: The above configuration is only for `testing environments`. In production environments, you should configure network security as needed.

2. Add the following attribute to the `application` tag in the `AndroidManifest.xml` file

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest ... >
    <application android:networkSecurityConfig="@xml/network_security_config"
                    ... >
        ...
    </application>
</manifest>
```

##### iOS

Add the following configuration to `Info.plist` in `iOS`

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

> Note: If you want to run the provided `Demo` in the `SDK`, you should also declare permission to use the photo library.

### Usage

1. Import the file

```dart
import 'package:vod_upload_flutter/txugc_publish.dart';
```

2. Create an object

```dart
var uploader = TXUGCPublish(
    id: "",
);
```

> 注：The `id` can be any string as long as it is `unique`. The main purpose is to map the Flutter object to the native layer object.

### API

#### Upload Video

```dart
uploader.publishVideo(TXPublishParam(
      signature: "",
      videoPath: "",
      fileName: "",
));
```

#### Cancel Video Upload

```dart
uploader.cancelUploadVideo();
```

#### Resume Video Upload

```dart
uploader.resumeUploadVideo(TXPublishParam(
      signature: "",
      videoPath: "",
      fileName: "",
));
```

#### Upload Media File

```dart
uploader.publishMedia(TXMediaPublishParam(
      signature: "",
      mediaPath: "",
      fileName: "",
));
```

#### Cancel Media File Upload

```dart
uploader.cancelUploadMedia();
```

#### Resume Media File Upload

```dart
uploader.resumeUploadMedia(TXMediaPublishParam(
      signature: "",
      mediaPath: "",
      fileName: "",
));
```

#### Prepare Upload

```dart
TXUGCPublish.prepareUpload(signature, callback);
```

> Note: Prepare upload is a `static method`

#### Get Upload Information

```dart
// On Android, you can only get information during the upload process, while on iOS, you can get information throughout the process.
uploader.getStatusInfo();
```

#### Report `AppId`

```dart
uploader.setAppId(appId);
```

#### Set Video Upload Callback

```dart
uploader.setVideoListener(listener);
```

#### Set Media Upload Callback

```dart
uploader.setMediaListener(listener);
```

### Callback Interfaces and Parameter Explanations

#### Video Upload Parameters

`TXPublishParam`

|Field|Type|Required|Explanation|Default Value|
|-------|-------|:------:|------|------|
|signature|string|✅|Signature|null|
|videoPath|string|✅|Video path|null|
|fileName|string|✅|File name|null|
|enableResume|boolean|❌|Enable resumable upload|true|
|enableHttps|boolean|❌|Enable HTTPS|false|
|coverPath|string|❌|Cover image|null|
|enablePreparePublish|boolean|❌|Enable prepare upload (can be manually triggered if disabled)|true|
|sliceSize|integer|❌|Chunk size (minimum 1M, maximum 10M, default 0, which means the file size divided by 10)|0|
|concurrentCount|integer|❌|Concurrent number of chunk uploads (if <=0, the default value of 2 will be used)|-1|

#### 媒体上传参数

`TXMediaPublishParam`

|Field|Type|Required|Explanation|Default Value|
|-------|-------|:------:|------|------|
|signature|string|✅|签名|null|
|mediaPath|string|✅|Media file path|null|
|fileName|string|✅|File name|null|
|enableResume|boolean|❌|Enable resumable upload|true|
|enableHttps|boolean|❌|Enable HTTPS|false|
|coverPath|string|❌|Cover image|null|
|enablePreparePublish|boolean|❌|Enable prepare upload (can be manually triggered if disabled)|true|
|sliceSize|integer|❌|Chunk size (minimum 1M, maximum 10M, default 0, which means the file size divided by 10)|0|
|concurrentCount|integer|❌|Concurrent number of chunk uploads (if <=0, the default value of 2 will be used)|-1|

#### Video Upload Callback

`ITXVideoPublishListener`

|Method|Return Type|Explanation|
|-------|-------|------|
|onPublishProgress|void|Upload progress callback|
|onPublishComplete|void|Upload completion callback|

Parameter explanation:

`onPublishProgress`

|Parameter|Type|Explanation|
|-------|-------|------|
|uploadBytes|integer|Number of bytes uploaded|
|totalBytes|integer|Total number of bytes|

`onPublishComplete`

|Parameter|Type|Explanation|
|-------|-------|------|
|result|TXPublishResult|Upload result|

`TXPublishResult`

|Parameter|Type|Explanation|
|-------|-------|------|
|retCode|integer|Error code|
|descMsg|string|Error description|
|videoId|string|Video file ID|
|videoURL|string|Video playback URL|
|coverURL|string|Cover image storage URL|

#### Media File Upload Callback

`ITXMediaPublishListener`

|Method|Return Type|Explanation|
|-------|-------|------|
|onMediaPublishProgress|void|Upload progress callback|
|onMediaPublishComplete|void|Upload completion callback|

Parameter explanation:

`onMediaPublishProgress`

|Parameter|Type|Explanation|
|-------|-------|------|
|uploadBytes|integer|Number of bytes uploaded|
|totalBytes|integer|Total number of bytes|

`onMediaPublishComplete`

|Parameter|Type|Explanation|
|-------|-------|------|
|result|TXMediaPublishResult|Upload result|

`TXMediaPublishResult`

|Parameter|Type|Explanation|
|-------|-------|------|
|retCode|integer|Error code|
|descMsg|string|Error description|
|mediaId|string|Media file ID|
|mediaURL|string|Media file URL|

#### Prepare Upload Callback

`IPrepareUploadCallback`

|Method|Return Type|Explanation|
|-------|-------|------|
|onLoading|void|Prepare upload start callback|
|onFinish|void|Prepare upload completion callback|

#### Upload Status Information

`ReportInfo`

|Field|Type|Explanation|
|-------|-------|------|
|reqType|string|Request type, indicating the current step|
|errCode|string|Error code|
|cosErrCode|string|COS upload error code|
|errMsg|string|Error message|
|reqTime|string|Request start time for the current step|
|reqTimeCost|string|Time spent on the current step|
|fileSize|string|File size|
|fileType|string|File type|
|fileName|string|File name|
|fileId|string|File ID|
|appId|string|VOD App ID set through TXUGCPublish|
|reqServerIp|string|IP address accessed during the current step|
|reportId|string|Custom report ID provided by the customer, can be passed through the TXUGCPublish constructor|
|reqKey|string|Request key, usually composed of the last modification time of the file and the start time of this upload|
|vodSessionKey|string|Session key from the VOD server, obtained from the upload request interface|
|cosRegion|string|Region accessed during the current upload|
|requestId|string|Request ID for the current COS upload|
|cosVideoPath|string|Path for the current COS video upload|
|vodErrCode|integer|Signaling request error code|
|useHttpDNS|integer|Whether to use httpDns for domain name resolution|
|useCosAcc|integer|Whether COS domain name acceleration is enabled|
|tcpConnTimeCost|integer|Time spent on connecting to the server in the current step|
|recvRespTimeCost|integer|Time spent on receiving server response in the current step|
