import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vod_upload_flutter/txugc_publish_log.dart';
import 'package:vod_upload_flutter/txugc_publish_type_def.dart';

class TXUGCPublish {
  static const String _TAG = "TXUGCPublish";
  static const _PUBLISH_METHOD_CHANNEL_PATH =
      "cloud.tencent.com/txvodplayer/videoUpload";
  static const _apiChannel = MethodChannel(_PUBLISH_METHOD_CHANNEL_PATH);
  static bool _isInit = false;
  static final Map<String, ITXVideoPublishListener> _videoPublishListener = {};
  static final Map<String, ITXMediaPublishListener> _mediaPublishListener = {};
  static IUploadResumeController? _uploadResumeController;

  /// id: binding between the native layer object and the dart layer object
  final String id;

  TXUGCPublish({required this.id}) {
    if (!_isInit) {
      _isInit = true;
      _init();
    }
  }

  /// initialize function
  static void _init() {
    _apiChannel.setMethodCallHandler(_handleCallback);
  }

  /// detail callback
  static Future<dynamic> _handleCallback(MethodCall call) async {
    String taskId = call.arguments["id"];
    var callback = call.arguments["callback"];
    Map<String, dynamic> resp = jsonDecode(callback);
    Map<String, dynamic>? data = resp["data"];
    if (data?.isEmpty ?? true) {
      return;
    }
    data!;
    switch (call.method) {
      case Apis.ON_PUBLISH_PROGRESS:
        {
          ITXVideoPublishListener? listener = _videoPublishListener[taskId];
          TXUGCPublishLog.debug(_TAG,
              "onPublishProgress : id : $taskId : uploadBytes : ${data["uploadBytes"]} totalBytes : ${data["totalBytes"]}");
          listener?.onPublishProgress(
            data["uploadBytes"],
            data["totalBytes"],
          );
          break;
        }
      case Apis.ON_PUBLISH_COMPLETE:
        {
          Map<String, dynamic>? detail = data["detail"];
          if (detail?.isEmpty ?? true) {
            return;
          }
          detail!;
          var videoResult = TXPublishResult(
            detail["retCode"],
            detail["descMsg"],
            detail["videoId"],
            detail["videoURL"],
            detail["coverURL"],
          );
          ITXVideoPublishListener? listener = _videoPublishListener[taskId];
          TXUGCPublishLog.debug(_TAG,
              "onPublishComplete : id : $taskId : retCode : ${videoResult.retCode} descMsg : ${videoResult.descMsg} videoId : ${videoResult.videoId} videoURL : ${videoResult.videoURL} coverURL : ${videoResult.coverURL}");
          listener?.onPublishComplete(videoResult);
          break;
        }
      case Apis.ON_MEDIA_PUBLISH_PROGRESS:
        {
          ITXMediaPublishListener? listener = _mediaPublishListener[taskId];
          TXUGCPublishLog.debug(_TAG,
              "onMediaPublishProgress : id : $taskId : uploadBytes : ${data["uploadBytes"]} totalBytes : ${data["totalBytes"]}");
          listener?.onMediaPublishProgress(
            data["uploadBytes"],
            data["totalBytes"],
          );
          break;
        }
      case Apis.ON_MEDIA_PUBLISH_COMPLETE:
        {
          Map<String, dynamic>? detail = data["detail"];
          if (detail?.isEmpty ?? true) {
            return;
          }
          detail!;
          var mediaResult = TXMediaPublishResult(
            detail["retCode"],
            detail["descMsg"],
            detail["mediaId"],
            detail["mediaURL"],
          );
          ITXMediaPublishListener? listener = _mediaPublishListener[taskId];
          TXUGCPublishLog.debug(_TAG,
              "onMediaPublishComplete : id : $taskId : retCode : ${mediaResult.retCode} descMsg : ${mediaResult.descMsg} mediaId : ${mediaResult.mediaId} mediaURL : ${mediaResult.mediaURL}");
          listener?.onMediaPublishComplete(mediaResult);
          break;
        }
    }
  }

  setIsDebug(bool isDebug) {
    if (isDebug) {
      TXUGCPublishLog.useDebug();
    }
    TXUGCPublishLog.debug(_TAG, "setIsDebug : id : $id : isDebug : $isDebug");
    _apiChannel.invokeMethod(Apis.SET_IS_DEBUG, {
      "id": id,
      "isDebug": isDebug,
    });
  }

