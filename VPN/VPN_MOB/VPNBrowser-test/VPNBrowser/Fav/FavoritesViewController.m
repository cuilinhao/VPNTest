//
//  FavoritesViewController.m
//  VPNConnector
//
//  Created by fenghj on 15/12/28.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "FavoritesViewController.h"
#import "FavoritesView.h"
#import <MOBFoundation/MOBFoundation.h>

@interface FavoritesViewController ()

/**
 收藏视图
 */
@property (weak, nonatomic) IBOutlet FavoritesView *favoritesView;

/**
 *  列表项点击事件
 */
@property (nonatomic, copy) void (^itemClickedHandler) (FavURL *URL);

@end

@implementation FavoritesViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.title = NSLocalizedString(@"MY_FAVORITES_TITLE", @"My Favorites");;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.favoritesView onItemClicked:self.itemClickedHandler];
}

- (void)onItemClicked:(void(^)(FavURL *URL))handler
{
    self.itemClickedHandler = handler;
    if (self.isViewLoaded)
    {
        [self.favoritesView onItemClicked:handler];
    }
}

@end
