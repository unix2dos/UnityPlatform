//
//  WXApiManager.h
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import <Foundation/Foundation.h>
#import <string>
#import "WXApi.h"
#import "iOSFunction.h"
#define WXAPPID @"wxc99bd144ac341969"
#define WXAPPSC @"1"
@interface WXApiManager : NSObject<WXApiDelegate> {
    UIView* _view;
    BOOL _show;
    UIToolbar *_toolBar;
    NSString* _filePath;
    NSString* _text;
}

+ (instancetype)sharedManager;
+ (BOOL)isWXAppSupport;
/*微信分享文字*/
+ (void)sendMessageText:(NSString*) text Type:(int)type;
/*微信分享文字和图片*/
+ (void)sendMessageImage:(NSString*) filePath Type:(int)type Thumb:(NSString*) image Text:(NSString*) text ;
/*微信分享链接*/
+ (void)sendMessageUrl:(NSString*) url Type:(int)type Thumb:(NSString*) image Title:(NSString*) title Text:(NSString*) text;
/*初始化一些值*/
- (void)initValue;
/*初始化分享UI*/
- (void)initShareView:(UIView*) view;
/*微信分享展示*/
- (void)showShareView:(BOOL) show;
///*设置分享的文字和图片*/
//- (void)setFilePath:(NSString*) filePath Text:(NSString*) text;
/*微信分享好友*/
- (void)shareSession:(id)sender   ;
/*微信分享朋友圈*/
- (void)shareTimeline:(id)sender  ;
/*图保存到相册*/
- (void)captureImageToPhoto:(NSString*) filePath;
/*图保存到相册的回调*/
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

/*微信登录*/
- (void)setLoginStr:(NSString*)refresh Access:(NSString*) access OpenId:(NSString*) openid;
- (void)WXLogin;
- (void)resetLoginWeChat;
- (bool)loginStep0:(NSString*) access OpenId:(NSString*) openid;
- (void)loginStep1:(NSString*) code;
- (void)loginStep2:(NSString*) refresh Reset:(bool) reset;
- (void)loginStep3:(NSString*) access OpenId:(NSString*) openid;
- (void)loginState:(int)state  Des:(NSDictionary*) des;
- (void)shareState:(int)state  Des:(NSDictionary*) des;
/*微信回调*/
- (void)WXcallBack:(EventType) type State:(int)state  Resp:(NSDictionary*) resp;

@property(nonatomic,retain,readwrite) UIView* view;
@property(nonatomic,retain,readwrite) NSString* filePath,*text,*refresh,*access,*openid;
@property(nonatomic,readwrite) BOOL show;

@end
