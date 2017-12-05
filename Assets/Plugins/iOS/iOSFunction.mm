#include <sys/types.h>
#include <sys/sysctl.h>

#include <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "sys/utsname.h"
#import "Reachability.h"
#import "iOSFunction.h"
#import "WXApiManager.h"


// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
    if (string)
        return [NSString stringWithUTF8String: string];
    else
        return [NSString stringWithUTF8String: ""];
}

// Helper method to create C string copy
char* MakeStringCopy (const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}


static id QueryASIdentifierManager()
{
    NSBundle* bundle = [NSBundle bundleWithPath: @"/System/Library/Frameworks/AdSupport.framework"];
    if (bundle)
    {
        [bundle load];
        Class retClass = [bundle classNamed: @"ASIdentifierManager"];
        return [retClass performSelector: @selector(sharedManager)];
    }
    
    return nil;
}



///////////////////////// C# 调用过来的 /////////////////////////
extern "C" {
    //微信相关
    void _weixinlogin()
    {
        [[WXApiManager sharedManager] WXLogin];
    }
    
    
    
    //设备相关
    const char* _AdvertisingIdentifier()
    {
        const char* _ADID = NULL;
        
        // ad id can be reset during app lifetime
        id manager = QueryASIdentifierManager();
        if (manager)
        {
            NSString* adid = [[manager performSelector: @selector(advertisingIdentifier)] UUIDString];
            _ADID = AllocCString(adid);
        }
        
        return _ADID;
    }
    
    const char* _VendorIdentifier()
    {
        return AllocCString([[UIDevice currentDevice].identifierForVendor UUIDString]);
    }
    
    const char* _DeviceName()
    {
        return AllocCString([UIDevice currentDevice].name);
    }
    
    const char* _SystemName()
    {
        return AllocCString([UIDevice currentDevice].systemName);
    }
    
    const char* _SystemVersion()
    {
        return AllocCString([UIDevice currentDevice].systemVersion);
    }
    
    const char* _DeviceModel()
    {
        const char* _DeviceModel = NULL;
        
        size_t size;
        ::sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        
        char* model = (char*)::malloc(size + 1);
        ::sysctlbyname("hw.machine", model, &size, NULL, 0);
        model[size] = 0;
        
        _DeviceModel = AllocCString([NSString stringWithUTF8String: model]);
        ::free(model);
        
        
        return _DeviceModel;
    }
    
    const char* _SystemLanguage()
    {
        const char* _SystemLanguage = NULL;
        
        NSArray* lang = [[NSUserDefaults standardUserDefaults] objectForKey: @"AppleLanguages"];
        if (lang.count > 0)
            _SystemLanguage = AllocCString(lang[0]);
        
        return _SystemLanguage;
    }
    
    const char* _CarrierName()
    {
        CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [info subscriberCellularProvider];
        return AllocCString([[carrier carrierName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    }
    
    const char* _DeviceToken()
    {
        return MakeStringCopy("");
    }
    
    const char* _NetType()
    {
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if(status == NotReachable)
        {
            //No internet
            return MakeStringCopy("none");
        }
        else if (status == ReachableViaWiFi)
        {
            //WiFi
            return MakeStringCopy("Wifi");
        }
        else if (status == ReachableViaWWAN)
        {
            //3G
            return MakeStringCopy("4G");
        }
        
        return MakeStringCopy("unknow");
    }
}
