//
//  AddVPNViewController.m
//  VPNBrowser
//
//  Created by youzu on 2018/8/9.
//  Copyright © 2018年 vimfung. All rights reserved.
//

#import "AddVPNViewController.h"
#import "VPNInfo+CoreDataClass.h"
#import "VPNTypeViewController.h"
#import "AddVPNTypeTableViewCell.h"
#import "AddVPNTextTableViewCell.h"
#import "VPNTypeViewController.h"
#import <MOBFoundation/MOBFoundation.h>

NSString *const AddItemCellTypeText = @"TextType";
NSString *const AddItemCellTypeDes = @"TextTypeDes";



@interface AddVPNViewController () <UITableViewDataSource,
                                    UITableViewDelegate,
                                    UIAlertViewDelegate,
                                    UITextFieldDelegate>


@property (weak) IBOutlet UITableView *tableView;


@property (strong) NSMutableArray *typeIKev2Array;
@property (strong) NSMutableArray *typeIPSecArray;

@property (strong) NSArray *dataArray;


@property (strong) NSMutableDictionary *dataDict;


@property (nonatomic, strong) AddVPNTypeTableViewCell *typeCell;

@property (nonatomic, strong) AddVPNTextTableViewCell *desCell;
@property (nonatomic, strong) AddVPNTextTableViewCell *serverCell;
@property (nonatomic, strong) AddVPNTextTableViewCell *localIdCell;
@property (nonatomic, strong) AddVPNTextTableViewCell *remoteIdCell;
@property (nonatomic, strong) AddVPNTextTableViewCell *userNameCell;
@property (nonatomic, strong) AddVPNTextTableViewCell *pwdCell;
@property (nonatomic, strong) AddVPNTextTableViewCell *sharekeyCell;

@property (weak) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation AddVPNViewController


- (AddVPNTypeTableViewCell *)typeCell
{
    if(!_typeCell)
    {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"AddVPNTypeTableViewCell" owner:self options:nil];
        _typeCell = cells.firstObject;
        _typeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return _typeCell;
}

- (AddVPNTextTableViewCell *)desCell
{
    if(!_desCell)
    {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"AddVPNTextTableViewCell" owner:self options:nil];
        _desCell = cells.firstObject;
    }
    return _desCell;
}

- (AddVPNTextTableViewCell *)serverCell
{
    if(!_serverCell)
    {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"AddVPNTextTableViewCell" owner:self options:nil];
        _serverCell = cells.firstObject;
    }
    return _serverCell;
}


- (AddVPNTextTableViewCell *)localIdCell
{
    if(!_localIdCell)
    {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"AddVPNTextTableViewCell" owner:self options:nil];
        _localIdCell = cells.firstObject;
    }
    return _localIdCell;
}


- (AddVPNTextTableViewCell *)remoteIdCell
{
    if(!_remoteIdCell)
    {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"AddVPNTextTableViewCell" owner:self options:nil];
        _remoteIdCell = cells.firstObject;
    }
    return _remoteIdCell;
}


- (AddVPNTextTableViewCell *)userNameCell
{
    if(!_userNameCell)
    {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"AddVPNTextTableViewCell" owner:self options:nil];
        _userNameCell = cells.firstObject;
    }
    return _userNameCell;
}

- (AddVPNTextTableViewCell *)pwdCell
{
    if(!_pwdCell)
    {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"AddVPNTextTableViewCell" owner:self options:nil];
        _pwdCell = cells.firstObject;
        
        _pwdCell.tf.secureTextEntry = YES;
    }
    return _pwdCell;
}

- (AddVPNTextTableViewCell *)sharekeyCell
{
    if(!_sharekeyCell)
    {
        NSArray *cells = [[NSBundle mainBundle] loadNibNamed:@"AddVPNTextTableViewCell" owner:self options:nil];
        _sharekeyCell = cells.firstObject;
    }
    return _sharekeyCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClickedHandler)];

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClickedHandler:)];

    
    self.typeIKev2Array = [NSMutableArray new];
    //原始数据源
    [self loadDataNew];

}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregNotification];
}

