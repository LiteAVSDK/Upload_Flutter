import 'dart:typed_data';

class Apis {
  static const String PUBLISH_VIDEO = "publishVideo";
  static const String PAUSE_UPLOAD_VIDEO = "pauseUploadVideo";
  static const String RESUME_UPLOAD_VIDEO = "resumeUploadVideo";
  static const String CANCEL_UPLOAD_VIDEO = "cancelUploadVideo";
  static const String PUBLISH_MEDIA = "publishMedia";
  static const String PAUSE_UPLOAD_MEDIA = "pauseUploadMedia";
  static const String RESUME_UPLOAD_MEDIA = "resumeUploadMedia";
  static const String CANCEL_UPLOAD_MEDIA = "cancelUploadMedia";
  static const String REMOVE_CACHE = "removeCache";
  static const String PREPARE_UPLOAD = "prepareUpload";
  static const String SAVE_SESSION = "saveSession";
  static const String CLEAR_LOCAL_CACHE = "clearLocalCache";
  static const String GET_RESUME_DATA = "getResumeData";
  static const String IS_RESUME_UPLOAD_VIDEO = "isResumeUploadVideo";
  static const String SET_APPID = "setAppId";
  static const String GET_STATUS_INFO = "getStatusInfo";
  static const String SET_IS_DEBUG = "setIsDebug";

  static const String ON_PUBLISH_PROGRESS = "onPublishProgress";
  static const String ON_PUBLISH_COMPLETE = "onPublishComplete";
  static const String ON_MEDIA_PUBLISH_PROGRESS = "onMediaPublishProgress";
  static const String ON_MEDIA_PUBLISH_COMPLETE = "onMediaPublishComplete";
}

abstract class ITXVideoPublishListener {
  void onPublishProgress(int uploadBytes, int totalBytes);

  void onPublishComplete(TXPublishResult result);
}

abstract class ITXMediaPublishListener {
  void onMediaPublishProgress(int uploadBytes, int totalBytes);

  void onMediaPublishComplete(TXMediaPublishResult result);
}

abstract class IPrepareUploadCallback {
  void onLoading();

  void onFinish();
}

abstract class IUploadResumeController {
  /// 保存续点
  /// @param filePath 文件路径
  /// @param vodSessionKey 上传session
  /// @param uploadId 上传id
  /// @param uploadInfo 上传详情
  void saveSessionAndroid(String filePath, String vodSessionKey,
      String uploadId, TVCUploadInfo uploadInfo);

  void saveSessionIOS(String filePath, String vodSessionKey,
      Uint8List resumeData, TVCUploadInfo uploadInfo);

  /// 获得续点，当enableResume为true的时候，才会被调用
  /// @param filePath 文件路径
  ResumeCacheData getResumeData(String filePath);

  /// 清除过期续点
  void clearLocalCache();

  /// 判断是否是续点视频，当enableResume为true的时候，才会被调用
  bool isResumeUploadVideo(String uploadId, TVCUploadInfo uploadInfo,
      String vodSessionKey, int fileLastModTime, int coverFileLastModTime);
}

/// Definition of short video/media publishing result error codes.
/// The short video publishing process consists of three steps:
/// Step 1: Request to upload the file
/// Step 2: Upload the file
/// Step 3: Request to publish the short video/media
class ErrorCode {
  /// Publish successful
  static const int PUBLISH_RESULT_OK                    = 0;
  /// step0: Preparing for publishing failed
  static const int PUBLISH_RESULT_PUBLISH_PREPARE_ERROR = 1000;
  /// step1: "Short video/media" sending failed
  static const int PUBLISH_RESULT_UPLOAD_REQUEST_FAILED = 1001;
  /// step1: "Short video/media upload request" received error response
  static const int PUBLISH_RESULT_UPLOAD_RESPONSE_ERROR = 1002;

  /// step2: "Video file" upload failed
  static const int PUBLISH_RESULT_UPLOAD_VIDEO_FAILED = 1003;
  /// step2: "Media file" upload failed
  static const int PUBLISH_RESULT_UPLOAD_MEDIA_FAILED = 1003;
  // 这里媒体文件上传code和视频文件上传code失败是一致的

  /// step2: "Cover file" upload failed
  static const int PUBLISH_RESULT_UPLOAD_COVER_FAILED    = 1004;
  /// step3: "Short video/media publishing request" sending failed
  static const int PUBLISH_RESULT_PUBLISH_REQUEST_FAILED = 1005;
  /// step3: "Short video/media publishing request" received error response
  static const int PUBLISH_RESULT_PUBLISH_RESPONSE_ERROR = 1006;

