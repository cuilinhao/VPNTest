//
//  AddressPanel.m
//  VPNConnector
//
//  Created by fenghj on 15/12/22.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "AddressBar.h"
#import "AddressBarDisplayView.h"
#import "AssistInputBar.h"
#import <MOBFoundation/MOBFoundation.h>

static const CGFloat CancelButtonWidth = 60.0;
//static const CGFloat TopPadding = 5.0;
static const CGFloat Padding = 10.0;
static const CGFloat BottomPadding = 10.0;
static const CGFloat ContainerHeight = 29.0;
//static const CGFloat Top = 20.0;

@interface AddressBar () <UITextFieldDelegate>

/**
 *  背景视图
 */
@property (nonatomic, strong) UIView *backgroundView;

/**
 *  显示视图
 */
@property (nonatomic, strong) AddressBarDisplayView *displayView;

/**
 *  地址输入框
 */
@property (nonatomic, strong) AddressField *addressField;

/**
 *  取消按钮
 */
@property (nonatomic, strong) UIButton *cancelButton;

/**
 *  进度视图
 */
@property (nonatomic, strong) UIProgressView *progressView;

/**
 *  开始编辑事件处理
 */
@property (nonatomic, copy) void (^beginEditingHandler) (void);

/**
 *  结束编辑事件处理
 */
@property (nonatomic, copy) void (^endEditingHandler) (void);

/**
 *  刷新页面事件处理
 */
@property (nonatomic, copy) void (^refreshURLHandler) (void);

/**
 *  停止加载事件处理
 */
@property (nonatomic, copy) void (^stopLoadingHandler) (void);

/**
 *  加载页面事件处理
 */
@property (nonatomic, copy) void (^loadingURLHandler)(NSString *url);

/**
 *  返回首页事件处理
 */
@property (nonatomic, copy) void (^goToHomeHandler) (void);

/**
 *  链接
 */
@property (nonatomic, strong) NSURL *url;

/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  图标
 */
@property (nonatomic, copy) NSString *icon;

/**
 *  进度定时器
 */
@property (nonatomic, strong) NSTimer *progressTimer;

/**
 *  加载完成定时器
 */
@property (nonatomic, strong) NSTimer *completionTimer;

/**
 *  是否正在加载页面
 */
@property (nonatomic) BOOL isLoading;

/**
 *  开启迷你模式,只显示小标题
 */
@property (nonatomic) BOOL miniMode;

/**
 *  迷你图片视图
 */
@property (nonatomic, strong) UIImageView *miniImageView;

/**
 *  迷你模式背景
 */
@property (nonatomic, strong) UIImageView *miniBackgroundView;

/**
 *  迷你模式手势
 */
@property (nonatomic, strong) UITapGestureRecognizer *miniTapGesture;

@end

@implementation AddressBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(Padding, self.frame.size.height - BottomPadding - ContainerHeight, self.frame.size.width - 2 * Padding, ContainerHeight)];
        self.backgroundView.clipsToBounds = YES;
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"SearchBarBackground"] stretchableImageWithLeftCapWidth:15 topCapHeight:15]];
        bgView.frame = self.backgroundView.bounds;
        bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.backgroundView addSubview:bgView];
        
        self.addressField = [[AddressField alloc] initWithFrame:self.backgroundView.bounds];
        self.addressField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.addressField.hidden = YES;
        self.addressField.delegate = self;
        self.addressField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SEARCH_LABEL", @"输入网址或者百度一下")
                                                                                  attributes:@{NSForegroundColorAttributeName: [MOBFColor colorWithRGB:0x8F8F91]}];
        
        //添加辅助输入栏
        AssistInputBar *assistInputBar = [[AssistInputBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 44.0)];
        __weak AddressBar *theBar = self;
        [assistInputBar onText:^(NSString *content) {
            
            theBar.addressField.text = [theBar.addressField.text stringByAppendingString:content];
            
        }];
        self.addressField.inputAccessoryView = assistInputBar;
        
        
        [self.backgroundView addSubview:self.addressField];
        
        [self addSubview:self.backgroundView];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setTitle:NSLocalizedString(@"CANCEL_BUTTON_TITLE", @"Cancel") forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.cancelButton.frame = CGRectMake(self.frame.size.width - CancelButtonWidth - Padding, self.frame.size.height - ContainerHeight - BottomPadding, CancelButtonWidth, ContainerHeight);
        self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.cancelButton addTarget:self action:@selector(cancelButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
        self.cancelButton.hidden = YES;
        [self addSubview:self.cancelButton];
        
        self.displayView = [[AddressBarDisplayView alloc] initWithFrame:CGRectMake(Padding, self.frame.size.height - ContainerHeight - BottomPadding, self.frame.size.width - 2 * Padding, ContainerHeight)];
        self.displayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.displayView addTarget:self action:@selector(displayViewClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self.displayView.actionButton addTarget:self action:@selector(actionButtonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.displayView];
        
        self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.hidden = YES;
        self.progressView.progress = 0;
        self.progressView.trackTintColor = [UIColor whiteColor];
        self.progressView.frame = CGRectMake(0.0, self.frame.size.height - self.progressView.frame.size.height - 1, self.frame.size.width, self.progressView.frame.size.height);
        self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.progressView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 0.5, self.frame.size.width, 0.5)];
        lineView.backgroundColor = [MOBFColor colorWithRGB:0xbdbebe];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:lineView];
    }
    return self;
}