  /// upload video
  Future<int> publishVideo(TXPublishParam param) async {
    TXUGCPublishLog.debug(
        _TAG, "publishVideo : id : $id : param : ${param.toString()}");
    bool isDefaultResumeController = _uploadResumeController == null;
    String respJson = await _apiChannel.invokeMethod(Apis.PUBLISH_VIDEO, {
      "id": id,
      "signature": param.signature,
      "videoPath": param.videoPath,
      "fileName": param.fileName,
      "enableResume": param.enableResume,
      "enableHttps": param.enableHttps,
      "enablePreparePublish": param.enablePreparePublish,
      "sliceSize": param.sliceSize,
      "concurrentCount": param.concurrentCount,
      "coverPath": param.coverPath,
      "isDefaultResumeController": isDefaultResumeController
    });
    Map<String, dynamic> resp = jsonDecode(respJson);
    return resp["code"];
  }

  /// upload media file
  Future<int> publishMedia(TXMediaPublishParam param) async {
    TXUGCPublishLog.debug(
        _TAG, "publishMedia : id : $id : param : ${param.toString()}");
    bool isDefaultResumeController = _uploadResumeController == null;
    String respJson = await _apiChannel.invokeMethod(Apis.PUBLISH_MEDIA, {
      "id": id,
      "signature": param.signature,
      "mediaPath": param.mediaPath,
      "fileName": param.fileName,
      "enableResume": param.enableResume,
      "enableHttps": param.enableHttps,
      "enablePreparePublish": param.enablePreparePublish,
      "sliceSize": param.sliceSize,
      "concurrentCount": param.concurrentCount,
      "isDefaultResumeController": isDefaultResumeController
    });
    Map<String, dynamic> resp = jsonDecode(respJson);
    return resp["code"];
  }

  /// pause upload video
  Future<void> pauseUploadVideo() async {
    TXUGCPublishLog.debug(_TAG, "pauseUploadVideo : id : $id");
    return await _apiChannel.invokeMethod(Apis.PAUSE_UPLOAD_VIDEO, {"id": id});
  }

  /// cancel upload video
  Future<void> cancelUploadVideo() async {
    TXUGCPublishLog.debug(_TAG, "cancelUploadVideo : id : $id");
    return await _apiChannel.invokeMethod(Apis.CANCEL_UPLOAD_VIDEO, {"id": id});
  }

  /// pause upload media file
  Future<void> pauseUploadMedia() async {
    TXUGCPublishLog.debug(_TAG, "pauseUploadMedia : id : $id");
    return await _apiChannel.invokeMethod(Apis.PAUSE_UPLOAD_MEDIA, {"id": id});
  }

  /// cancel upload media file
  Future<void> cancelUploadMedia() async {
    TXUGCPublishLog.debug(_TAG, "cancelUploadMedia : id : $id");
    return await _apiChannel.invokeMethod(Apis.CANCEL_UPLOAD_MEDIA, {"id": id});
  }

  /// resume upload video
  Future<int> resumeUploadVideo(TXPublishParam param) async {
    TXUGCPublishLog.debug(
        _TAG, "resumeUploadVideo : id : $id : param : ${param.toString()}");
    bool isDefaultResumeController = _uploadResumeController == null;
    var respJson = await _apiChannel.invokeMethod(Apis.RESUME_UPLOAD_VIDEO, {
      "id": id,
      "signature": param.signature,
      "videoPath": param.videoPath,
      "fileName": param.fileName,
      "enableResume": param.enableResume,
      "enableHttps": param.enableHttps,
      "enablePreparePublish": param.enablePreparePublish,
      "sliceSize": param.sliceSize,
      "concurrentCount": param.concurrentCount,
      "coverPath": param.coverPath,
      "isDefaultResumeController": isDefaultResumeController
    });
    Map<String, dynamic> resp = jsonDecode(respJson);
    return resp["code"];
  }