- (void)loadDataNew
{
    
    
    {
        //group1
        NSMutableArray *group1 = [NSMutableArray new];
        {
            self.typeCell.titleLbl.text = NSLocalizedString(@"Text_Title_Type", @"Type");
            self.typeCell.desLbl.text = VPNTypeIPSec;
            [group1 addObject:self.typeCell];
            
            
        }
        
        NSMutableArray *group2 = [NSMutableArray new];
        {
            {
                self.desCell.titleLbl.text = NSLocalizedString(@"Text_Title_Des", @"Description");
                self.desCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");

                [group2 addObject:self.desCell];
            }
            
            {
                self.serverCell.titleLbl.text = NSLocalizedString(@"Text_Title_Server", @"Server");
                self.serverCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");
                
                [group2 addObject:self.serverCell];
                
            }
            
            {
                self.remoteIdCell.titleLbl.text = NSLocalizedString(@"Text_Title_RemoteId", @"Remote ID");
                self.remoteIdCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");
                
                [group2 addObject:self.remoteIdCell];
            }
            
            {
                self.localIdCell.titleLbl.text = NSLocalizedString(@"Text_Title_LocalId", @"Local ID");
                self.localIdCell.tf.placeholder = @"";
                
                [group2 addObject:self.localIdCell];
            }
            
        }
        //group2
        
        NSMutableArray *group3 = [NSMutableArray new];
        //group3
        {
            {
                self.userNameCell.titleLbl.text = NSLocalizedString(@"Text_Title_UserName", @"Username");
                self.userNameCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");
                
                [group3 addObject:self.userNameCell];
            }
            
            {
                self.pwdCell.titleLbl.text = NSLocalizedString(@"Text_Title_UserPwd", @"Password");
                self.pwdCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");
                
                [group3 addObject:self.pwdCell];
            }
        }
        
        [self.typeIKev2Array addObject:group1];
        [self.typeIKev2Array addObject:group2];
        [self.typeIKev2Array addObject:group3];
        
    }
    
    
    self.typeIPSecArray = [NSMutableArray new];
    //原始数据源
    {
        //group1
        NSMutableArray *group1 = [NSMutableArray new];
        {
            self.typeCell.titleLbl.text = NSLocalizedString(@"Text_Title_Type", @"类型");
            self.typeCell.desLbl.text = @"IKEv2";
            [group1 addObject:self.typeCell];
        }
        
        NSMutableArray *group2 = [NSMutableArray new];
        {
            {
                self.desCell.titleLbl.text = NSLocalizedString(@"Text_Title_Des", @"描述");
                self.desCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");
                
                [group2 addObject:self.desCell];
            }
            
            {
                self.serverCell.titleLbl.text = NSLocalizedString(@"Text_Title_Server", @"服务器");
                self.serverCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");
                
                [group2 addObject:self.serverCell];
                
            }
            
            {
                self.userNameCell.titleLbl.text = NSLocalizedString(@"Text_Title_UserName", @"用户名");
                self.userNameCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");
                
                [group2 addObject:self.userNameCell];
            }
            
            {
                self.pwdCell.titleLbl.text = NSLocalizedString(@"Text_Title_UserPwd", @"密码");
                self.pwdCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");
                _pwdCell.tf.secureTextEntry = YES;
                
                [group2 addObject:self.pwdCell];
            }
            
            {
                self.sharekeyCell.titleLbl.text = NSLocalizedString(@"Text_Title_SecretKey", @"秘钥");
                self.sharekeyCell.tf.placeholder = NSLocalizedString(@"Text_Title_Required", @"Required");
                _sharekeyCell.tf.secureTextEntry = YES;

                [group2 addObject:self.sharekeyCell];
            }
            
        }
        [self.typeIPSecArray addObject:group1];
        [self.typeIPSecArray addObject:group2];
        
    }
    
    [self switchType];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.dataArray)
    {
        [self switchType];
    }
    [self regNotification];

}


