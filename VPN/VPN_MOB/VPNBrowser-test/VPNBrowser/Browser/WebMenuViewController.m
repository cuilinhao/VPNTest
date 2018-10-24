//
//  WebMenuViewController.m
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "WebMenuViewController.h"
#import "WebMenuView.h"
#import "Context.h"
#import "FavURL.h"

@interface WebMenuViewController ()

/**
 *  菜单视图
 */
@property (nonatomic, strong) WebMenuView *menuView;

/**
 *  列表项点击事件
 */
@property (nonatomic, copy) void(^itemClickHandler)(NSIndexPath *indexPath);

/**
 *  取消事件
 */
@property (nonatomic, copy) void(^cancelHandler)(void);

/**
 *  窗口尺寸
 */
@property (nonatomic) CGRect windowFrame;

@end

@implementation WebMenuViewController

- (instancetype)initWithWindowFrame:(CGRect)frame
{
    if (self = [super initWithNibName:nil bundle:nil])
    {

    }
    return self;
}

#pragma mark -  生命周期 Life Circle
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    static const CGFloat MenuHeight = 167.0;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    //菜单视图
    self.menuView = [[WebMenuView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - MenuHeight, self.view.frame.size.width, MenuHeight)];
    self.menuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.menuView];
    
    __weak WebMenuViewController *theController = self;
    [self.menuView onItemClickedHandler:^(NSIndexPath *indexPath) {
        
        if (theController.itemClickHandler)
        {
            theController.itemClickHandler (indexPath);
        }
        
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self closeWindow];
}

- (void)onItemClicked:(void (^)(NSIndexPath *))handler
{
    self.itemClickHandler = handler;
}

- (void)onCancel:(void(^)(void))handler
{
    self.cancelHandler = handler;
}

- (void)updateStatus
{
    [self.menuView updateStatus];
}

#pragma mark - Private

/**
 *  关闭窗口
 */
- (void)closeWindow
{
    [self.view.window resignKeyWindow];
    self.view.window.hidden = YES;
    
    if (self.cancelHandler)
    {
        self.cancelHandler ();
    }
}

@end
