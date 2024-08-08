//
// Created by stewiechen on 2023/8/10.
//

#import <Flutter/Flutter.h>
#import "TXUGCUploadResumeFlutterController.h"
#import "TXUGCPublishJsonUtils.h"


@implementation TXUGCUploadResumeFlutterController
static NSString *SAVE_SESSION = @"saveSession";
static NSString *GET_RESUME_DATA = @"getResumeData";
static NSString *CLEAR_LOCAL_CACHE = @"clearLocalCache";
static NSString *IS_RESUME_UPLOAD_VIDEO = @"isResumeUploadVideo";

+ (TXUGCUploadResumeFlutterController *)newInstanceWithMethodChannel:(FlutterMethodChannel *)methodChannel {
    TXUGCUploadResumeFlutterController *controller = [[TXUGCUploadResumeFlutterController alloc] init];
    controller.methodChannel = methodChannel;
    return controller;
}

- (void)saveSession:(NSString *)filePath withSessionKey:(NSString *)vodSessionKey withResumeData:(NSData *)resumeData withUploadInfo:(TVCUploadContext *)uploadContext {
    TVCUploadInfo *info = [self convertContext:uploadContext];
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    id infoJson = [TXUGCPublishJsonUtils toJSONString:info];
    args[@"uploadInfo"] = infoJson;
    args[@"vodSessionKey"] = vodSessionKey;
    args[@"filePath"] = filePath;
    args[@"resumeData"] = resumeData;
    [self.methodChannel invokeMethod:SAVE_SESSION arguments:args];
}

- (void)clearLocalCache {
    [self.methodChannel invokeMethod:CLEAR_LOCAL_CACHE arguments:nil];
}

- (ResumeCacheData *)getResumeData:(NSString *)filePath {
    __block ResumeCacheData *resumeCacheData;
    NSDictionary *args = @{@"filePath": filePath};
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.methodChannel invokeMethod:GET_RESUME_DATA arguments:args result:(FlutterResult) ^(id result) {
        NSString *data = result[@"data"];
        resumeCacheData = [TXUGCPublishJsonUtils parseJSONString:data withClass:[ResumeCacheData class]];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return resumeCacheData;
}

- (BOOL)isResumeUploadVideo:(TVCUploadContext *)uploadContext withSessionKey:(NSString *)vodSessionKey withFileModTime:(uint64_t)videoLastModTime withCoverModTime:(uint64_t)coverLastModTime {
    __block BOOL res;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.methodChannel invokeMethod:IS_RESUME_UPLOAD_VIDEO arguments:nil result:(FlutterResult) ^(id result) {
        res = result[@"data"];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return res;
}

- (TVCUploadInfo *)convertContext:(TVCUploadContext *)uploadContext {
    TVCUploadInfo *info = [TVCUploadInfo new];
    info.fileName = uploadContext.uploadParam.videoName;
    info.filePath = uploadContext.uploadParam.videoPath;
    info.coverName = uploadContext.uploadParam.coverPath;
    info.coverPath = uploadContext.uploadParam.coverPath;
    info.fileLastModTime = (long) uploadContext.videoLastModTime;
    info.coverLastModTime = (long) uploadContext.coverLastModTime;
    info.videoFileSize = (long) uploadContext.videoSize;
    info.coverFileSize = (long) uploadContext.coverSize;
    info.fileType = [self getFileType:uploadContext.uploadParam.videoPath];
    info.coverType = [self getFileType:uploadContext.uploadParam.coverPath];
    return info;
}

- (NSString *)getFileType:(NSString *)filePath {
    return [filePath pathExtension];
}
@end

@implementation TVCUploadInfo
@end
