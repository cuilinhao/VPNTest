//
//  MOBFVPNConnector.m
//  VPNConnector
//
//  Created by fenghj on 15/12/7.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "MOBVPNConnector.h"
#import "MOBVPNIPSecConfig.h"
#import "MOBVPNIKev2Config.h"
#import <MOBFoundation/MOBFoundation.h>
#import <UIKit/UIKit.h>

static NSString *const ValidDateKey = @"ValidDate";

@interface MOBVPNConnector ()

@property (nonatomic, strong) NEVPNManager *vpnManager;

@property (nonatomic) BOOL hasReady;

/**
 *  是否正在保存配置
 */
@property (nonatomic) BOOL isSavingConfig;

@property (nonatomic, copy) VPNConnectorReadyHandler readyHandler;

@property (nonatomic, copy) VPNConnectorErrorHandler errorHandler;

@property (nonatomic, copy) VPNConnectorStatusChangeHandler statusChangeHandler;

@property (nonatomic, copy) VPNConfigChangedHandler configChangedHandler;

@property (nonatomic, strong) MOBVPNConfig *config;

/**
 *  有效时间
 */
@property (nonatomic, strong) NSDate *validDate;

@end

@implementation MOBVPNConnector

- (instancetype) init
{
    if (self = [super init])
    {
        self.vpnManager = [NEVPNManager sharedManager];
        [self setup];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setConfig:(MOBVPNConfig *)config
{
    _config = config;
    
    if (self.hasReady)
    {
        [self applyConfig];
    }
}

+ (MOBVPNConnector *)sharedInstance
{
    static MOBVPNConnector *instance;
    static dispatch_once_t instancePredicate;
    
    dispatch_once(&instancePredicate, ^{
       
        instance = [[MOBVPNConnector alloc] init];
        
    });
    
    return instance;
}

- (void) onReady:(VPNConnectorReadyHandler)handler
{
    self.readyHandler = handler;
}

- (void) onError:(VPNConnectorErrorHandler)handler
{
    self.errorHandler = handler;
}

- (void) onStatusChange:(VPNConnectorStatusChangeHandler)handler
{
    self.statusChangeHandler = handler;
}

- (void) onConfigChange:(VPNConfigChangedHandler)handler
{
    self.configChangedHandler = handler;
}

- (void)connect
{
    NSError *error = nil;
    [self.vpnManager.connection startVPNTunnelAndReturnError:&error];
    
    if (error)
    {
        if (self.errorHandler)
        {
            self.errorHandler (error);
        }
    }
}

- (void)disconnect
{
    [self.vpnManager.connection stopVPNTunnel];
}

- (NEVPNStatus)status
{
    return self.vpnManager.connection.status;
}

- (NSTimeInterval)connectedTime
{
    return -[self.vpnManager.connection.connectedDate timeIntervalSinceNow];
}

- (NSDate *) limitDate
{
    if (!self.validDate)
    {
        self.validDate = [[MOBFDataService sharedInstance] cacheDataForKey:ValidDateKey domain:nil];
    }
    
    if (!self.validDate)
    {
        //试用一天
        self.validDate = [[NSDate alloc] initWithTimeIntervalSinceNow:3600 * 24];
    }
    
    return self.validDate;
}

- (void) setLimitDate:(NSDate *)limitDate
{
    self.validDate = limitDate;
    [[MOBFDataService sharedInstance] setCacheData:limitDate forKey:ValidDateKey domain:nil];
}

#pragma mark - Private

/**
 *  应用配置
 */
- (void) applyConfig
{
    NEVPNProtocol *applyProtocol = nil;
    if ([self.config isKindOfClass:[MOBVPNIKev2Config class]])
    {
        MOBVPNIKev2Config *ikev2Conf = (MOBVPNIKev2Config *)self.config;
        
        NEVPNProtocolIKEv2 *protocol = [[NEVPNProtocolIKEv2 alloc] init];
        protocol.serverAddress = ikev2Conf.address;
        protocol.username = ikev2Conf.userName;
        protocol.passwordReference = [self getKeyChainReferenceWithIdentifier:@"VPN_PASSWORD" data:[ikev2Conf.password dataUsingEncoding:NSUTF8StringEncoding]];
        
        protocol.remoteIdentifier = ikev2Conf.remoteId;
        protocol.localIdentifier = ikev2Conf.localId;
        
//        protocol.authenticationMethod = NEVPNIKEAuthenticationMethodCertificate;
//        protocol.serverCertificateCommonName = @"ikev2.lamfire.com";
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"client.cert" ofType:@"p12"];
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        protocol.identityData = data;
//        protocol.identityDataPassword = @"lin12345";
        
        if (ikev2Conf.shareSecret.length > 0)
        {
            protocol.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
            protocol.sharedSecretReference = [self getKeyChainReferenceWithIdentifier:@"VPN_SHARESECRET" data:[ikev2Conf.shareSecret dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
            protocol.authenticationMethod = NEVPNIKEAuthenticationMethodNone;
        }
        
        protocol.childSecurityAssociationParameters.diffieHellmanGroup = NEVPNIKEv2DiffieHellmanGroup2;
        protocol.childSecurityAssociationParameters.encryptionAlgorithm = NEVPNIKEv2EncryptionAlgorithm3DES;
        protocol.childSecurityAssociationParameters.integrityAlgorithm = NEVPNIKEv2IntegrityAlgorithmSHA96;
        protocol.childSecurityAssociationParameters.lifetimeMinutes = 1440;
        
        protocol.deadPeerDetectionRate = NEVPNIKEv2DeadPeerDetectionRateMedium;
        
        if ([MOBFDevice versionCompare:@"9.0"] != NSOrderedAscending)
        {
            protocol.disableMOBIKE = NO;
            protocol.disableRedirect = NO;
            protocol.enableRevocationCheck = NO;
            protocol.enablePFS = NO;
            
            protocol.useConfigurationAttributeInternalIPSubnet = NO;
        }
        
        
        protocol.IKESecurityAssociationParameters.diffieHellmanGroup = NEVPNIKEv2DiffieHellmanGroup2;
        protocol.IKESecurityAssociationParameters.encryptionAlgorithm = NEVPNIKEv2EncryptionAlgorithm3DES;
        protocol.IKESecurityAssociationParameters.integrityAlgorithm = NEVPNIKEv2IntegrityAlgorithmSHA96;
        protocol.IKESecurityAssociationParameters.lifetimeMinutes = 1440;
        
        protocol.useExtendedAuthentication = YES;
        protocol.disconnectOnSleep = NO;
        
        applyProtocol = protocol;
    }
    else if ([self.config isKindOfClass:[MOBVPNIPSecConfig class]])
    {
        MOBVPNIPSecConfig *ipsecConf = (MOBVPNIPSecConfig *)self.config;
        
        NEVPNProtocolIPSec *protocol = [[NEVPNProtocolIPSec alloc] init];
        protocol.serverAddress = ipsecConf.address;
        protocol.username = ipsecConf.userName;
        protocol.passwordReference = [self getKeyChainReferenceWithIdentifier:@"VPN_PASSWORD" data:[ipsecConf.password dataUsingEncoding:NSUTF8StringEncoding]];
        
        if (ipsecConf.shareSecret.length > 0)
        {
            protocol.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
            protocol.sharedSecretReference = [self getKeyChainReferenceWithIdentifier:@"VPN_SHARESECRET" data:[ipsecConf.shareSecret dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else
        {
            protocol.authenticationMethod = NEVPNIKEAuthenticationMethodNone;
        }
        
        applyProtocol = protocol;
    }
    
    if (applyProtocol)
    {
        BOOL needReload = NO;
        if (!self.vpnManager.protocol)
        {
            needReload = YES;
        }
        
        self.vpnManager.protocol = applyProtocol;
        self.vpnManager.localizedDescription = @"CY Browser";
        
        self.vpnManager.enabled = YES;
        
        self.isSavingConfig = YES;
        
        __weak MOBVPNConnector *theConnector = self;
        [self.vpnManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            
            NSLog(@"=========== save config success");
            
            theConnector.isSavingConfig = NO;
            
            if (error)
            {
                if (theConnector.errorHandler)
                {
                    theConnector.errorHandler (error);
                }
            }
            
            if (needReload && [MOBFDevice versionCompare:@"9.0"] != NSOrderedAscending)
            {
                [self.vpnManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                    
                    if (error)
                    {
                        if (theConnector.errorHandler)
                        {
                            theConnector.errorHandler (error);
                        }
                    }
                    
                }];
            }
            
        }];
    }
    else
    {
        if (!self.isSavingConfig && self.vpnManager.protocol)
        {
            self.vpnManager.protocol.username = nil;
            self.vpnManager.protocol.passwordReference = nil;
            [self.vpnManager saveToPreferencesWithCompletionHandler:nil];
        }
    }
}

/**
 *  获取安全数据容器
 *
 *  @return 安全数据容器
 */
- (NSData *) getKeyChainReferenceWithIdentifier:(NSString *)identifier data:(NSData *)data
{
    static NSString * const ServiceName = @"com.mob.vpn.config";
    
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrService] = ServiceName;
    
    SecItemDelete((__bridge CFDictionaryRef)searchDictionary);
    
    [searchDictionary setObject:data forKey:(__bridge id)kSecValueData];
    
    
    NSInteger ret = SecItemAdd((__bridge CFDictionaryRef)searchDictionary, NULL);
    if (ret != noErr)
    {
        return nil;
    }
    
    searchDictionary[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    searchDictionary[(__bridge id)kSecReturnPersistentRef] = (__bridge id _Nullable)(kCFBooleanTrue);
    
    CFDataRef dataResult = NULL;
    SecItemCopyMatching((CFDictionaryRef)searchDictionary, (CFTypeRef *)&dataResult);
    
    return (__bridge_transfer NSData *)dataResult;
}

/**
 *  初始化
 */
- (void) setup
{
    __weak MOBVPNConnector *theConnector = self;
    [self.vpnManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        
        if (error)
        {
            if (theConnector.errorHandler)
            {
                theConnector.errorHandler (error);
            }
            
            return;
        }
        
        theConnector.hasReady = YES;
        if (theConnector.readyHandler)
        {
            theConnector.readyHandler ();
        }
        
        if (theConnector.config)
        {
            [theConnector applyConfig];
        }
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vpnStatusDidChangeHandler:)
                                                 name:NEVPNStatusDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vpnConfigDidChangeHandler:)
                                                 name:NEVPNConfigurationChangeNotification
                                               object:nil];
}

- (void) vpnStatusDidChangeHandler:(NSNotification *)notif
{
    NSLog(@"status == %ld", (long)self.status);
    if (self.statusChangeHandler)
    {
        self.statusChangeHandler (self.vpnManager.connection.status);
    }
}

- (void) vpnConfigDidChangeHandler:(NSNotification *)notif
{
    NSLog(@"config did change ======");

    if (self.configChangedHandler)
    {
        self.configChangedHandler ();
    }
}

@end