  static const int TVC_ERR_FILE_NOT_EXIST = 1008;  // video path not found
  static const int TVC_ERR_ERR_UGC_PUBLISHING = 1009;  // video uploading
  static const int TVC_ERR_UGC_INVALID_PARAME = 1010;  // invalid param
  static const int TVC_ERR_INVALID_SIGNATURE = 1012;  // short video upload signature is null
  static const int TVC_ERR_INVALID_VIDEOPATH = 1013;  // video path is null
  static const int TVC_ERR_USER_CANCLE = 1017;  // user called cancel function
  static const int TVC_ERR_UPLOAD_SIGN_EXPIRED = 1020;  // signature expire
}

/// Short Video Publishing Result Definition
/// 短视频发布结果定义
class TXPublishResult {
  /// Error Code
  int? retCode;
  /// Error Description Information
  String? descMsg;
  /// Video File Id
  String? videoId;
  /// Video Playback Address
  String? videoURL;
  /// Cover Storage Address
  String? coverURL;

  TXPublishResult(
      this.retCode, this.descMsg, this.videoId, this.videoURL, this.coverURL);
}

/// Media Content Publishing Result Definition
/// 媒体内容发布结果定义
class TXMediaPublishResult {
  /// Error Code
  int? retCode;
  /// Error Description Information
  String? descMsg;
  /// Media File Id
  String? mediaId;
  /// Media Address
  String? mediaURL;

  TXMediaPublishResult(this.retCode, this.descMsg, this.mediaId, this.mediaURL);
}

/// Definition of short video publishing parameters
/// 短视频发布参数定义
class TXPublishParam {
  /// Tencent Cloud Storage COS service key ID, which has been deprecated, does not need to be filled in
  /// 腾讯云存储cos服务密钥ID，已经废弃，不用填写

  /// signature
  String? signature;
  /// Video URL, which supports Uri
  /// 视频地址，支持uri
  String? videoPath;
  /// Video cover
  /// 封面
  String? coverPath;
  /// Whether to enable breakpoint continuation, which is disabled by default
  /// 是否启动断点续传，默认开启
  bool enableResume = true;
  /// Whether to use HTTPS for uploading, which is disabled by default
  /// 上传是否使用https，默认关闭
  bool enableHttps = false;
  /// Video name
  /// 视频名称
  String? fileName;
  /// Whether to enable the pre-upload mechanism, which is enabled by default.
  /// Note: The pre-upload mechanism can significantly improve the upload quality of files.
  /// 是否开启预上传机制，默认开启，备注：预上传机制可以大幅提升文件的上传质量
  bool enablePreparePublish = true;
  /// Slice size, which supports a minimum of 1M and a maximum of 10M, and is defaulted to 0,
  /// representing the file size uploaded divided by 10
  /// 分片大小,支持最小为1M,最大10M，默认0，代表上传文件大小除以10
  int sliceSize = 0;
  /// Maximum number of concurrent slices for upload, which should be less than or equal to 0,
  /// indicating that the SDK defaults to 4 internally
  /// 分片上传最大并发数量，<=0 则表示SDK内部默认为4个
  int concurrentCount = -1; // 分片上传并发数量，<=0 则表示SDK内部默认为2个

  TXPublishParam({
    required this.signature,
    required this.videoPath,
    required this.fileName,
    this.enableResume = true,
    this.enableHttps = false,
    this.coverPath,
    this.enablePreparePublish = true,
    this.sliceSize = 0,
    this.concurrentCount = -1,
  });

  @override
  String toString() {
    return 'TXPublishParam{signature: $signature, videoPath: $videoPath, coverPath: $coverPath, enableResume: $enableResume, enableHttps: $enableHttps, fileName: $fileName, enablePreparePublish: $enablePreparePublish, sliceSize: $sliceSize, concurrentCount: $concurrentCount}';
  }
}

/// Definition of media content publishing parameters
/// 媒体内容发布参数定义
class TXMediaPublishParam {
  /// signature
  String? signature;
  /// Media URL, which supports Uri
  /// 媒体地址，支持uri
  String? mediaPath;
  /// Whether to enable breakpoint continuation, which is disabled by default
  /// 是否启动断点续传，默认开启
  bool enableResume = true;
  /// Whether to use HTTPS for uploading, which is disabled by default
  /// 上传是否使用https，默认关闭
  bool enableHttps = false;
  /// Media name
  /// 媒体名称
  String? fileName;
  /// Whether to enable the pre-upload mechanism, which is enabled by default.
  /// Note: The pre-upload mechanism can significantly improve the upload quality of files.
  /// 是否开启预上传机制，默认开启，备注：预上传机制可以大幅提升文件的上传质量
  bool enablePreparePublish = true;
  /// Slice size, which supports a minimum of 1M and a maximum of 10M, and is defaulted to 0,
  /// representing the file size uploaded divided by 10
  /// 分片大小,支持最小为1M,最大10M，默认0，代表上传文件大小除以10
  int sliceSize = 0;
  /// Maximum number of concurrent slices for upload, which should be less than or equal to 0,
  /// indicating that the SDK defaults to 4 internally
  /// 分片上传最大并发数量，<=0 则表示SDK内部默认为4个
  int concurrentCount = -1;

