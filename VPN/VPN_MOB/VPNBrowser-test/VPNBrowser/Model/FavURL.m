//
//  FavURL.m
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "FavURL.h"
#import <MOBFoundation/MOBFoundation.h>

@interface FavURL ()

@end

@implementation FavURL

- (MOBFImageObserver *)getIcon:(void (^)(UIImage *iconImage))handler
{
    /**
     网页图标映射表
     */
    static NSDictionary<NSString *, NSString *> *_websiteIcons = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _websiteIcons = @{
                          @"^(\\w+[.])?facebook.com" : @"facebook",
                          @"^(\\w+[.])?bing.com" : @"bing",
                          @"^(\\w+[.])?dropbox.com" : @"dropbox",
                          @"^(\\w+[.])?google.com" : @"google",
                          @"^(\\w+[.])?linkedin.com" : @"linkedin",
                          @"^(\\w+[.])?paypal.com" : @"paypal",
                          @"^(\\w+[.])?pinterest.com" : @"pinterest",
                          @"^(\\w+[.])?tumblr.com" : @"tumblr",
                          @"^(\\w+[.])?twitter.com" : @"twitter",
                          @"^(\\w+[.])?wikipedia.(org|com)" : @"wikipedia",
                          @"^(\\w+[.])?yahoo.com" : @"yahoo",
                          @"^(\\w+[.])?youtube.com" : @"youtube",
                          };
        
    });
    
    NSURL *webURL = [NSURL URLWithString:self.url];
    if (webURL)
    {
        __block NSString *localIcon = nil;
        [_websiteIcons enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            
            if ([MOBFRegex isMatchedByRegex:key
                                    options:MOBFRegexOptionsCaseless
                                    inRange:NSMakeRange(0, webURL.host.length)
                                 withString:webURL.host])
            {
                localIcon = obj;
                *stop = YES;
            }
            
        }];
        
        if (localIcon)
        {
            if (handler)
            {
                handler ([UIImage imageNamed:localIcon]);
            }
            
            return nil;
        }
        else
        {
            return [[MOBFImageGetter sharedInstance] getImageWithURL:[NSURL URLWithString:self.icon] result:^(UIImage *image, NSError *error) {
                
                if (handler)
                {
                    handler (image);
                }
                
            }];
        }
    }
    else
    {
        if (handler)
        {
            handler (nil);
        }
    }
    
    return nil;
}

@end
