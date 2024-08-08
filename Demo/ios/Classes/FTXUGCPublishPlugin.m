//
// Created by stewiechen on 2023/8/3.
//

#import "FTXUGCPublishPlugin.h"
#import "TXUGCPublish.h"
#import "utils/TXUGCPublishBeanUtils.h"
#import "UploadResumeDefaultController.h"
#import "TXUGCPublishProgressCallbackData.h"
#import "TXUGCPublishResult.h"
#import "TXUGCPublishOptCenter.h"
#import "TXUGCUploadResumeFlutterController.h"
#import "TVCLog.h"

const NSString *PUBLISH_VIDEO = @"publishVideo";
const NSString *CANCEL_UPLOAD_VIDEO = @"cancelUploadVideo";
const NSString *PAUSE_UPLOAD_VIDEO = @"pauseUploadVideo";
const NSString *RESUME_UPLOAD_VIDEO = @"resumeUploadVideo";
const NSString *PUBLISH_MEDIA = @"publishMedia";
const NSString *CANCEL_UPLOAD_MEDIA = @"cancelUploadMedia";
const NSString *PAUSE_UPLOAD_MEDIA = @"pauseUploadMedia";
const NSString *RESUME_UPLOAD_MEDIA = @"resumeUploadMedia";
const NSString *PREPARE_UPLOAD = @"prepareUpload";
const NSString *GET_STATUS_INFO = @"getStatusInfo";
const NSString *SET_APPID = @"setAppId";
const NSString *SET_IS_DEBUG = @"setIsDebug";
const NSString *ON_PUBLISH_PROGRESS = @"onPublishProgress";
const NSString *ON_PUBLISH_COMPLETE = @"onPublishComplete";
const NSString *ON_MEDIA_PUBLISH_PROGRESS = @"onMediaPublishProgress";
const NSString *ON_MEDIA_PUBLISH_COMPLETE = @"onMediaPublishComplete";

@implementation FTXUGCPublishPlugin {
    NSDictionary *_methods;
    NSMutableDictionary *_publishCache;
}

static NSString *PUBLISH_METHOD_CHANNEL_PATH = @"cloud.tencent.com/txvodplayer/videoUpload";

static FlutterMethodChannel *METHOD_CHANNEL;
static NSObject <FlutterPluginRegistrar> *FLUTTER_REGISTER;

