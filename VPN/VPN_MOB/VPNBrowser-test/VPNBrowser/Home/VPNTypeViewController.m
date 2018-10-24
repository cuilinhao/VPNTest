//
//  VPNTypeViewController.m
//  VPNBrowser
//
//  Created by hower on 2018/8/9.
//  Copyright © 2018年 vimfung. All rights reserved.
//

#import "VPNTypeViewController.h"

@interface VPNTypeViewController ()

@property (nonatomic, strong)NSArray *dataArray;

@end

@implementation VPNTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back_BUTTON_TITLE", @"返回") style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    self.dataArray = @[VPNTypeIKev2,VPNTypeIPSec];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"CeLL"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CeLL"];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.selectBlock)
    {
        self.selectBlock(self.dataArray[indexPath.row]);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
