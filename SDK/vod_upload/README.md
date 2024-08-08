## Flutter - Vod上传

Flutter Vod上传SDK

### 环境准备

- Flutter:
  - Flutter 2.5.0及以上版本
  - Dart 2.19.2及以上3.0以下版本
- Android:
  - Android Studio 3.5及以上版本
  - Android 4.1及以上版本
- iOS:
  - Xcode 11.0及以上版本
  - iOS 9.0及以上版本
  - 请确保您的项目已设置有效的开发者签名

### 快速集成

#### 引入依赖

1. 将SDK源码复制到项目目录下

2. 在`pubspec.yaml`中引入`SDK`

```yaml
vod_upload_flutter:
  path: ./vod_upload
```

3. 项目根目录下运行`flutter pub get`命令刷新依赖

> 注：
> 1. 最好在`项目根目录`、`SDK目录`、`SDK Example目录`下分别运行`flutter pub get`命令，不然有可能报错
> 2. `SDK Example目录`为`SDK`的测试项目，如无需要可以删掉

#### 添加原生配置

##### Android

在`AndroidManifest.xml`中增加如下配置

```xml
<!--网络权限-->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
```

**网络安全配置允许App发送HTTP请求**：出于安全考虑，从 Android P开始，Google要求App的请求都使用加密链接。SDK上传需要进行网络请求，如果您的应用`targetSdkVersion >= 28`，并且`需要采用HTTP协议进行上传`，可以通过**网络安全配置**来开启允许发送HTTP请求。 否则播放时将出现`java.io.IOException: Cleartext HTTP traffic to xxx not permitted`错误，导致无法上传。配置步骤如下：

1. 在项目新建`res/xml/network_security_config.xml`文件，设置网络安全性配置

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<network-security-config>
    <base-config cleartextTrafficPermitted="ture" />