+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FLUTTER_REGISTER = registrar;
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:PUBLISH_METHOD_CHANNEL_PATH
                  binaryMessenger:[registrar messenger]];
    FTXUGCPublishPlugin *instance = [[FTXUGCPublishPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [registrar publish:instance];
    METHOD_CHANNEL = channel;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _methods = @{
                PUBLISH_VIDEO: @1,
                CANCEL_UPLOAD_VIDEO: @2,
                PAUSE_UPLOAD_VIDEO: @3,
                RESUME_UPLOAD_VIDEO: @4,
                PUBLISH_MEDIA: @5,
                CANCEL_UPLOAD_MEDIA: @6,
                PAUSE_UPLOAD_MEDIA: @7,
                RESUME_UPLOAD_MEDIA: @8,
                PREPARE_UPLOAD: @9,
                GET_STATUS_INFO: @10,
                SET_APPID: @11,
                SET_IS_DEBUG: @12,
        };
        _publishCache = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSNumber *method = _methods[call.method];
    VodLogDebug(@"%@", call.method);
    if (method == nil) {
        VodLogDebug(@"Method Not Found");
        result([FlutterError errorWithCode:@"-1" message:@"Method Not Found" details:@""]);
        return;
    }

    TXPublishParam *publishParam = [[TXPublishParam alloc] init];
    TXMediaPublishParam *mediaPublishParam = [[TXMediaPublishParam alloc] init];
    NSString *taskId = call.arguments[@"id"];
    switch ([method intValue]) {
        case 1: {
            [TXUGCPublishBeanUtils copyProperties:publishParam fromMap:call.arguments];
            BOOL enableHttps = [call.arguments[@"enableHttps"] boolValue];
            publishParam.enableHTTPS = enableHttps;
            if (![call.arguments[@"coverPath"] isKindOfClass:[NSString class]]) {
                publishParam.coverPath = @"";
            }
            NSNumber *resCode = [self publishVideo:taskId param:publishParam];
            TXUGCPublishResult *template = [TXUGCPublishResult constructor:[resCode intValue] msg:@"OK"];
            result([template toJson]);
        }
            break;
        case 2:
            if (!taskId) {
                 result([FlutterError errorWithCode:@"-1" message:@"id is empty" details:@""]);
            }
            [self cancelPublishVideo:taskId];
            result(@"");
            break;
        case 3:
            if (!taskId) {
                 result([FlutterError errorWithCode:@"-1" message:@"id is empty" details:@""]);
            }
            [self pausePublishVideo:taskId];
            result(@"");
            break;
        case 4:{
            [TXUGCPublishBeanUtils copyProperties:publishParam fromMap:call.arguments];
            BOOL enableHttps = [call.arguments[@"enableHttps"] boolValue];
            publishParam.enableHTTPS = enableHttps;
            if (![call.arguments[@"coverPath"] isKindOfClass:[NSString class]]) {
                publishParam.coverPath = @"";
            }
            [self resumeUploadVideo:taskId param:publishParam];
            result(@"");
        }
            break;
        case 5: {
            [TXUGCPublishBeanUtils copyProperties:mediaPublishParam fromMap:call.arguments];
            BOOL enableHttps = [call.arguments[@"enableHttps"] boolValue];
            mediaPublishParam.enableHTTPS = enableHttps;
            NSNumber *resCode = [self publishMedia:taskId param:mediaPublishParam];
            TXUGCPublishResult *template = [TXUGCPublishResult constructor:[resCode intValue] msg:@"OK"];
            result([template toJson]);
        }
            break;
        case 6:
            [self cancelPublishMedia:taskId];
            result(@"");
            break;
        case 7:
            [self pausePublishMedia:taskId];
            result(@"");
            break;
        case 8: {
            [TXUGCPublishBeanUtils copyProperties:mediaPublishParam fromMap:call.arguments];
            BOOL enableHttps = [call.arguments[@"enableHttps"] boolValue];
            mediaPublishParam.enableHTTPS = enableHttps;
            [self resumeUploadMedia:taskId param:mediaPublishParam];
            result(@"");
        }
            break;
        case 9: {
            NSString *sign = call.arguments[@"signature"];
            [self prepareUpload:sign result:result];
            result(@"");
        }
            break;
        case 10: {
            NSDictionary *statusInfo = [self getStatusInfo:taskId];
            TXUGCPublishResult *template = [TXUGCPublishResult success];
            template.data = statusInfo;
            result([template toJson]);
        }
            break;
        case 11: {
            NSNumber *appId = call.arguments[@"appId"];
            [self setAppId:taskId appId:appId];
            result(@"");
        }
            break;
        case 12: {
            BOOL isDebug = [call.arguments[@"isDebug"] boolValue];
            [self setIsDebug:taskId isDebug:isDebug];
            result(@"");
        }
            break;
    }
}

- (NSNumber *)publishVideo:(NSString *)taskId param:(TXPublishParam *)param {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) {
        TXPublishListenerImpl *tmp = [TXPublishListenerImpl newInstance:taskId apiChannel:METHOD_CHANNEL];
        id <TXVideoPublishListener> videoListener = (id <TXVideoPublishListener>) tmp;
        cache = [self createCache:taskId videoListener:videoListener];
        cache.publisher.delegate = videoListener;
    }

    TXPublishParam *publishParam = [[TXPublishParam alloc] init];
    publishParam.signature = param.signature;
    publishParam.coverPath = param.coverPath;
    publishParam.videoPath = param.videoPath;
    publishParam.enableHTTPS = param.enableHTTPS;
    publishParam.concurrentCount = param.concurrentCount;
    publishParam.enablePreparePublish = param.enablePreparePublish;
    publishParam.sliceSize = param.sliceSize;
    publishParam.coverPath = param.coverPath;
    publishParam.enableResume = param.enableResume;
    if (param.isDefaultResumeController) {
        publishParam.uploadResumController = [[UploadResumeDefaultController alloc] init];
    } else {
        publishParam.uploadResumController = [TXUGCUploadResumeFlutterController newInstanceWithMethodChannel:METHOD_CHANNEL];
    }
    return [NSNumber numberWithInt:[cache.publisher publishVideo:publishParam]];
}

