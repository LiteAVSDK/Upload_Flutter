//
// Created by stewiechen on 2023/8/3.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import "TXUGCPublishListener.h"

@class TXUGCPublish;
@class TXUGCPublishProgressCallbackData;
@class TXUGCPublishResult;


@interface FTXUGCPublishPlugin : NSObject <FlutterPlugin>
@end

@interface TXUGCPublishCache : NSObject
@property(nonatomic, strong) TXUGCPublish *publisher;
@end

@interface TXPublishListenerImpl : NSObject <TXVideoPublishListener, TXMediaPublishListener>
@property(nonatomic, strong) NSString *taskId;
@property(nonatomic, strong) FlutterMethodChannel *apiChannel;

+ (TXPublishListenerImpl *)newInstance:(NSString *)taskId apiChannel:(FlutterMethodChannel *)apiChannel;
@end
