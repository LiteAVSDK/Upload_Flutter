//
// Created by stewiechen on 2023/8/7.
//

#import <Foundation/Foundation.h>


@interface TXUGCPublishProgressCallbackData : NSObject
@property NSString *taskId;
@property NSInteger progress;
@property NSInteger uploadBytes;
@property NSInteger totalBytes;
@property BOOL isComplete;
@property id detail;
@end
