//
//  WebWindowInfo.m
//  VPNConnector
//
//  Created by fenghj on 15/12/23.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "PageInfo.h"
#import <MOBFoundation/MOBFoundation.h>

static const CGFloat ImageWidth = 150.0;
static const CGFloat ImageHeight = 125.0;

@interface PageInfo ()

/**
 *  Web页面
 */
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation PageInfo

- (instancetype)init
{
    if (self = [super init])
    {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        self.webView.scalesPageToFit = YES;
    }
    return self;
}

- (NSString *)icon
{
    NSString *icon = nil;
    NSURL *url = self.browsingURL;
    
    static NSString *const getFavJS = @"(function(){var favicon=undefined;var selectedNode=null;var selectedSize=0;var nodeList=document.getElementsByTagName('link');for(var i=0;i<nodeList.length;i++){var node=nodeList[i];var relStr=node.getAttribute('rel').toLowerCase().trim();switch(relStr){case'icon':case'shortcut icon':{if(selectedNode==null||(selectedNode.getAttribute('rel').toLocaleLowerCase()!='apple-touch-icon-precomposed'&&selectedNode.getAttribute('rel').toLocaleLowerCase()!='apple-touch-icon')){selectedNode=node;selectedSize=0}break}case'apple-touch-icon-precomposed':case'apple-touch-icon':{var sizeValue=0;var sizesStr=node.getAttribute('sizes');var re=/(\\d+)x(\\d+)/;if(re.test(sizesStr)){sizeValue=RegExp.$1*RegExp.$2}if(selectedSize<=sizeValue){selectedNode=node;selectedSize=sizeValue}break}}}if(selectedNode!=null){return selectedNode.getAttribute('href')}return""})();";
    
    if ([url.host isEqualToString:self.webView.request.URL.host])
    {
        icon = [self.webView stringByEvaluatingJavaScriptFromString:getFavJS];
        if (!icon || [icon isEqualToString:@""])
        {
            icon = [NSString stringWithFormat:@"%@://%@/favicon.ico", url.scheme, url.host];
        }
        else
        {
            if (![MOBFRegex isMatchedByRegex:@"^\\w+://" options:MOBFRegexOptionsCaseless inRange:NSMakeRange(0, icon.length) withString:icon])
            {
                if ([icon hasPrefix:@"//"])
                {
                    icon = [NSString stringWithFormat:@"%@:%@", url.scheme, icon];
                }
                else
                {
                    icon = [NSString stringWithFormat:@"%@://%@%@", url.scheme, url.host, icon];
                }
            }
        }
    }
    
    return icon;
}

- (NSString *)url
{
    return self.browsingURL.absoluteString;
}

- (NSString *)title
{
    NSString *title = nil;
    NSURL *url = self.browsingURL;
    if ([url.host isEqualToString:self.webView.request.URL.host] && [url.path isEqualToString:self.webView.request.URL.path])
    {
        title =  [self.webView stringByEvaluatingJavaScriptFromString:@"this.document.title"];
    }
    
    if (!title || [title isEqualToString:@""])
    {
        NSArray *hostArr = [url.host componentsSeparatedByString:@"."];
        NSMutableString *host = [NSMutableString string];
        
        if (hostArr.count > 0)
        {
            NSInteger i = hostArr.count - 2;
            if (i < 0)
            {
                i = 0;
            }
            
            for (; i < hostArr.count; i++)
            {
                [host appendFormat:@"%@.", hostArr[i]];
            }
            
            [host deleteCharactersInRange:NSMakeRange(host.length - 1, 1)];
            [host replaceCharactersInRange:NSMakeRange(0, 1) withString:[[host substringToIndex:1] uppercaseString]];
        }
        
        
        title = host;
    }
    
    if (!title || [title isEqualToString:@""])
    {
        title = NSLocalizedString(@"HOME_TITLE", @"Home");
    }
    
    return title;
}

- (UIImage *)image
{
    UIImage *image = nil;
    if (self.webView.request)
    {
        image = [self _webImage];
    }
    else
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ImageWidth, ImageHeight)];
        view.backgroundColor = [UIColor whiteColor];
        image = [MOBFImage imageByView:view];
        image = [MOBFImage roundRectImage:image withSize:CGSizeMake(ImageWidth, ImageHeight) ovalWidth:6 ovalHeight:6 ovalType:MOBFOvalTypeAll];
    }
    
    return image;
}


- (UIImage *)miniWebImage
{
    NSString *str = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    if (str.length > 0)
    {
        return [self _webImage];
    }
    
    return nil;
}

#pragma mark - Private


/**
 获取网页截图

 @return 网页截图
 */
- (UIImage *)_webImage
{
    //先记录边距，等截图完成后再还原，否则图片上会有一段空白的位置。
    CGPoint contentOffset = self.webView.scrollView.contentOffset;
    if (contentOffset.y < 0)
    {
        self.webView.scrollView.contentOffset = CGPointZero;
    }
    UIImage *image = [MOBFImage scaleImage:[MOBFImage imageByView:self.webView] withSize:CGSizeMake(ImageWidth, MAXFLOAT)];
    image = [MOBFImage clipImage:image withRect:CGRectMake(0, 0, ImageWidth, ImageHeight)];
    image = [MOBFImage roundRectImage:image withSize:CGSizeMake(ImageWidth, ImageHeight) ovalWidth:6 ovalHeight:6 ovalType:MOBFOvalTypeAll];
    self.webView.scrollView.contentOffset = contentOffset;
    
    return image;
}

@end
