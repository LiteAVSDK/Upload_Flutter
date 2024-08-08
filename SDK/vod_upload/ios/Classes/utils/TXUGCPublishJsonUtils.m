//
// Created by stewiechen on 2023/8/3.
//

#import "TXUGCPublishJsonUtils.h"
#import "TXUGCPublishBeanUtils.h"
#import <objc/runtime.h>

@implementation TXUGCPublishJsonUtils
/// 根据Class解析JSON为对象
+ (id)parseJSONString:(NSString *)json withClass:(Class)clazz {
    id parse = [TXUGCPublishJsonUtils parseJSONStringToMapOrArray:json];
    id obj = [[clazz alloc] init];
    if ([parse isKindOfClass:[NSDictionary class]]) {
        for (NSString *jsonProperty in parse) {
            if ([TXUGCPublishJsonUtils hasProperty:clazz withPropertyName:jsonProperty]) {
                if ([parse[jsonProperty] isKindOfClass:[NSDictionary class]] &&
                        ![[obj valueForKey:jsonProperty] isKindOfClass:[NSDictionary class]]) {
                    // 如果解析到的当前key为一个字典 且原属性并不是字典类型
                    [TXUGCPublishBeanUtils copyProperties:[obj valueForKey:jsonProperty] fromMap:parse[jsonProperty]];
                } else if ([parse[jsonProperty] isKindOfClass:[NSString class]] &&
                        [TXUGCPublishJsonUtils getClassOfPropertyWithPropertyName:jsonProperty inObject:obj] != [NSString class]) {
                    // 如果解析到的当前key为一个字符串 且原属性并不是字符串
                    // 类似于: {"key": "{"name": "stewie"}"}
                    Class propertyClass = [TXUGCPublishJsonUtils getClassOfPropertyWithPropertyName:jsonProperty inObject:obj];
                    [obj setValue:[TXUGCPublishJsonUtils parseJSONString:parse[jsonProperty] withClass:propertyClass] forKey:jsonProperty];
                } else {
                    [obj setValue:parse[jsonProperty] forKey:jsonProperty];
                }
            } else {
                NSLog(@"JSON WARN: Property Not Found");
                continue;
            }
        }
        return obj;
    } else if ([parse isKindOfClass:[NSArray class]] &&
            [obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *tmp = [obj mutableCopy];
        for (id jsonElement in parse) {
            if ([jsonElement isKindOfClass:[NSDictionary class]]) {
                // TODO: 数组元素是对象的情况
            } else if ([jsonElement isKindOfClass:[NSArray class]]) {
                // TODO: 数组元素是数组的情况
            } else if ([jsonElement isKindOfClass:[NSString class]] ||
                    [jsonElement isKindOfClass:[NSNumber class]]) {
                // TODO: 数组元素是基本类型的情况
                [tmp addObject:jsonElement];
            } else {
                // [tmp addObject:jsonElement];
            }
        }
        return nil;
    }
    return nil;
}

/// 解析JSON为字典或数组
+ (id)parseJSONStringToMapOrArray:(NSString *)json {
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error) {
        NSLog(@"JSON ERROR: %@", error);
        return nil;
    } else {
        if ([jsonObject isKindOfClass:[NSDictionary class]] || [jsonObject isKindOfClass:[NSArray class]]) {
            return jsonObject;
        } else {
            NSLog(@"JSON ERROR: Parse Result Not Dictionary Or Array");
            return nil;
        }
    }
}

/// 将对象转换为JSON
+ (NSString *)toJSONString:(NSData *)obj {
    NSMutableDictionary *propertiesMap = [TXUGCPublishBeanUtils propertiesToMap:obj];
    return [TXUGCPublishJsonUtils toJSONStringWithMap:propertiesMap];
}

/// 将字典转换为JSON
+ (NSString *)toJSONStringWithMap:(NSMutableDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"JSON ERROR: %@", error);
        return nil;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

/// 判断类是否含有对应属性
+ (BOOL)hasProperty:(Class)clazz withPropertyName:(NSString *)propertyName {
    objc_property_t property = class_getProperty(clazz, propertyName.UTF8String);
    return (property != NULL);
}

/// 获取对应属性的Class - 可能存在问题
+ (Class)getClassOfPropertyWithPropertyName:(NSString *)propertyName inObject:(id)object {
    if (object == nil) {
        return nil;
    }
    id value = [object valueForKey:propertyName];
    if (value != nil) {
        // 如果对象对应属性有值 则直接返回其Class对象
        return [value class];
    }
    objc_property_t property = class_getProperty([object class], [propertyName UTF8String]);
    if (property == NULL) {
        return nil;
    }
    const char *typeEncoding = property_getAttributes(property);
    NSString *typeString = [NSString stringWithUTF8String:typeEncoding];
    if ([typeString hasPrefix:@"T@"]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\"(.*?)\"" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [regex matchesInString:typeString options:0 range:NSMakeRange(0, typeString.length)];
        if ([matches count] > 0) {
            NSRange matchRange = [matches[0] range];
            NSString *matchedString = [typeString substringWithRange:matchRange];
            NSUInteger length = matchedString.length - 2;
            NSRange range = NSMakeRange(1, length);
            NSString *className = [matchedString substringWithRange:range];
            return NSClassFromString(className);
        }
    }
    return nil;
}
@end
