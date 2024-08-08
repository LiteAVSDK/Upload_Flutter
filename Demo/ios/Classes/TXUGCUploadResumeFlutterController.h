//
// Created by stewiechen on 2023/8/10.
//

#import <Foundation/Foundation.h>
#import "IUploadResumeController.h"


@interface TXUGCUploadResumeFlutterController : NSObject <IUploadResumeController>
+(TXUGCUploadResumeFlutterController *)newInstanceWithMethodChannel:(FlutterMethodChannel *)methodChannel;
@property(nonatomic, strong) FlutterMethodChannel *methodChannel;
@end

@interface TVCUploadInfo : NSObject
@property(nonatomic, strong) NSString *fileType;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic, assign) long fileLastModTime;
@property(nonatomic, strong) NSString *coverType;
@property(nonatomic, strong) NSString *coverPath;
@property(nonatomic, assign) long coverLastModTime;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, assign) long videoFileSize;
@property(nonatomic, assign) long coverFileSize;
@property(nonatomic, strong) NSString *coverName;
@end
