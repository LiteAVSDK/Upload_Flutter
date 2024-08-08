//
// Created by stewiechen on 2023/8/7.
//

#import "TXUGCPublishResult.h"
#import "TXUGCPublishBeanUtils.h"
#import "TXUGCPublishJsonUtils.h"

@implementation TXUGCPublishResult

static int SUCCESS_CODE = 0;
static int FAIL_CODE = 1;
static NSString *SUCCESS_MSG = @"OK";
static NSString *FAIL_MSG = @"ERROR";
static NSString *NULL_MSG = @"NULL";

- (NSString *)toJson {
    NSMutableDictionary *dict = [TXUGCPublishBeanUtils propertiesToMap:self];
    NSString *json = [TXUGCPublishJsonUtils toJSONStringWithMap:dict];
    return json;
}

+ (TXUGCPublishResult *)constructor:(int)code msg:(NSString *)msg {
    TXUGCPublishResult *result = [[TXUGCPublishResult alloc] init];
    result.code = code;
    result.msg = msg;
    return result;
}

+ (TXUGCPublishResult *)success:(id)data {
    TXUGCPublishResult *result = [[TXUGCPublishResult alloc] init];
    result.code = SUCCESS_CODE;
    result.msg = SUCCESS_MSG;
    result.data = data;
    return result;
}

+ (TXUGCPublishResult *)success:(NSString *)msg data:(id)data {
    TXUGCPublishResult *result = [[TXUGCPublishResult alloc] init];
    result.code = SUCCESS_CODE;
    result.msg = msg;
    result.data = data;
    return result;
}

+ (TXUGCPublishResult *)success {
    TXUGCPublishResult *result = [[TXUGCPublishResult alloc] init];
    result.code = SUCCESS_CODE;
    result.msg = (NSString *) SUCCESS_MSG;
    return result;
}

+ (TXUGCPublishResult *)except:(NSString *)msg {
    TXUGCPublishResult *result = [[TXUGCPublishResult alloc] init];
    result.code = FAIL_CODE;
    result.msg = msg;
    return result;
}

+ (TXUGCPublishResult *)except:(NSString *)msg data:(id)data {
    TXUGCPublishResult *result = [[TXUGCPublishResult alloc] init];
    result.code = FAIL_CODE;
    result.msg = msg;
    result.data = data;
    return result;
}

+ (TXUGCPublishResult *)except {
    TXUGCPublishResult *result = [[TXUGCPublishResult alloc] init];
    result.code = FAIL_CODE;
    result.msg = (NSString *) FAIL_MSG;
    return result;
}
@end