- (NSString *)text
{
    return self.addressField.text;
}

- (void)setText:(NSString *)text
{
    self.addressField.text = text;
}

- (void)setEditing:(BOOL)editing
{
    if (editing && self.miniMode)
    {
        //还原迷你模式
        self.miniMode = NO;
        [self miniModeProgress:0];
        [self becomeNormalModeCompletionHandler];
    }
    
    _editing = editing;
    
    if (_editing)
    {
        [self becomeFirstResponderAnimation];
    }
    else
    {
        [self resignFirstResponderAnimation];
    }
}

- (void)onBeginEditing:(void(^)(void))handler
{
    self.beginEditingHandler = handler;
}

- (void)onEndEditing:(void(^)(void))handler
{
    self.endEditingHandler = handler;
}

- (void)onRefreshURL:(void(^)(void))handler
{
    self.refreshURLHandler = handler;
}

- (void)onStopLoading:(void(^)(void))handler
{
    self.stopLoadingHandler = handler;
}

- (void)onLoadingURL:(void(^)(NSString *url))handler
{
    self.loadingURLHandler = handler;
}

- (void)onGoToHome:(void(^)(void))handler
{
    self.goToHomeHandler = handler;
}

- (void)loadingURL:(NSURL *)url title:(NSString *)title icon:(NSString *)icon
{
    if (!self.isLoading)
    {
        self.isLoading = YES;
        self.url = url;
        self.title = title;
        self.icon = icon;
        [self.displayView loadingByUrl:url title:title icon:icon];
        
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        
        if (!self.url)
        {
            self.addressField.text = @"";
            self.progressView.hidden = YES;
        }
        else
        {
            self.progressView.progress = 0;
            self.progressView.alpha = 0;
            self.progressView.hidden = NO;
            
            __weak AddressBar *theBar = self;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                theBar.progressView.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                [theBar.progressView setProgress:0.1 animated:YES];
                
            }];
            
            self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(progressTimerHandler:) userInfo:nil repeats:YES];
        }
    }
    else
    {
        if (self.progressView.progress < 0.8)
        {
            [self.progressView setProgress:self.progressView.progress + 0.1 animated:YES];
        }
    }
}

- (void)stopLoading
{
    self.isLoading = NO;
    [self.displayView completionByUrl:self.url title:self.title icon:self.icon];
    
    [self.progressTimer invalidate];
    self.progressTimer = nil;
    
    __weak AddressBar *theBar = self;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        theBar.progressView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        if (!theBar.isLoading)
        {
            theBar.progressView.hidden = YES;
        }
        
    }];
}

- (void)completionURL:(NSURL *)url title:(NSString *)title icon:(NSString *)icon
{
    //取消之前的完成倒计时，开启新的完成计时
    [self.completionTimer invalidate];
    self.completionTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(loadCompletionHandler:) userInfo:nil repeats:NO];
    
    if (!url)
    {
        self.addressField.text = @"";
    }
    
    self.url = url;
    self.title = title;
    self.icon = icon;
    
    [self.displayView completionByUrl:self.url title:self.title icon:self.icon];

    if (self.miniMode)
    {
        //生成地址图片
        self.displayView.hidden = NO;
        self.miniImageView.image = [self.displayView miniModeImage];
        self.displayView.hidden = YES;
    }
}

