//
//  AddressBarDisplayView.m
//  VPNConnector
//
//  Created by fenghj on 16/1/6.
//  Copyright © 2016年 vimfung. All rights reserved.
//

#import "AddressBarDisplayView.h"
#import "Context.h"
#import <MOBFoundation/MOBFoundation.h>
#import <MOBFoundation/MOBFImageGetter.h>

typedef NS_ENUM(NSUInteger, AddressBarDisplayViewState)
{
    AddressBarDisplayViewStateNormal = 0,
    AddressBarDisplayViewStateLoading = 1,
    AddressBarDisplayViewStateComplete = 2,
};

@interface AddressBarDisplayView ()

/**
 *  行为按钮
 */
@property (nonatomic, strong) UIButton *actionButton;

/**
 *  状态
 */
@property (nonatomic) AddressBarDisplayViewState viewState;

/**
 *  链接
 */
@property (nonatomic, strong) NSURL *url;

/**
 *  图标
 */
@property (nonatomic, copy) NSString *icon;

/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  图片观察者
 */
@property (nonatomic, strong) MOBFImageObserver *imageObserver;

@end

@implementation AddressBarDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.actionButton setImage:[UIImage imageNamed:@"StopIcon"] forState:UIControlStateNormal];
        [self.actionButton setImage:[UIImage imageNamed:@"RefreshIcon"] forState:UIControlStateSelected];
        self.actionButton.frame = CGRectMake(self.frame.size.width - 29, (self.frame.size.height - 29) / 2, 29, 29);
        self.actionButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.actionButton.hidden = YES;
        [self addSubview:self.actionButton];
        
        [self setBackgroundImage:[[UIImage imageNamed:@"SearchBarBackground"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]
                        forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"SearchBarBackgroundSelected"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]
                        forState:UIControlStateHighlighted];
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        
        self.viewState = AddressBarDisplayViewStateNormal;
    }
    
    return self;
}

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.imageObserver];
}

- (void)setViewState:(AddressBarDisplayViewState)viewState
{
    _viewState = viewState;
    
    Context *context = [Context sharedInstance];
    MOBFImageGetter *imageGetter = [MOBFImageGetter sharedInstance];
//    MOBFImageService *imageService = [MOBFImageService sharedInstance];
    
    switch (_viewState)
    {
        case AddressBarDisplayViewStateNormal:
        {
            self.actionButton.hidden = YES;
            
            [self setTitleColor:[MOBFColor colorWithRGB:0x8F8F91] forState:UIControlStateNormal];
            [self setTitle:NSLocalizedString(@"SEARCH_LABEL", @"输入网址或者百度一下") forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:@"SearchDarkIcon"] forState:UIControlStateNormal];
            
            break;
        }
        case AddressBarDisplayViewStateLoading:
        case AddressBarDisplayViewStateComplete:
        {
            self.actionButton.hidden = NO;
            
            if (_viewState == AddressBarDisplayViewStateComplete)
            {
                self.actionButton.selected = YES;
            }
            else
            {
                self.actionButton.selected = NO;
            }
            
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self setTitle:self.url.host forState:UIControlStateNormal];
            
            __weak AddressBarDisplayView *theView = self;
            UIImage *defImage = [context defaultWebsiteIconWithURL:self.url title:self.title];
            defImage = [MOBFImage scaleImage:defImage withSize:CGSizeMake(21, 21)];
            
            [self setImage:defImage forState:UIControlStateNormal];
            [imageGetter removeImageObserver:self.imageObserver];
            
            if (self.icon)
            {
                self.imageObserver = [imageGetter getImageWithURL:[NSURL URLWithString:self.icon] result:^(UIImage *image, NSError *error) {
                   
                    image = [MOBFImage scaleImage:image withSize:CGSizeMake(21, 21)];
                    if (image)
                    {
                        [theView setImage:image forState:UIControlStateNormal];
                    }
                    
                }];
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)loadingByUrl:(NSURL *)url title:(NSString *)title icon:(NSString *)icon
{
    self.url = url;
    self.icon = icon;
    self.title = title;
    
    if (self.url)
    {
        self.viewState = AddressBarDisplayViewStateLoading;
    }
    else
    {
        self.viewState = AddressBarDisplayViewStateNormal;
    }
}

- (void)completionByUrl:(NSURL *)url title:(NSString *)title icon:(NSString *)icon
{
    self.url = url;
    self.icon = icon;
    self.title = title;
    
    if (self.url)
    {
        self.viewState = AddressBarDisplayViewStateComplete;
    }
    else
    {
        self.viewState = AddressBarDisplayViewStateNormal;
    }
}

- (UIImage *)miniModeImage
{
    UIImage *image = [[UIImage alloc] init];
    
    [self setBackgroundImage:image
                    forState:UIControlStateNormal];
    [self setBackgroundImage:image
                    forState:UIControlStateHighlighted];
    self.actionButton.hidden = YES;
    
    UIImage *miniImage = [MOBFImage imageByView:self opaque:NO];
    
    
    if (self.viewState != AddressBarDisplayViewStateNormal)
    {
        self.actionButton.hidden = NO;
    }
    [self setBackgroundImage:[[UIImage imageNamed:@"SearchBarBackground"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]
                    forState:UIControlStateNormal];
    [self setBackgroundImage:[[UIImage imageNamed:@"SearchBarBackgroundSelected"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]
                    forState:UIControlStateHighlighted];
    
    return miniImage;
}

- (UIImage *)miniModeBackgroundImage
{
    NSString *text = [self titleForState:UIControlStateNormal];
    UIImage *image = [self imageForState:UIControlStateNormal];
    
    [self setTitle:@"" forState:UIControlStateNormal];
    [self setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    
    UIImage *miniImage = [MOBFImage imageByView:self opaque:NO];
    
    [self setTitle:text forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateNormal];
    
    return miniImage;
}

@end