  TXMediaPublishParam({
    required this.signature,
    required this.mediaPath,
    required this.fileName,
    this.enableResume = true,
    this.enableHttps = false,
    this.enablePreparePublish = true,
    this.sliceSize = 0,
    this.concurrentCount = -1,
  });

  @override
  String toString() {
    return 'TXMediaPublishParam{signature: $signature, mediaPath: $mediaPath, enableResume: $enableResume, enableHttps: $enableHttps, fileName: $fileName, enablePreparePublish: $enablePreparePublish, sliceSize: $sliceSize, concurrentCount: $concurrentCount}';
  }
}

class ReportInfo {
  String? reqType = "";
  String? errCode = "";
  String? cosErrCode = "";
  String? errMsg = "";
  String? reqTime = "";
  String? reqTimeCost = "";
  String? fileSize = "";
  String? fileType = "";
  String? fileName = "";
  String? fileId = "";
  String? appId = "";
  String? reqServerIp = "";

  String? reportId = "";
  String? reqKey = "";
  String? vodSessionKey = "";
  String? cosRegion = "";
  int? vodErrCode = 0;
  int? useHttpDNS = 0;
  int? useCosAcc = 0;
  int? tcpConnTimeCost = 0;
  int? recvRespTimeCost = 0;
  String? requestId = "";
  String? cosVideoPath = "";

  ReportInfo.formJson(Map<String, dynamic> json)
      : reqType = json["reqType"],
        errCode = json["errCode"],
        vodErrCode = json["vodErrCode"],
        cosErrCode = json["cosErrCode"],
        errMsg = json["errMsg"],
        reqTime = json["reqTime"],
        reqTimeCost = json["reqTimeCost"],
        fileSize = json["fileSize"],
        fileType = json["fileType"],
        fileName = json["fileName"],
        fileId = json["fileId"],
        appId = json["appId"],
        reqServerIp = json["reqServerIp"],
        useHttpDNS = json["useHttpDNS"],
        reportId = json["reportId"],
        reqKey = json["reqKey"],
        vodSessionKey = json["vodSessionKey"],
        cosRegion = json["cosRegion"],
        useCosAcc = json["useCosAcc"],
        tcpConnTimeCost = json["tcpConnTimeCost"],
        recvRespTimeCost = json["recvRespTimeCost"],
        requestId = json["requestId"],
        cosVideoPath = json["cosVideoPath"];

  @override
  String toString() {
    return 'ReportInfo{reqType: $reqType, errCode: $errCode, cosErrCode: $cosErrCode, errMsg: $errMsg, reqTime: $reqTime, reqTimeCost: $reqTimeCost, fileSize: $fileSize, fileType: $fileType, fileName: $fileName, fileId: $fileId, appId: $appId, reqServerIp: $reqServerIp, reportId: $reportId, reqKey: $reqKey, vodSessionKey: $vodSessionKey, cosRegion: $cosRegion, vodErrCode: $vodErrCode, useHttpDNS: $useHttpDNS, useCosAcc: $useCosAcc, tcpConnTimeCost: $tcpConnTimeCost, recvRespTimeCost: $recvRespTimeCost, requestId: $requestId, cosVideoPath: $cosVideoPath}';
  }
}

class TVCUploadInfo {
  String? fileType;
  String? filePath;
  int? fileLastModTime;
  String? coverType;
  String? coverPath;
  int? coverLastModTime;
  String? fileName;
  int? videoFileSize = 0;
  int? coverFileSize = 0;
  String? coverName;

  @override
  String toString() {
    return 'TVCUploadInfo{fileType: $fileType, filePath: $filePath, fileLastModTime: $fileLastModTime, coverType: $coverType, coverPath: $coverPath, coverLastModTime: $coverLastModTime, fileName: $fileName, videoFileSize: $videoFileSize, coverFileSize: $coverFileSize, coverName: $coverName}';
  }

  TVCUploadInfo.fromJson(Map<String, dynamic> json)
      : fileType = json["fileType"],
        filePath = json["filePath"],
        fileLastModTime = json["fileLastModTime"],
        coverType = json["coverType"],
        coverPath = json["coverPath"],
        coverLastModTime = json["coverLastModTime"],
        fileName = json["fileName"],
        videoFileSize = json["videoFileSize"],
        coverFileSize = json["coverFileSize"],
        coverName = json["coverName"];
}

class ResumeCacheData {
  String? vodSessionKey = "hello";
  String? uploadId = "world";
  int? fileLastModTime = 1;
  int? coverFileLastModTime = 2;

  Map<String, dynamic> toJson() {
    return {
      'vodSessionKey': vodSessionKey,
      'uploadId': uploadId,
      "fileLastModTime": fileLastModTime,
      "coverFileLastModTime": coverFileLastModTime
    };
  }
}