- (void)startMiniMode
{
    if (self.editing)
    {
        return;
    }
    
    //通过使用图片的方式做为过渡动画
    //先让displayView生成一张图片，再对图片进行缩放
    if (!self.miniBackgroundView)
    {
        self.miniBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.miniBackgroundView];
    }
    self.miniBackgroundView.image = [self.displayView miniModeBackgroundImage];
    self.miniBackgroundView.hidden = NO;
    self.miniBackgroundView.alpha = 1;
    self.miniBackgroundView.frame = CGRectMake(Padding, self.bounds.size.height - BottomPadding - ContainerHeight, self.frame.size.width - 2 * Padding, ContainerHeight);
    
    if (!self.miniImageView)
    {
        self.miniImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.miniImageView];
    }
    self.miniImageView.hidden = NO;
    self.miniImageView.image = [self.displayView miniModeImage];
    [self.miniImageView sizeToFit];
    self.miniImageView.frame = self.miniBackgroundView.frame;
    
    self.displayView.hidden = YES;
    self.backgroundView.hidden = YES;
    self.cancelButton.hidden = YES;
}

- (void)miniModeProgress:(CGFloat)progress
{
    if (self.editing)
    {
        return;
    }
    
    if (progress < 0)
    {
        progress = 0;
    }
    if (progress > 1)
    {
        progress = 1;
    }
    
    CGFloat maxTop = 20;
    CGFloat oriBarHeight = 64;
    if (@available(iOS 11.0, *))
    {
        maxTop = self.safeAreaInsets.top;
        oriBarHeight = self.safeAreaInsets.top + 44;
    }
    
    CGFloat targetBarHeight = maxTop + 20;
    CGFloat barHeight = targetBarHeight + (oriBarHeight - targetBarHeight) * (1 - progress);
    self.frame = CGRectMake(0.0, 0.0, self.superview.frame.size.width, barHeight);
    
    CGFloat hpadding = 10 + (50 - 10) * progress;
    CGFloat bottomPadding = 10 - 7 * progress;
    CGFloat width = self.frame.size.width - 2 * hpadding;
    CGFloat height = self.miniBackgroundView.frame.size.height / self.miniBackgroundView.frame.size.width * width;
    CGFloat topPadding = barHeight - maxTop - height - bottomPadding;
    self.miniBackgroundView.frame = CGRectMake(hpadding, maxTop +  topPadding, self.frame.size.width - 2 * hpadding, height);
    self.miniBackgroundView.alpha = 1 - 2 * progress;
    self.miniImageView.frame = self.miniBackgroundView.frame;
    
}

- (void)endMiniMode
{
    if (self.editing)
    {
        return;
    }
    
    self.miniMode = YES;
    
    [UIView beginAnimations:@"miniMode" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(becomeMiniModeCompletionHandler)];
    
    [self miniModeProgress:1];
    
    [UIView commitAnimations];
}

- (void)restoreNormalMode
{
    if (self.editing)
    {
        return;
    }
    
    self.miniMode = NO;
    [self removeGestureRecognizer:self.miniTapGesture];
    
    [UIView beginAnimations:@"miniMode" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(becomeNormalModeCompletionHandler)];
    
    [self miniModeProgress:0];
    
    [UIView commitAnimations];
}

#pragma mark - Private

/**
 *  加载完成事件处理
 *
 *  @param sender 事件对象
 */
- (void)loadCompletionHandler:(id)sender
{
    [self.completionTimer invalidate];
    self.completionTimer = nil;
    
    if (self.isLoading)
    {
        self.isLoading = NO;
        
        [self.progressTimer invalidate];
        self.progressTimer = nil;
        
        __weak AddressBar *theBar = self;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            theBar.progressView.progress = 1;
            theBar.progressView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            if (!theBar.isLoading)
            {
                theBar.progressView.hidden = YES;
            }
            
        }];
    }
}

/**
 *  变更迷你模式完成
 */
- (void)becomeMiniModeCompletionHandler
{
    if (!self.miniTapGesture)
    {
        self.miniTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(miniTapGestureHandler:)];
    }
    [self addGestureRecognizer:self.miniTapGesture];
}

/**
 *  变更正常模式完成
 */
- (void)becomeNormalModeCompletionHandler
{
    self.miniImageView.hidden = YES;
    self.miniBackgroundView.hidden = YES;
    
    self.displayView.hidden = NO;
    self.backgroundView.hidden = NO;
    self.cancelButton.hidden = NO;
}

/**
 *  迷你模式点击手势处理
 *
 *  @param sender 手势对象
 */
- (void)miniTapGestureHandler:(id)sender
{
    [self restoreNormalMode];
    [self removeGestureRecognizer:self.miniTapGesture];
}

/**
 *  进度计时器处理
 *
 *  @param sender 事件对象
 */
- (void)progressTimerHandler:(id)sender
{
    if (self.progressView.progress < 0.8)
    {
        self.progressView.progress += 0.002;
    }
}

