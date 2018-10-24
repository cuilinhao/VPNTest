//
//  ShareCommand.m
//  VPNBrowser
//
//  Created by 冯鸿杰 on 2017/10/18.
//  Copyright © 2017年 vimfung. All rights reserved.
//

#import "ShareCommand.h"

@interface ShareCommand ()


/**
 平台类型
 */
@property (nonatomic) SSDKPlatformType platformType;

@end

@implementation ShareCommand

- (instancetype)initWithPlatformType:(SSDKPlatformType)platformType
{
    if (self = [super init])
    {
        self.platformType = platformType;
    }
    return self;
}

- (void)execute:(void (^) (SSDKResponseState state, NSError *error))handler
{
    NSString *shareText = @"About to get inside a wilder world,CY Browser free download https://itunes.apple.com/cn/app/vpn-browser/id1071217745?mt=8";
    NSString *noRCCodeShareImagePath = [[NSBundle mainBundle] pathForResource:@"ShareImage_NoRCCode" ofType:@"jpg"];
    NSString *shareImagePath = [[NSBundle mainBundle] pathForResource:@"ShareImage" ofType:@"png"];
    
    NSMutableDictionary *shareContent = [NSMutableDictionary dictionary];
    [shareContent SSDKSetupMailParamsByText:shareText
                                      title:nil
                                     images:noRCCodeShareImagePath
                                attachments:nil
                                 recipients:nil
                               ccRecipients:nil
                              bccRecipients:nil
                                       type:SSDKContentTypeImage];
    [shareContent SSDKSetupFacebookParamsByText:shareText
                                          image:noRCCodeShareImagePath
                                           type:SSDKContentTypeImage];
    [shareContent SSDKSetupWeChatParamsByText:nil
                                        title:nil
                                          url:nil
                                   thumbImage:nil
                                        image:shareImagePath
                                 musicFileURL:nil
                                      extInfo:nil
                                     fileData:nil
                                 emoticonData:nil
                                         type:SSDKContentTypeImage
                           forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    [shareContent SSDKSetupWeChatParamsByText:nil
                                        title:nil
                                          url:nil
                                   thumbImage:nil
                                        image:shareImagePath
                                 musicFileURL:nil
                                      extInfo:nil
                                     fileData:nil
                                 emoticonData:nil
                                         type:SSDKContentTypeImage
                           forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
    
    [ShareSDK share:self.platformType
         parameters:shareContent
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         
         if (handler)
         {
             handler (state, error);
         }
         
     }];
}

@end
