//
// Created by 陈桐 on 2023/8/3.
//

#import <Foundation/Foundation.h>


@interface TXUGCPublishBeanUtils : NSObject
+ (void)copyProperties:(id)target fromMap:(NSDictionary *)values;

+ (NSMutableDictionary *)propertiesToMap:(id)obj;
@end

@protocol PropertiesIgnore <NSObject>
- (void)addIgnoreProperties:(NSMutableArray *)ignoreProperties;
@end