  /// resume upload media file
  Future<int> resumeUploadMedia(TXMediaPublishParam param) async {
    TXUGCPublishLog.debug(
        _TAG, "resumeUploadMedia : id : $id : param : ${param.toString()}");
    bool isDefaultResumeController = _uploadResumeController == null;
    var respJson = await _apiChannel.invokeMethod(Apis.RESUME_UPLOAD_MEDIA, {
      "id": id,
      "signature": param.signature,
      "mediaPath": param.mediaPath,
      "fileName": param.fileName,
      "enableResume": param.enableResume,
      "enableHttps": param.enableHttps,
      "enablePreparePublish": param.enablePreparePublish,
      "sliceSize": param.sliceSize,
      "concurrentCount": param.concurrentCount,
      "isDefaultResumeController": isDefaultResumeController
    });
    Map<String, dynamic> resp = jsonDecode(respJson);
    return resp["code"];
  }

  /// report appid
  Future<void> setAppId(int appId) async {
    var respJson = await _apiChannel
        .invokeMethod(Apis.SET_APPID, {"id": id, "appId": appId});
    var resp = jsonDecode(respJson);
    if (resp["code"] == 0) {
      TXUGCPublishLog.debug(_TAG, "setAppId : id : $id : appid : $appId");
    }
  }

  /// get report status info
  Future<ReportInfo?> getStatusInfo() async {
    var respJson =
        await _apiChannel.invokeMethod(Apis.GET_STATUS_INFO, {"id": id});
    var resp = jsonDecode(respJson);
    if (resp["code"] == 0) {
      ReportInfo reportInfo = ReportInfo.formJson(resp["data"]);
      TXUGCPublishLog.debug(_TAG,
          "getStatusInfo : id : $id : reportInfo : ${reportInfo.toString()}");
      return reportInfo;
    }
    return null;
  }

  /// set video upload callback
  void setVideoListener(ITXVideoPublishListener listener) {
    TXUGCPublishLog.debug(_TAG, "setVideoListener : id : $id");
    _videoPublishListener[id] = listener;
  }

  /// set media file upload callback
  void setMediaListener(ITXMediaPublishListener listener) {
    TXUGCPublishLog.debug(_TAG, "setMediaListener : id : $id");
    _mediaPublishListener[id] = listener;
  }

  /// prepare upload
  static Future<void> prepareUpload(
      String signature, IPrepareUploadCallback callback) async {
    TXUGCPublishLog.debug(_TAG, "prepareUpload : signature : $signature");
    callback.onLoading();
    await _apiChannel
        .invokeMethod(Apis.PREPARE_UPLOAD, {"signature": signature});
    callback.onFinish();
  }

  /// The following code is for the custom continuation point calculation function, which is currently not enabled in the current version
  static Future<dynamic> _handleResumeMethodCall(MethodCall call) async {
    if (_uploadResumeController == null) return;
    dynamic res;
    switch (call.method) {
      case Apis.SAVE_SESSION:
        var filePath = call.arguments["filePath"];
        var vodSessionKey = call.arguments["vodSessionKey"];
        var uploadId = call.arguments["uploadId"];
        var resumeData = call.arguments["resumeData"];
        var uploadJson = call.arguments["uploadInfo"];
        var uploadInfo = TVCUploadInfo.fromJson(jsonDecode(uploadJson));
        if (defaultTargetPlatform == TargetPlatform.android) {
          _uploadResumeController?.saveSessionAndroid(
              filePath, vodSessionKey, uploadId, uploadInfo);
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          _uploadResumeController?.saveSessionIOS(
              filePath, vodSessionKey, resumeData, uploadInfo);
        }
        break;
      case Apis.CLEAR_LOCAL_CACHE:
        _uploadResumeController?.clearLocalCache();
        break;
      case Apis.GET_RESUME_DATA:
        var filePath = call.arguments["filePath"];
        res = _uploadResumeController?.getResumeData(filePath);
        break;
      case Apis.IS_RESUME_UPLOAD_VIDEO:
        var fileLastModTime = call.arguments["fileLastModTime"];
        var coverFileLastModTime = call.arguments["coverFileLastModTime"];
        var vodSessionKey = call.arguments["vodSessionKey"];
        var uploadId = call.arguments["uploadId"];
        var uploadJson = call.arguments["uploadInfo"];
        var uploadInfo = TVCUploadInfo.fromJson(jsonDecode(uploadJson));
        res = _uploadResumeController?.isResumeUploadVideo(uploadId, uploadInfo,
            vodSessionKey, fileLastModTime, coverFileLastModTime);
        break;
    }
    if (res == null) return;
    var data = jsonEncode(res);
    return {"data": data};
  }

  static void _setUploadResumeController(IUploadResumeController controller) {
    _uploadResumeController = controller;
  }
}
