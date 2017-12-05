//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"
//#import "WeChatIOS.h"
@implementation WXApiManager
@synthesize view = _view;
@synthesize show = _show;
@synthesize filePath = _filePath;
@synthesize text = _text;
@synthesize refresh = _refresh;
@synthesize access = _access;
@synthesize openid = _openid;
#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
        [instance initValue];
    });
    return instance;
}
+ (BOOL)isWXAppSupport
{
   return [WXApi isWXAppInstalled]&&[WXApi isWXAppSupportApi];
}
- (void)dealloc {
    [_filePath  release];
    [_text release];
    [super dealloc];
}
/*初始化一些值*/
- (void)initValue
{
   //初始值
    _filePath = NULL;
    _text = NULL;
}
- (void)initShareView:(UIView*) view
{
    float width = 60;float height = 60;
    /**< 聊天界面    */
    UIBarButtonItem *session = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [button setBackgroundImage:[UIImage imageNamed:@"ui/WeChat_Friend.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(shareSession:) forControlEvents:UIControlEventTouchUpInside];
    session.customView = button;
    /**< 朋友圈      */
    UIBarButtonItem *timeline = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [button2 setBackgroundImage:[UIImage imageNamed:@"ui/WeChat_Circle.png"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(shareTimeline:) forControlEvents:UIControlEventTouchUpInside];
    timeline.customView = button2;
    //toolBar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, view.frame.size.height - width, view.frame.size.width, height)];
    [toolBar setBarStyle:UIBarStyleDefault];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [toolBar setItems:[NSArray arrayWithObjects:session,timeline, nil]];
    [view addSubview:toolBar];
    _toolBar = toolBar;
    //    release
    [button  release];
    [button2 release];
    [session release];
    [timeline release];

    
    //    默认隐藏
    [self setView:view];
    [self showShareView:false];

}
///*设置分享的文字和图片*/
//- (void)setFilePath:(NSString*) filePath Text:(NSString*) text
//{
//    _filePath = filePath;
//    _text = text;
//}
/*微信分享文字*/
+ (void)sendMessageText:(NSString*) text Type:(int)type{
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc]init];
    req.text = text;
    req.bText = true;
    req.scene = type==8 ? WXSceneSession:WXSceneTimeline ;
    [WXApi sendReq:req];
}
/*微信分享文字和图片*/
+ (void)sendMessageImage:(NSString*) filePath Type:(int)type Thumb:(NSString*) image Text:(NSString*) text
{
    WXMediaMessage * message = [WXMediaMessage message];
    WXImageObject * imageObject = [WXImageObject object];
    imageObject.imageData = [NSData dataWithContentsOfFile:filePath];
    message.mediaObject = imageObject;
    if (image)
    {
        UIImage *_image = [UIImage imageNamed:image];
        [message setThumbImage:_image];
    }
    if (text) {
        message.title = text;
        message.description = text;
    }
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = type==8 ? WXSceneSession:WXSceneTimeline ;
    [WXApi sendReq:req];
}
/*微信分享链接*/
+ (void)sendMessageUrl:(NSString*) url Type:(int)type Thumb:(NSString*) image Title:(NSString*) title Text:(NSString*) text
{
    WXWebpageObject *mediaObject = [WXWebpageObject object];
    mediaObject.webpageUrl = url;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = text;
    message.mediaObject = mediaObject;
    if (image)
    {
        UIImage *_image = [UIImage imageNamed:image];
        [message setThumbImage:_image];
    }
    
    SendMessageToWXReq * req = [[SendMessageToWXReq alloc]init];
    req.bText = NO;
    req.message = message;
    req.scene = type==1 ? WXSceneTimeline:WXSceneSession ;
    [WXApi sendReq:req];
}
/*微信分享展示*/
- (void )showShareView:(BOOL) show
{
    [self setShow:show];
    [_toolBar setHidden:!show];
}

/*微信分享好友*/
- (void)shareSession:(id)sender
{
    NSLog(@"/*微信分享好友*/");
    [WXApiManager sendMessageImage:_filePath  Type:1 Thumb:NULL Text:_text];
}
/*微信分享朋友圈*/
- (void)shareTimeline:(id)sender
{
    NSLog(@"/*微信分享朋友圈*/");
    [WXApiManager sendMessageImage:_filePath  Type:0 Thumb:NULL Text: _text];
}
/*截图保存到相册*/
- (void)captureImageToPhoto:(NSString*) filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}