- (void)switchType
{
    if([self.typeCell.desLbl.text isEqualToString:VPNTypeIPSec])
    {
        self.dataArray = self.typeIPSecArray;
    }
    else
    {
        self.dataArray = self.typeIKev2Array;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 取消 & 完成按钮

- (void)cancelButtonClickedHandler
{
    self.tableView.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonClickedHandler:(UIButton *)btn
{
    
    NSString *server = nil;
    NSString *des = nil;
    NSString *remoteId = nil;
    NSString *username = nil;
    NSString *pwd = nil;
    NSString *type = nil;
    NSString *localId = nil;
    NSString *secrectKey = nil;

    
    server = self.serverCell.tf.text;
    des = self.desCell.tf.text;
    remoteId = self.remoteIdCell.tf.text;
    localId = self.localIdCell.tf.text;
    username = self.userNameCell.tf.text;
    pwd = self.pwdCell.tf.text;
    type = self.typeCell.desLbl.text;
    secrectKey = self.sharekeyCell.tf.text;
    
    NSString *msg = nil;
    if(self.desCell.tf.text.length == 0)
    {
        msg = NSLocalizedString(@"Des_NOT_EMPTY", @"Description not empty");
    }
    else if(self.serverCell.tf.text.length == 0)
    {
        msg = NSLocalizedString(@"Server_NOT_EMPTY", @"Server ID not empty");
    }
    if(self.userNameCell.tf.text.length == 0)
    {
        msg = NSLocalizedString(@"Username_NOT_EMPTY", @"Username not empty");
    }
    else if(self.pwdCell.tf.text.length == 0)
    {
        msg = NSLocalizedString(@"PASSWORD_NOT_EMPTY", @"Password not empty");
    }
    else
    {
        if([self.typeCell.desLbl.text isEqualToString:VPNTypeIPSec])
        {
            if(self.sharekeyCell.tf.text.length == 0)
            {
                msg = NSLocalizedString(@"SecrectKey_NOT_EMPTY", @"SecretKey not empty");
            }
        }
        else
        {
            if(self.remoteIdCell.tf.text.length == 0)
            {
                msg = NSLocalizedString(@"RemoteID_NOT_EMPTY", @"Remote ID not empty");
            }
        }
    }

    if(msg)
    {
        [self showAlert:msg];
        return;
    }

    //加密
    {
        
        NSData *keyData = [MOBFData md5Data:[[MOBFApplication bundleId] dataUsingEncoding:NSUTF8StringEncoding]];
        NSData *encData = [MOBFData aes128EncryptData:[pwd dataUsingEncoding:NSUTF8StringEncoding] key:keyData options:kCCOptionECBMode | kCCOptionPKCS7Padding];
        pwd = [MOBFData stringByBase64EncodeData:encData];
    }
    
    //添加
    [[Context sharedInstance] addVPNInfo:server remoteId:remoteId localId:localId userName:username password:pwd description:des type:type secretKey:secrectKey];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeTypeButtonClickedHandler
{
    
}

- (void)deleteButtonClickedHandler:(UIButton *)btn
{
    //处理数据库，返回
    [[Context sharedInstance] removeVPNInfo:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlert:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TIPS_ALERT_TITLE", @"提示")
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"KONWN_BUTTON_TITLE", @"知道了")
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *curCell = [self.dataArray[indexPath.section] objectAtIndex:indexPath.row];

    
  
    /*
    ADDItem *item = [self.dataArray[indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *curCell = nil;
    if([item.cellType isEqualToString:AddItemCellTypeText])
    {
        AddVPNTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellType];
        if (!cell)
        {
            cell = [[AddVPNTextTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:item.cellType];
        }
        curCell = cell;
        cell.titleLbl.text = item.title;
    }
    else if([item.cellType isEqualToString:AddItemCellTypeDes])
    {
        AddVPNTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item.cellType];
        if (!cell)
        {
            cell = [[AddVPNTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:item.cellType];
        }
        curCell = cell;
        cell.titleLbl.text = item.title;
        cell.desLbl.text = self.dataDict[item.key];

    }
    */
    return curCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    VPNTypeViewController *vc = [[VPNTypeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    [vc setSelectBlock:^(NSString *type) {
        
        self.typeCell.desLbl.text = type;
        [self switchType];
        [self.tableView reloadData];
        
    }];
}

- (void)regNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)unregNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - notification handler

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect beginKeyboardRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
//    CGFloat yOffset = endKeyboardRect.origin.y - beginKeyboardRect.origin.y;
    
    self.bottomConstraint.constant = [UIScreen mainScreen].bounds.size.height - endKeyboardRect.origin.y;
    
    NSLog(@"----%f---%f",endKeyboardRect.origin.y);
    //CGRect inputFieldRect = self.inputTextField.frame;
    //CGRect moreBtnRect = self.moreInputTypeBtn.frame;
    
    //inputFieldRect.origin.y += yOffset;
    //moreBtnRect.origin.y += yOffset;
    
    [UIView animateWithDuration:duration animations:^{
        //self.inputTextField.frame = inputFieldRect;
        //self.moreInputTypeBtn.frame = moreBtnRect;
    }];
}
@end