/**
 *  显示视图点击事件
 *
 *  @param sender 事件对象
 */
- (void)displayViewClickedHandler:(id)sender
{
    self.editing = YES;
}

/**
 *  取消按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)cancelButtonClickedHandler:(id)sender
{
    if (self.backToHomeWhenClickCancelButton)
    {
        if (self.goToHomeHandler)
        {
            self.goToHomeHandler ();
        }
    }
    else
    {
        self.editing = NO;
    }
}


/**
 *  行为按钮点击事件
 *
 *  @param sender 事件对象
 */
- (void)actionButtonClickedHandler:(id)sender
{
    if (((UIButton *)sender).selected)
    {
        if (self.refreshURLHandler)
        {
            self.refreshURLHandler ();
        }
    }
    else
    {
        if (self.stopLoadingHandler)
        {
            self.stopLoadingHandler ();
        }
    }
}

/**
 *  获取焦点动画
 */
- (void)becomeFirstResponderAnimation
{
    __weak AddressBar *theBar = self;
    
    self.backgroundView.frame = self.displayView.frame;
    CGFloat left = (self.displayView.frame.size.width - 166) / 2;
    
    CGRect rect = self.addressField.frame;
    rect.origin.x = left;
    
    self.addressField.hidden = NO;
    self.addressField.frame = rect;
    [self.addressField becomeFirstResponder];
    
    self.cancelButton.hidden = NO;
    self.cancelButton.frame = CGRectMake(self.backgroundView.frame.origin.x + self.backgroundView.frame.size.width + Padding, self.frame.size.height - ContainerHeight - BottomPadding, CancelButtonWidth, ContainerHeight);
    self.cancelButton.alpha = 0.5;
    
    self.displayView.hidden = YES;
    
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if (theBar.isLoading)
        {
            theBar.progressView.alpha = 0;
        }
        
        CGRect rect = CGRectMake(Padding, self.frame.size.height - ContainerHeight - BottomPadding, self.frame.size.width - 2 * Padding - CancelButtonWidth, ContainerHeight);
        theBar.backgroundView.frame = rect;
        
        theBar.addressField.frame = theBar.backgroundView.bounds;
        
        theBar.cancelButton.alpha = 1;
        theBar.cancelButton.frame = CGRectMake(rect.origin.x + rect.size.width + Padding, self.frame.size.height - ContainerHeight - BottomPadding, CancelButtonWidth, ContainerHeight);
        
    } completion:^(BOOL finished) {
        
        [theBar.addressField selectAll:nil];
        
    }];
}

/**
 *  取消焦点动画
 */
- (void)resignFirstResponderAnimation
{
    __weak AddressBar *theBar = self;
    
    [self.addressField resignFirstResponder];
    
    CGFloat left = (self.displayView.frame.size.width - 166) / 2;
    
    [UIView beginAnimations:@"resignFirstResponderAnimation" context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    CGRect rect = CGRectMake(Padding, self.frame.size.height - ContainerHeight - BottomPadding, self.frame.size.width - 2 * Padding, ContainerHeight);
    theBar.backgroundView.frame = rect;
    
    theBar.addressField.frame = CGRectMake(left, 0, rect.size.width, rect.size.height);
    
    theBar.cancelButton.alpha = 0;
    theBar.cancelButton.frame = CGRectMake(rect.origin.x + rect.size.width + Padding, self.frame.size.height - ContainerHeight - BottomPadding, CancelButtonWidth, ContainerHeight);
    
    [UIView commitAnimations];
    
    theBar.displayView.hidden = NO;
    theBar.displayView.alpha = 0.0;
    
    [UIView beginAnimations:@"resignFirstResponderAnimation2" context:nil];
    [UIView setAnimationDelay:0.15];
    [UIView setAnimationDuration:0.05];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    if (theBar.isLoading)
    {
        theBar.progressView.alpha = 1;
    }
    
    
    theBar.displayView.alpha = 1;
    
    [UIView commitAnimations];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _editing = NO;
    [self resignFirstResponderAnimation];
    
    if (self.endEditingHandler)
    {
        self.endEditingHandler ();
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.url)
    {
        self.addressField.text = self.url.absoluteString;
    }
    
    if (self.beginEditingHandler)
    {
        self.beginEditingHandler ();
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *urlString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!urlString || [urlString isEqualToString:@""])
    {
        return NO;
    }
    
    if (self.loadingURLHandler)
    {
        self.loadingURLHandler (urlString);
    }
    
    [self.addressField resignFirstResponder];
    
    return YES;
}

@end
