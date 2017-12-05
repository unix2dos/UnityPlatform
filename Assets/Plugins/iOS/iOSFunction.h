//
//  iOSFunction.h
//  Unity-iPhone
//
//  Created by liuwei on 2017/12/5.
//

#ifndef iOSFunction_h
#define iOSFunction_h
#include <string>
#include "UnityInterface.h"


enum class EventType
{
    WX_LOGIN = 10000,
    WX_SHARE = 10001,
};

class iOSFunction
{
public:
    static void sendCSharpMsg(EventType type, NSMutableDictionary* dict)
    {
        [dict setValue:@((int)type)   forKey:@"type"];
        NSString *jsonString = convertToJSONData(dict);
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        UnitySendMessage("DontDestroy", "iOSCallCSharp", [jsonString UTF8String]);
    }
    
    
    /*字符串转换*/
    static NSString* convertToJSONData(NSDictionary* infoDict)
    {
        // Pass 0 if you don't care about the readability of the generated string
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = @"";
        if (! jsonData)
        {
            NSLog(@"Got an error: %@", error);
        }else
        {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];//去除掉首尾的空白字符和换行字符
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        return jsonString;
    }
    
    
    static NSDictionary* dictionaryWithJsonString(NSString * jsonString)
    {
        if (jsonString == nil) {
            return nil;
        }
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        if(err)
        {
            NSLog(@"json解析失败：%@",err);
            return nil;
        }
        return dic;
    }
};




#endif /* iOSFunction_h */
