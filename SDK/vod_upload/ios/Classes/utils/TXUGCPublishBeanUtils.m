//
// Created by stewiechen on 2023/8/3.
//

#import <objc/runtime.h>
#import "TXUGCPublishBeanUtils.h"

@implementation TXUGCPublishBeanUtils
+ (void)callProtocolMethodWithParameters:(id)object targetProtocol:(Protocol *)targetProtocol methodSelector:(SEL)methodSelector parameters:(NSArray *)parameters {
    if ([object conformsToProtocol:targetProtocol] && [object respondsToSelector:methodSelector]) {
        NSMethodSignature *methodSignature = [object methodSignatureForSelector:methodSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setSelector:methodSelector];
        [invocation setTarget:object];
        for (int i = 0; i < parameters.count; i++) {
            id parameter = parameters[(NSUInteger) i];
            [invocation setArgument:&parameter atIndex:i + 2];
        }
        [invocation invoke];
    }
}

+ (BOOL)arrayContainsString:(NSMutableArray *)array searchString:(NSString *)searchString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF isEqualToString:%@", searchString];
    NSArray *filteredArray = [array filteredArrayUsingPredicate:predicate];
    return (filteredArray.count > 0);
}

+ (BOOL)classConformsToProtocol:(Class)targetClass targetProtocol:(Protocol *)targetProtocol {
    return class_conformsToProtocol(targetClass, targetProtocol);
}

/// 将字典转换键值转换为对象
+ (void)copyProperties:(id)target fromMap:(NSDictionary *)values; {
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([target class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *nsName = [[NSString alloc] initWithUTF8String:name];
        id val = values[nsName];
        if (val == nil) {
            continue;
        }
        // 判断是否为复杂类型且数据是否为字典
        if ([val isKindOfClass:[NSDictionary class]]) {
            val = [self newObjectPropertyInstance:target propertyName:nsName];
            [self copyProperties:val fromMap:values[nsName]];
        }
        [target setValue:val forKey:nsName];
    }
    free(properties);
}

/// 将对象的所有属性转换为字典类型
// TODO: 考虑obj是集合的情况
+ (NSMutableDictionary *)propertiesToMap:(id)obj {
    NSMutableArray *ignoreProperties = [NSMutableArray array];
    if ([TXUGCPublishBeanUtils classConformsToProtocol:[obj class] targetProtocol:@protocol(PropertiesIgnore)]) {
        [TXUGCPublishBeanUtils callProtocolMethodWithParameters:obj targetProtocol:@protocol(PropertiesIgnore) methodSelector:@selector(addIgnoreProperties:) parameters:ignoreProperties];
        // callProtocolMethodWithParameters(obj, @protocol(PropertiesIgnore), @selector(addIgnoreProperties:), ignoreProperties);
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([obj class], &count);

    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString *key = [NSString stringWithUTF8String:propertyName];
        if ([TXUGCPublishBeanUtils arrayContainsString:ignoreProperties searchString:key]) {
            continue;
        }
        id value = [obj valueForKey:key];
        if (value && ![TXUGCPublishBeanUtils isBoxing:value] && ![TXUGCPublishBeanUtils isCollect:value]) {
            // value存在 且不是基本属性的包装类 且不是集合类 -> value是对象
            value = [TXUGCPublishBeanUtils propertiesToMap:value];
            if (value) {
                [dict setObject:value forKey:key];
            }
        } else if ([TXUGCPublishBeanUtils isCollect:value]) {
            // value是集合类
            if ([value isKindOfClass:[NSDictionary class]]) {
                // value是字典类型 - KV结构
                [dict setObject:value forKey:key];
            } else {
                // value是其他集合类型 - Element结构
                NSMutableArray *marr;
                SEL allObjectsMethod = @selector(allObjects);
                if ([value respondsToSelector:allObjectsMethod]) {
                    NSArray *convertArr = [value allObjects];
                    marr = [TXUGCPublishBeanUtils convertCollect:convertArr];
                } else {
                    marr = [TXUGCPublishBeanUtils convertCollect:value];
                }
                if (marr) {
                    [dict setObject:marr forKey:key];
                }
            }
        } else {
            if (value) {
                [dict setObject:value forKey:key];
            }
        }
    }

    free(properties);
    return dict;
}

// TODO: 还应考虑的情况是数组元素是字典类型 需要遍历字典查看类型并处理
+ (NSMutableArray *)convertCollect:(NSArray *)dataSource {
    NSMutableArray *marr = [NSMutableArray array];
    for (id element in dataSource) {
        if (element && ![TXUGCPublishBeanUtils isBoxing:element] && ![TXUGCPublishBeanUtils isCollect:element]) {
            // 数组元素是对象的情况
            NSMutableDictionary *resMap = [TXUGCPublishBeanUtils propertiesToMap:element];
            if (resMap) {
                [marr addObject:resMap];
            }
        } else if ([element isKindOfClass:[NSArray class]] || [element isKindOfClass:[NSSet class]]) {
            // 数组元素是集合类型的时候
            SEL allObjectsMethod = @selector(allObjects);
            if ([element respondsToSelector:allObjectsMethod]) {
                NSArray *el = [element allObjects];
                NSMutableArray *emarr = [TXUGCPublishBeanUtils convertCollect:el];
                if (emarr) {
                    [marr addObject:emarr];
                }
            } else {
                NSMutableArray *emarr = [TXUGCPublishBeanUtils convertCollect:element];
                if (emarr) {
                    [marr addObject:emarr];
                }
            }
        } else {
            // 数组对象是基本类型或者字典类型
            [marr addObject:element];
        }
    }
    return marr;
}

/// 判断对象是否为基本属性的包装类
+ (BOOL)isBoxing:(id)obj {
    if ([obj isKindOfClass:[NSString class]] ||
            [obj isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    return NO;
}

/// 判断对象是否为集合类
+ (BOOL)isCollect:(id)obj {
    if ([obj isKindOfClass:[NSArray class]] ||
            [obj isKindOfClass:[NSDictionary class]] ||
            [obj isKindOfClass:[NSSet class]]) {
        return YES;
    }
    return NO;
}

+ (id)newObjectPropertyInstance:(id)object propertyName:(NSString *)propertyName {
    Class clazz = [TXUGCPublishBeanUtils getClassOfPropertyWithPropertyName:propertyName inObject:object];
    return [[clazz alloc] init];
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
