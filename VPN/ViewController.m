
#import "ViewController.h"
#import <NetworkExtension/NetworkExtension.h>

@interface ViewController ()
@property (nonatomic, strong) NEVPNManager *manage;
@end


#pragma mark - Demo

@implementation ViewController

#pragma mark -  生命周期 Life Circle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _testVPN];
}

- (void)_testVPN
{
    self.manage = [NEVPNManager sharedManager];
    
    /*
     
     服务端口    13229
     连接密码    cecil2007
     
     标准普及版     VIP美国003    us003.jiasudu.pw
     标准普及版     VIP美国004    us004.jiasudu.pw
     标准普及版     VIP美国005    us005.jiasudu.pw
     标准普及版     VIP美国006    us006.jiasudu.pw
     标准普及版     VIP美国007    us007.jiasudu.pw
     
     */
    [self.manage loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        NSError *errors = error;
        if (errors) {
            NSLog(@"---errors--->>>>>>%@",errors);
        }
        else{
            NEVPNProtocolIKEv2 *p = [[NEVPNProtocolIKEv2 alloc] init];
            
            //用户名
            p.username = @"linrb";
            //服务器地址
            p.serverAddress = @"us003.jiasudu.pw";
            
            //密码
            [self createKeychainValue:@"" forIdentifier:@"VPN_PASSWORD"];
            p.passwordReference =  [self searchKeychainCopyMatching:@"VPN_PASSWORD"];
            
            //共享秘钥    可以和密码同一个.
            [self createKeychainValue:@"cecil2007" forIdentifier:@"PSK"];
            p.sharedSecretReference = [self searchKeychainCopyMatching:@"PSK"];
            
            p.localIdentifier = @"";
            
            p.remoteIdentifier = @"";
            
            
            p.useExtendedAuthentication = YES;
            
            p.disconnectOnSleep = NO;
            
            self.manage.onDemandEnabled = NO;
            
            [self.manage setProtocolConfiguration:p];
            //描述
            self.manage.localizedDescription = @"天下林子";
            
            self.manage.enabled = true;
            
            [self.manage saveToPreferencesWithCompletionHandler:^(NSError *error) {
                if(error) {
                    NSLog(@"---eeee----Save error: %@", error);
                }
                else {
                    NSLog(@"------>>>>>Saved!");
                }
            }];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onVpnStateChange:) name:NEVPNStatusDidChangeNotification object:nil];
}

#pragma mark - 链接
- (IBAction)ConnectBtn:(id)sender
{
    NSError *error = nil;
    [self.manage.connection startVPNTunnelAndReturnError:&error];
    if(error) {
        NSLog(@"+++++++++Start error: %@", error.localizedDescription);
    }
    else
    {
        NSLog(@"++++++++Connection established!");
    }
    
}


- (void)onVpnStateChange:(NSNotification *)Notification
{
    
    NEVPNStatus state = self.manage.connection.status;
 
    switch (state) {
        case NEVPNStatusInvalid:
            NSLog(@"无效连接");
            break;
        case NEVPNStatusDisconnected:
            NSLog(@"未连接");
            break;
        case NEVPNStatusConnecting:
            NSLog(@"正在连接");
            break;
        case NEVPNStatusConnected:
            NSLog(@"已连接");
            break;
        case NEVPNStatusDisconnecting:
            NSLog(@"断开连接");
            break;
        default:
            break;
    }
}



- (NSData *)searchKeychainCopyMatching:(NSString *)identifier
{
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [searchDictionary setObject:@YES forKey:(__bridge id)kSecReturnPersistentRef];
    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    return (__bridge_transfer NSData *)result;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier
{
    // creat a new item
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    //OSStatus 就是一个返回状态的code 不同的类返回的结果不同
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)dictionary);
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

//服务器地址
static NSString * const serviceName = @"us003.jiasudu.pw";

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    //   keychain item creat
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    //   extern CFTypeRef kSecClassGenericPassword  一般密码
    //   extern CFTypeRef kSecClassInternetPassword 网络密码
    //   extern CFTypeRef kSecClassCertificate 证书
    //   extern CFTypeRef kSecClassKey 秘钥
    //   extern CFTypeRef kSecClassIdentity 带秘钥的证书
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    //ksecClass 主键
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    return searchDictionary;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