- (BOOL)cancelPublishVideo:(NSString *)taskId {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) return NO;
    return [cache.publisher canclePublish];
}

- (BOOL)pausePublishVideo:(NSString *)taskId {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) return NO;
    return [cache.publisher canclePublish];
}

- (NSNumber *)resumeUploadVideo:(NSString *)taskId param:(TXPublishParam *)param {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) return @1;
    TXPublishParam *publishParam = [[TXPublishParam alloc] init];
    publishParam.signature = param.signature;
    publishParam.coverPath = param.coverPath;
    publishParam.videoPath = param.videoPath;
    publishParam.enableHTTPS = param.enableHTTPS;
    publishParam.concurrentCount = param.concurrentCount;
    publishParam.enablePreparePublish = param.enablePreparePublish;
    publishParam.sliceSize = param.sliceSize;
    publishParam.coverPath = param.coverPath;
    publishParam.enableResume = param.enableResume;
    if (param.isDefaultResumeController) {
        publishParam.uploadResumController = [[UploadResumeDefaultController alloc] init];
    } else {
        publishParam.uploadResumController = [TXUGCUploadResumeFlutterController newInstanceWithMethodChannel:METHOD_CHANNEL];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cache.publisher publishVideo:publishParam];
    });
    return @0;
}

- (NSNumber *)publishMedia:(NSString *)taskId param:(TXMediaPublishParam *)param {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) {
        TXPublishListenerImpl *tmp = [TXPublishListenerImpl newInstance:taskId apiChannel:METHOD_CHANNEL];
        id <TXMediaPublishListener> mediaListener = (id <TXMediaPublishListener>) tmp;
        cache = [self createCache:taskId mediaListener:mediaListener];
    }

    TXMediaPublishParam *publishParam = [[TXMediaPublishParam alloc] init];
    publishParam.signature = param.signature;
    publishParam.fileName = param.fileName;
    publishParam.mediaPath = param.mediaPath;
    publishParam.enableHTTPS = param.enableHTTPS;
    publishParam.concurrentCount = param.concurrentCount;
    publishParam.enablePreparePublish = param.enablePreparePublish;
    publishParam.sliceSize = param.sliceSize;
    publishParam.enableResume = param.enableResume;
    if (param.isDefaultResumeController) {
        publishParam.uploadResumController = [[UploadResumeDefaultController alloc] init];
    } else {
        publishParam.uploadResumController = [TXUGCUploadResumeFlutterController newInstanceWithMethodChannel:METHOD_CHANNEL];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cache.publisher publishMedia:publishParam];
    });
    return @0;
}

- (BOOL)cancelPublishMedia:(NSString *)taskId {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) return NO;
    return [cache.publisher canclePublish];
}

- (BOOL)pausePublishMedia:(NSString *)taskId {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) return NO;
    return [cache.publisher canclePublish];
}

- (NSNumber *)resumeUploadMedia:(NSString *)taskId param:(TXMediaPublishParam *)param {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) return @1;

    TXMediaPublishParam *publishParam = [[TXMediaPublishParam alloc] init];
    publishParam.signature = param.signature;
    publishParam.fileName = param.fileName;
    publishParam.mediaPath = param.mediaPath;
    publishParam.enableHTTPS = param.enableHTTPS;
    publishParam.concurrentCount = param.concurrentCount;
    publishParam.enablePreparePublish = param.enablePreparePublish;
    publishParam.sliceSize = param.sliceSize;
    publishParam.enableResume = param.enableResume;
    if (param.isDefaultResumeController) {
        publishParam.uploadResumController = [[UploadResumeDefaultController alloc] init];
    } else {
        publishParam.uploadResumController = [TXUGCUploadResumeFlutterController newInstanceWithMethodChannel:METHOD_CHANNEL];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cache.publisher publishMedia:publishParam];
    });
    return @0;
}

- (void)prepareUpload:(NSString *)signature result:(FlutterResult)result {
    [[TXUGCPublishOptCenter shareInstance] prepareUpload:signature prepareUploadComplete:^(void) {
        TXUGCPublishResult *template = [TXUGCPublishResult success];
        result([template toJson]);
    }];
}

