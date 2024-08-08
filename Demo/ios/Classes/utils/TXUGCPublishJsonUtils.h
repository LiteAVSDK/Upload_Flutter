//
// Created by stewiechen on 2023/8/3.
//

#import <Foundation/Foundation.h>


@interface TXUGCPublishJsonUtils : NSObject
+ (id)parseJSONString:(NSString *)json withClass:(Class)obj;

+ (NSString *)toJSONString:(id)obj;

+ (NSString *)toJSONStringWithMap:(NSMutableDictionary *)dict;
@end
