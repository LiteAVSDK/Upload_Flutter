//
// Created by stewiechen on 2023/8/7.
//

#import <Foundation/Foundation.h>


@interface TXUGCPublishResult : NSObject
@property(nonatomic, assign) int code;
@property(nonatomic, strong) NSString *msg;
@property(nonatomic, strong) id data;

- (NSString *)toJson;

+ (TXUGCPublishResult *)constructor:(int)code msg:(NSString *)msg;

+ (TXUGCPublishResult *)success:(NSString *)msg data:(id)data;

+ (TXUGCPublishResult *)success:(id)data;

+ (TXUGCPublishResult *)success;

+ (TXUGCPublishResult *)except:(NSString *)msg data:(id)data;

+ (TXUGCPublishResult *)except:(NSString *)msg;

+ (TXUGCPublishResult *)except;
@end