</network-security-config>
```

> 注：上述配置仅限**测试环境**下使用，生产环境中应按需进行网络安全性配置

2. 在`AndroidManifest.xml`文件下的`application`标签中增加以下属性

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

在`iOS`的`Info.plist`中增加如下配置

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

> 注：如需运行`SDK`中提供的`Demo`，还应声明相册使用权限

### 使用

1. 引入文件

```dart
import 'package:vod_upload_flutter/txugc_publish.dart';
```

2. 创建对象

```dart
var uploader = TXUGCPublish(
    id: "",
);
```

> 注：`id`可以为任意字符串，只要**保证不重复**即可，主要目的是将Flutter对象与原生层对象进行映射

### API

#### 上传视频

```dart
uploader.publishVideo(TXPublishParam(
      signature: "",
      videoPath: "",
      fileName: "",
));
```

#### 取消上传视频

```dart
uploader.cancelUploadVideo();
```

#### 恢复上传视频

```dart
uploader.resumeUploadVideo(TXPublishParam(
      signature: "",
      videoPath: "",
      fileName: "",
));
```

#### 上传媒体文件

```dart
uploader.publishMedia(TXMediaPublishParam(
      signature: "",
      mediaPath: "",
      fileName: "",
));
```

#### 取消上传媒体文件

```dart
uploader.cancelUploadMedia();
```

#### 恢复上传媒体文件

```dart
uploader.resumeUploadMedia(TXMediaPublishParam(
      signature: "",
      mediaPath: "",
      fileName: "",
));
```

#### 预上传

```dart
TXUGCPublish.prepareUpload(signature, callback);
```

> 注：预上传为**静态方法**

#### 获取上传信息

```dart
// android端只能在上传过程中获取信息, iOS端全程都可以获取信息
uploader.getStatusInfo();
```

#### 上报`AppId`

```dart
uploader.setAppId(appId);
```

#### 设置视频上传回调

```dart
uploader.setVideoListener(listener);
```

#### 设置媒体上传回调

```dart
uploader.setMediaListener(listener);
```

### 回调接口及参数解释

#### 视频上传参数

`TXPublishParam`

|字段名|类型|是否必填|解释|默认值|
|-------|-------|:------:|------|------|
|signature|string|✅|签名|null|
|videoPath|string|✅|视频路径|null|
|fileName|string|✅|文件名|null|
|enableResume|boolean|❌|是否启用续点|true|
|enableHttps|boolean|❌|是否启用https|false|
|coverPath|string|❌|封面图|null|
|enablePreparePublish|boolean|❌|是否启用预上传(关闭后可手动预上传)|true|
|sliceSize|integer|❌|分片大小(支持最小为1M,最大10M,默认0,代表上传文件大小除以10)|0|
|concurrentCount|integer|❌|分片上传并发数量(若<=0,则取SDK内部默认值2)|-1|

#### 媒体上传参数

`TXMediaPublishParam`

|字段名|类型|是否必填|解释|默认值|
|-------|-------|:------:|------|------|
|signature|string|✅|签名|null|
|mediaPath|string|✅|媒体文件路径|null|
|fileName|string|✅|文件名|null|
|enableResume|boolean|❌|是否启用续点|true|
|enableHttps|boolean|❌|是否启用https|false|
|coverPath|string|❌|封面图|null|
|enablePreparePublish|boolean|❌|是否启用预上传(关闭后可手动预上传)|true|
|sliceSize|integer|❌|分片大小(支持最小为1M,最大10M,默认0,代表上传文件大小除以10)|0|
|concurrentCount|integer|❌|分片上传并发数量(若<=0,则取SDK内部默认值2)|-1|

#### 视频上传回调

`ITXVideoPublishListener`

|方法名|返回值|解释|
|-------|-------|------|
|onPublishProgress|void|上传进度回调|
|onPublishComplete|void|上传完成回调|

参数解释:

`onPublishProgress`

|参数名|类型|解释|
|-------|-------|------|
|uploadBytes|integer|上传的字节数|
|totalBytes|integer|总计字节数|

`onPublishComplete`

|参数名|类型|解释|
|-------|-------|------|
|result|TXPublishResult|上传结果|

`TXPublishResult`

|字段名|类型|解释|
|-------|-------|------|
|retCode|integer|错误码|
|descMsg|string|错误描述信息|
|videoId|string|视频文件Id|
|videoURL|string|视频播放地址|
|coverURL|string|封面存储地址|

#### 媒体文件上传回调

`ITXMediaPublishListener`

|方法名|返回值|解释|
|-------|-------|------|
|onMediaPublishProgress|void|上传进度回调|
|onMediaPublishComplete|void|上传完成回调|

参数解释:

`onMediaPublishProgress`

|参数名|类型|解释|
|-------|-------|------|
|uploadBytes|integer|上传的字节数|
|totalBytes|integer|总计字节数|

`onMediaPublishComplete`

|参数名|类型|解释|
|-------|-------|------|
|result|TXMediaPublishResult|上传结果|

`TXMediaPublishResult`

|字段名|类型|解释|
|-------|-------|------|
|retCode|integer|错误码|
|descMsg|string|错误描述信息|
|mediaId|string|媒体文件Id|
|mediaURL|string|媒体文件地址|

#### 预上传回调

`IPrepareUploadCallback`

|方法名|返回值|解释|
|-------|-------|------|
|onLoading|void|开始预上传回调|
|onFinish|void|预上传完成回调|

#### 上传状态信息

`ReportInfo`

|字段名|类型|解释|
|-------|-------|------|
|reqType|string|请求类型，标识是在哪个步骤|
|errCode|string|错误码|
|cosErrCode|string|COS上传错误码|
|errMsg|string|错误信息|
|reqTime|string|当前步骤的请求开始时间|
|reqTimeCost|string|当前步骤的耗时|
|fileSize|string|文件大小|
|fileType|string|文件类型|
|fileName|string|文件名|
|fileId|string|文件Id|
|appId|string|使用TXUGCPublish设置进来的点播appId|
|reqServerIp|string|当前正在进行步骤所访问的ip|
|reportId|string|客户自定义上报id，可通过TXUGCPublish构造方法传入|
|reqKey|string|请求键值，一般由文件最后修改时间和本次上传开始时间组成|
|vodSessionKey|string|点播服务器会话键值，从申请上传接口获得|
|cosRegion|string|当前上传所访问的区域|
|requestId|string|当前cos上传的请求id|
|cosVideoPath|string|当前cos视频上传的路径|
|vodErrCode|integer|信令请求错误码|
|useHttpDNS|integer|是否使用httpDns进行域名解析|
|useCosAcc|integer|是否开启了cos域名加速|
|tcpConnTimeCost|integer|当前步骤链接服务器耗时|
|recvRespTimeCost|integer|当前步骤收到服务器响应耗时|