- (NSMutableDictionary *)getStatusInfo:(NSString *)taskId {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) return [NSMutableDictionary dictionary];
    NSDictionary *statusInfo = [cache.publisher getStatusInfoV2];
    return [NSMutableDictionary dictionaryWithDictionary:statusInfo];
}

- (void)setAppId:(NSString *)taskId appId:(NSNumber *)appId {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) return;
    [cache.publisher setAppId:[appId intValue]];
}

- (void)setIsDebug:(NSString *)taskId isDebug:(BOOL)isDebug {
    TXUGCPublishCache *cache = _publishCache[taskId];
    if (cache == nil) return;
    [cache.publisher setIsDebug:isDebug];
}

- (TXUGCPublishCache *)createCache:(NSString *)taskId videoListener:(id <TXVideoPublishListener>)videoListener {
    TXUGCPublishCache *cache = [self createCache:taskId];
    cache.publisher.delegate = videoListener;
    return cache;
}

- (TXUGCPublishCache *)createCache:(NSString *)taskId mediaListener:(id <TXMediaPublishListener>)mediaListener {
    TXUGCPublishCache *cache = [self createCache:taskId];
    cache.publisher.mediaDelegate = mediaListener;
    return cache;
}

- (TXUGCPublishCache *)createCache:(NSString *)taskId {
    TXUGCPublishCache *cache = [[TXUGCPublishCache alloc] init];
    _publishCache[taskId] = cache;
    TXUGCPublish *publisher = [[TXUGCPublish alloc] initWithUserID:@"independence_ios"];
    cache.publisher = publisher;
    return cache;
}
@end

@implementation TXUGCPublishCache
@end

@implementation TXPublishListenerImpl
+ (TXPublishListenerImpl *)newInstance:(NSString *)taskId apiChannel:(FlutterMethodChannel *)apiChannel {
    TXPublishListenerImpl *instance = [[TXPublishListenerImpl alloc] init];
    instance.taskId = taskId;
    instance.apiChannel = apiChannel;
    return instance;
}

- (void)onProgress:(NSInteger)uploadBytes totalBytes:(NSInteger)totalBytes method:(NSString *)method {
    TXUGCPublishProgressCallbackData *callbackData = [[TXUGCPublishProgressCallbackData alloc] init];
    NSInteger progress = (int) (100 * uploadBytes / totalBytes);
    callbackData.taskId = self.taskId;
    callbackData.progress = progress;
    callbackData.totalBytes = totalBytes;
    callbackData.uploadBytes = uploadBytes;
    callbackData.isComplete = NO;
    TXUGCPublishResult *template = [TXUGCPublishResult success:callbackData];
    NSString *json = [template toJson];
    NSDictionary *args = @{
            @"id": self.taskId,
            @"callback": json
    };
    [self.apiChannel invokeMethod:method arguments:args];
}

- (void)onComplete:(id)result method:(NSString *)method {
    TXUGCPublishProgressCallbackData *callbackData = [[TXUGCPublishProgressCallbackData alloc] init];
    callbackData.taskId = self.taskId;
    callbackData.progress = 100;
    callbackData.totalBytes = 0;
    callbackData.uploadBytes = 0;
    callbackData.isComplete = YES;
    callbackData.detail = result;
    TXUGCPublishResult *template = [TXUGCPublishResult success:callbackData];
    NSString *json = [template toJson];
    NSDictionary *args = @{
            @"id": self.taskId,
            @"callback": json
    };
    [self.apiChannel invokeMethod:method arguments:args];
}

- (void)onPublishProgress:(NSInteger)uploadBytes totalBytes:(NSInteger)totalBytes {
    [self onProgress:uploadBytes totalBytes:totalBytes method:ON_PUBLISH_PROGRESS];
}

- (void)onPublishComplete:(TXPublishResult *)result {
    [self onComplete:result method:ON_PUBLISH_COMPLETE];
}

- (void)onMediaPublishProgress:(NSInteger)uploadBytes totalBytes:(NSInteger)totalBytes {
    [self onProgress:uploadBytes totalBytes:totalBytes method:ON_MEDIA_PUBLISH_PROGRESS];
}

- (void)onMediaPublishComplete:(TXMediaPublishResult *)result {
    [self onComplete:result method:ON_MEDIA_PUBLISH_COMPLETE];
}
@end