/*微信登录参数*/
- (void)setLoginStr:(NSString*)refresh Access:(NSString*) access OpenId:(NSString*) openid
{
    [self setRefresh:refresh];
    [self setAccess:access];
    [self setOpenid:openid];
}
/*微信登录*/
- (void)WXLogin
{
    //没有登过
    if([self refresh] == NULL||[[self refresh]  isEqual: @"-1"]){
        [self resetLoginWeChat];
        return;
    }
    //access_token没有失效
    if([self loginStep0:[self access]  OpenId:[self openid]])
    {
        [self loginStep3:[self access]  OpenId:[self openid]];
    }else
    {
        //refresh_token 刷新
        [self loginStep2:[self refresh] Reset:true];
    }
}
- (void)resetLoginWeChat
{
    SendAuthReq* req =[[[SendAuthReq alloc ] init ] autorelease ];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"none" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}
- (bool)loginStep0:(NSString*) access OpenId:(NSString*) openid
{
    NSLog(@"WeChat:loginStep00000");
    //    1.设置请求路径
    NSString *urlStr=[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/auth?access_token=%@&openid=%@",access,openid];
    NSURL *url=[NSURL URLWithString:urlStr];
    //    2.创建请求对象
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    //    3.发送请求
    //发送同步请求，在主线程执行
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //（一直在等待服务器返回数据，这行代码会卡住，如果服务器没有返回数据，那么在主线程UI会卡住不能继续执行操作）
    if (data) {//请求成功
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dict);
        if(dict[@"errcode"]==NULL||dict[@"errcode"] == 0){
            return true;
        }
        else
        {
            return false;
        }
        
    }else   //请求失败
    {
        [self loginState:4 Des:NULL];
    }
    return false;
}
- (void)loginStep1:(NSString*) code
{
    NSLog(@"WeChat:loginStep111111");
    
    NSString *urlStr=[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WXAPPID,WXAPPSC, code];
    NSURL *url=[NSURL URLWithString:urlStr];
    //    2.创建请求对象
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    //    3.发送请求
    //发送同步请求，在主线程执行
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //（一直在等待服务器返回数据，这行代码会卡住，如果服务器没有返回数据，那么在主线程UI会卡住不能继续执行操作）
    if (data) {//请求成功
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dict);
        if(dict[@"errcode"]==NULL||dict[@"errcode"] == 0){
            
            NSString * refresh_token = dict[@"refresh_token"];
            NSString * access_token = dict[@"access_token"];
            NSString * openid = dict[@"openid"];
            [self setLoginStr:refresh_token Access:access_token OpenId:openid];
            [self loginStep3:access_token OpenId:openid];
        }
        else
        {
            [self loginState:2 Des:NULL];
        }
    }else   //请求失败
    {
        [self loginState:4 Des:NULL];
    }
}
- (void)loginStep2:(NSString*) refresh Reset:(bool) reset
{
    NSLog(@"WeChat:loginStep22222");
    
    NSString *urlStr=[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",WXAPPID,refresh];
    NSURL *url=[NSURL URLWithString:urlStr];
    //    2.创建请求对象
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    //    3.发送请求
    //发送同步请求，在主线程执行
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //（一直在等待服务器返回数据，这行代码会卡住，如果服务器没有返回数据，那么在主线程UI会卡住不能继续执行操作）
    if (data) {//请求成功
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dict);
        if(dict[@"errcode"]==NULL||dict[@"errcode"] == 0){
            
            NSString * refresh_token = dict[@"refresh_token"];
            NSString * access_token = dict[@"access_token"];
            NSString * openid = dict[@"openid"];
            [self setLoginStr:refresh_token Access:access_token OpenId:openid];
            [self loginStep3:access_token OpenId:openid];
        }
        else
        {
            if(reset){
                [self resetLoginWeChat];
            }
            else{
                [self loginState:2 Des:NULL];
            }
        }
    }else   //请求失败
    {
        [self loginState:4 Des:NULL];
    }
}
- (void)loginStep3:(NSString*) access OpenId:(NSString*) openid
{
    NSLog(@"WeChat:loginStep333333");
    
    NSString *urlStr=[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",access,openid];
    NSURL *url=[NSURL URLWithString:urlStr];
    //    2.创建请求对象
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    //    3.发送请求
    //发送同步请求，在主线程执行
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //（一直在等待服务器返回数据，这行代码会卡住，如果服务器没有返回数据，那么在主线程UI会卡住不能继续执行操作）
    if (data) {//请求成功
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",dict);
        if(dict[@"errcode"]==NULL||dict[@"errcode"] == 0){
            [self loginState:1 Des:dict];
        }
        else
        {
            [self loginState:2 Des:NULL];
        }
    }else   //请求失败
    {
        [self loginState:4 Des:NULL];
    }
}
- (void)loginState:(int)state  Des:(NSDictionary*) des
{
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc]initWithCapacity:6]autorelease];
    if ([self refresh]!=NULL) {
        [dic setValue:[self refresh] forKey:@"refresh_token"];
        [dic setValue:[self access] forKey:@"access_token"];
        [dic setValue:[self openid] forKey:@"openid"];
    }
    if (des!=NULL) {
        [dic setValue:des[@"nickname"] forKey:@"nickname"];
        [dic setValue:des[@"headimgurl"] forKey:@"headimgurl"];
        [dic setValue:des[@"city"] forKey:@"city"];
        [dic setValue:des[@"province"] forKey:@"province"];
        [dic setValue:des[@"country"] forKey:@"country"];
        [dic setValue:des[@"language"] forKey:@"language"];
        [dic setValue:des[@"sex"] forKey:@"sex"];
        [dic setValue:des[@"unionid"] forKey:@"unionid"];
    }
    [self WXcallBack:1 State:state Resp:dic];
}
- (void)shareState:(int)state  Des:(NSDictionary*) des{
    [self WXcallBack:2 State:state Resp:des];
}
/*微信回调*/
- (void)WXcallBack:(int) type State:(int)state  Resp:(NSDictionary*) resp
{
    
    NSMutableDictionary* dic = [[[NSMutableDictionary alloc]initWithCapacity:6]autorelease];
    [dic setValue:@(type)   forKey:@"type"];
    [dic setValue:@(state)   forKey:@"state"];
    if (resp!=NULL) {
        [dic setValue:resp    forKey:@"des"];
    }
    
    NSString *jsonString =  [WXApiManager convertToJSONData:dic];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
//    std::string dicStr = std::string([jsonString UTF8String]);
//    WeChatIOS::WXCallBack(dicStr);
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        switch ([resp errCode]) {
            case WXErrCode::WXSuccess:
                [self shareState:1 Des:NULL];
                break;
            case WXErrCode::WXErrCodeCommon:
            case WXErrCode::WXErrCodeUserCancel:
            case WXErrCode::WXErrCodeSentFail:
            case WXErrCode::WXErrCodeAuthDeny:
            case WXErrCode::WXErrCodeUnsupport:
            default:
                [self shareState:2 Des:NULL];
                break;
        }

    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp* auth = (SendAuthResp*)resp;
        switch ([resp errCode]) {
            case WXErrCode::WXSuccess:
                [self loginStep1:auth.code];
                break;
            case WXErrCode::WXErrCodeCommon:
            case WXErrCode::WXErrCodeUserCancel:
            case WXErrCode::WXErrCodeSentFail:
            case WXErrCode::WXErrCodeAuthDeny:
            case WXErrCode::WXErrCodeUnsupport:
            default:
                [self loginState:2 Des:NULL];
                break;
        }

    } else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]]) {

    }
}

- (void)onReq:(BaseReq *)req {
    if ([req isKindOfClass:[GetMessageFromWXReq class]]) {

    } else if ([req isKindOfClass:[ShowMessageFromWXReq class]]) {

    } else if ([req isKindOfClass:[LaunchFromWXReq class]]) {

    }
}

/*图保存到相册的回调*/
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        NSLog(@"保存到相册失败！");
    }
    else  // No errors
    {
       NSLog(@"保存到相册成功！");
    }
}

/*字符串转换*/
+ (NSString*)convertToJSONData:(id)infoDict
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
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return jsonString;
}
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
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
@end
