//
//  APIService.m
//  VPNConnector
//
//  Created by fenghj on 15/12/14.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "APIService.h"
#import "HostInfo.h"
#import "Context_Private.h"
#import <ShareSDK/ShareSDK.h>
#import <MOBFoundation/MOBFoundation.h>
#import <AVOSCloud/AVOSCloud.h>

static NSString *const DefaultBaseUrl = @"http://47.52.151.238:5566";
static NSString *const ErrorDomain = @"VPNConnectorError";

static NSTimeInterval timeFixed = 0;
static NSTimeInterval TimeOut = 15;

static dispatch_queue_t queue;
static dispatch_semaphore_t semaphore;

static BOOL checkingHost = NO;

/**
 *  令牌键名
 */
static NSString *token = nil;

@implementation APIService

+ (NSString *)idfv
{
    static NSString *idfv = nil;
    
    if (!idfv)
    {
        MOBFDataService *dataService = [MOBFDataService sharedInstance];
        [dataService beginSecureDataTrans];
        
        //检测是否在keychain中存在
        idfv = [dataService secureDataForKey:@"idfv"];
        
        if (!idfv)
        {
            idfv = [MOBFDevice idfv];
            [dataService setSecureData:idfv forKey:@"idfv"];
        }
        
        [dataService endSecureDataTrans];
    }
    
    return idfv;
}

+ (NSString *)duid
{
    static NSString *duid = nil;
    
    if (!duid)
    {
        MOBFDataService *dataService = [MOBFDataService sharedInstance];
        [dataService beginSecureDataTrans];
        
        //检测是否在keychain中存在
        duid = [dataService secureDataForKey:@"udid"];
        
        if (!duid)
        {
            duid = [MOBFDevice duid];
            [dataService setSecureData:duid forKey:@"udid"];
        }
        
        [dataService endSecureDataTrans];
    }
    
    return duid;
}

+ (NSString *)userId
{
    User *user = [Context sharedInstance].currentUser;
    if (user)
    {
        return user.userId;
    }
    
    return nil;
}

/*
+ (void) getHostList:(void (^) (NSArray *list))handler
{
    [self getToken:^(NSString *token) {
        
        if (token)
        {
            //更新主机列表
            NSMutableDictionary *params = [self standardParams];
            NSString *userId = [self userId];
            if (userId)
            {
                [params setObject:userId forKey:@"uid"];
            }
            [params setObject:[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] + timeFixed] forKey:@"timestamp"];
            
            MOBFHttpService *service = [[MOBFHttpService alloc] initWithURLString:[self getRequestURL:@"/host/list"]];
            [service setMethod:@"POST"];
            
            NSData *bodyData = [self encryptParams:params token:token];
            NSString *hashStr = [MOBFData hexStringByData:[MOBFData md5Data:bodyData]];
            
            [service addHeader:@"token" value:token];
            [service addHeader:@"hash" value:hashStr];
            [service setBody:bodyData];
            
            [service sendRequestOnResult:^(NSHTTPURLResponse *response, NSData *responseData) {
                
                NSDictionary *responder = [MOBFJson objectFromJSONData:[self decryptResponse:responseData token:token]];
                NSLog(@"hosts responder = %@", responder);
                if ([responder [@"status"] integerValue] == 200)
                {
                    NSMutableArray *hostArr = nil;
                    NSArray *hosts = responder [@"hosts"];
                    if ([hosts isKindOfClass:[NSArray class]])
                    {
                        hostArr = [NSMutableArray array];
                        [hosts enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            HostInfo *info = [[HostInfo alloc] initWithRawData:obj];
                            [hostArr addObject:info];
                            
                        }];
                    }
                    
                    if (handler)
                    {
                        handler (hostArr);
                    }
                }
                else
                {
                    if (handler)
                    {
                        handler (nil);
                    }
                }
                
            } onFault:^(NSError *error) {
                
                [self checkHostWithError:error];
                
                if (handler)
                {
                    handler (nil);
                }
                
            } onUploadProgress:nil];

        }
        else
        {
            if (handler)
            {
                handler (nil);
            }
        }
        
    }];

}
 */

+ (void) getVipStatusWithUserId:(NSString *)userId
                       onResult: (void (^) (NSDate *vipDate, NSError *error))handler;
{
    [self getToken:^(NSString *token) {
        
        if (token)
        {
            NSMutableDictionary *params = [self standardParams];
            
            //写入用户标识
            if (userId)
            {
                [params setObject:userId forKey:@"uid"];
            }
            
            [params setObject:[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] + timeFixed] forKey:@"timestamp"];
            
            MOBFHttpService *service = [[MOBFHttpService alloc] initWithURLString:[self getRequestURL:@"/vip/status"]];
            [service setMethod:@"POST"];
            service.timeout = TimeOut;
            
            NSData *bodyData = [self encryptParams:params token:token];
            NSString *hashStr = [MOBFData hexStringByData:[MOBFData md5Data:bodyData]];
            
            [service addHeader:@"token" value:token];
            [service addHeader:@"hash" value:hashStr];
            [service setBody:bodyData];
            
            [service sendRequestOnResult:^(NSHTTPURLResponse *response, NSData *responseData) {
                
                NSDictionary *responder = [MOBFJson objectFromJSONData:[self decryptResponse:responseData token:token]];
                if ([responder [@"status"] integerValue] == 200)
                {
                    NSDate *vipDate = nil;
                    
                    if ([responder[@"vip"] boolValue])
                    {
                        vipDate = [[NSDate alloc] initWithTimeIntervalSince1970:[responder[@"expire"] doubleValue] / 1000];
                    }
                    
                    if (handler)
                    {
                        handler (vipDate, nil);
                    }
                }
                else
                {
                    if (handler)
                    {
                        handler (nil, [NSError errorWithDomain:ErrorDomain code:[responder[@"status"] integerValue] userInfo:nil]);
                    }
                }
                
            } onFault:^(NSError *error) {
              
                [self checkHostWithError:error];
                
                if (handler)
                {
                    handler (nil, error);
                }
                
            } onUploadProgress:nil];
        }
        else
        {
            if (handler)
            {
                handler (nil, [NSError errorWithDomain:ErrorDomain code:0 userInfo:nil]);
            }
        }
        
    }];
}

+ (void) buy:(NSString *)productId
 receiptData:(NSData *)receiptData
     expired:(NSDate *)expired
      userId:(NSString *)userId
      result:(void(^)(NSError *error))handler
{
    [self getToken:^(NSString *token) {
       
        if (token)
        {
            NSMutableDictionary *params = [self standardParams];
            if (userId)
            {
                //设置用户标识
                [params setObject:userId forKey:@"uid"];
            }
            
            [params setObject:productId forKey:@"item"];
            [params setObject:[NSString stringWithFormat:@"%.0f", [expired timeIntervalSince1970] * 1000] forKey:@"expireAt"];
            [params setObject:[MOBFData stringByBase64EncodeData:receiptData] forKey:@"receiptData"];
            
            MOBFHttpService *service = [[MOBFHttpService alloc] initWithURLString:[self getRequestURL:@"/buy"]];
            [service setMethod:@"POST"];
            service.timeout = TimeOut;
            
            NSData *bodyData = [self encryptParams:params token:token];
            NSString *hashStr = [MOBFData hexStringByData:[MOBFData md5Data:bodyData]];
            
            [service addHeader:@"token" value:token];
            [service addHeader:@"hash" value:hashStr];
            [service setBody:bodyData];
            
            [service sendRequestOnResult:^(NSHTTPURLResponse *response, NSData *responseData) {
                
                NSDictionary *responder = [MOBFJson objectFromJSONData:[self decryptResponse:responseData token:token]];
                NSLog(@"send receipt response = %@", responder);
                
                if ([responder [@"status"] integerValue] == 200)
                {
                    if (handler)
                    {
                        handler (nil);
                    }
                }
                else
                {
                    if (handler)
                    {
                        handler ([NSError errorWithDomain:ErrorDomain code:[responder[@"status"] integerValue] userInfo:nil]);
                    }
                }
                
            } onFault:^(NSError *error) {
                
                [self checkHostWithError:error];
                
                if (handler)
                {
                    handler (error);
                }
                
            } onUploadProgress:nil];
        }
        else
        {
            if (handler)
            {
                handler ([NSError errorWithDomain:ErrorDomain code:-100 userInfo:@{@"message" : @"miss token"}]);
            }
        }
        
    }];
}

+ (void) loginWithAccount:(NSString *)account
                 password:(NSString *)password
                   result:(void(^)(BOOL success, NSString *uid, NSString *errorMessage))handler
{
    [self getToken:^(NSString *token) {
        
        if (token)
        {
            NSMutableDictionary *params = [self standardParams];
            if (account)
            {
                [params setObject:account forKey:@"account"];
            }
            if (password)
            {
                [params setObject:password forKey:@"password"];
            }
            
            MOBFHttpService *service = [[MOBFHttpService alloc] initWithURLString:[self getRequestURL:@"/user/login"]];
            [service setMethod:@"POST"];
            service.timeout = TimeOut;
            
            NSData *bodyData = [self encryptParams:params token:token];
            NSString *hashStr = [MOBFData hexStringByData:[MOBFData md5Data:bodyData]];
            
            [service addHeader:@"token" value:token];
            [service addHeader:@"hash" value:hashStr];
            [service setBody:bodyData];
            
            [service sendRequestOnResult:^(NSHTTPURLResponse *response, NSData *responseData) {
                
                NSDictionary *responder = [MOBFJson objectFromJSONData:[self decryptResponse:responseData token:token]];
                NSLog(@"send receipt response = %@", responder);
                
                if ([responder [@"status"] integerValue] == 200)
                {
                    if (handler)
                    {
                        handler (YES, responder[@"uid"], nil);
                    }
                }
                else
                {
                    if (handler)
                    {
                        handler (NO, nil, responder[@"message"]);
                    }
                }
                
            } onFault:^(NSError *error) {
                
                [self checkHostWithError:error];
                
                if (handler)
                {
                    handler (NO, nil, @"LOGIN_FAIL_MESSAGE");
                }
                
            } onUploadProgress:nil];
        }
        else
        {
            if (handler)
            {
                handler (NO, nil, @"LOGIN_FAIL_MESSAGE");
            }
        }
        
    }];
}

+ (void) signUpWithAccount:(NSString *)account
                  password:(NSString *)password
                    result:(void(^)(BOOL success, NSString *uid, NSString *errorMessage))handler
{
    [self getToken:^(NSString *token) {
        
        if (token)
        {
            NSMutableDictionary *params = [self standardParams];
            if (account)
            {
                [params setObject:account forKey:@"account"];
            }
            if (password)
            {
                [params setObject:password forKey:@"password"];
            }
            
            MOBFHttpService *service = [[MOBFHttpService alloc] initWithURLString:[self getRequestURL:@"/user/register"]];
            [service setMethod:@"POST"];
            service.timeout = TimeOut;
            
            NSData *bodyData = [self encryptParams:params token:token];
            NSString *hashStr = [MOBFData hexStringByData:[MOBFData md5Data:bodyData]];
            
            [service addHeader:@"token" value:token];
            [service addHeader:@"hash" value:hashStr];
            [service setBody:bodyData];
            
            [service sendRequestOnResult:^(NSHTTPURLResponse *response, NSData *responseData) {
                
                NSDictionary *responder = [MOBFJson objectFromJSONData:[self decryptResponse:responseData token:token]];
                NSLog(@"send receipt response = %@", responder);
                
                if ([responder [@"status"] integerValue] == 200)
                {
                    if (handler)
                    {
                        handler (YES, responder[@"uid"], nil);
                    }
                }
                else
                {
                    if (handler)
                    {
                        handler (NO, nil, responder[@"message"]);
                    }
                }
                
            } onFault:^(NSError *error) {
                
                [self checkHostWithError:error];
                
                if (handler)
                {
                    handler (NO, nil, @"SIGNUP_FAIL_MESSAGE");
                }
                
            } onUploadProgress:nil];
        }
        else
        {
            if (handler)
            {
                handler (NO, nil, @"SIGNUP_FAIL_MESSAGE");
            }
        }
        
    }];
}

+ (void)sendLogs:(NSArray<NSString *> *)logs
          result:(void (^)(NSError *error))handler
{
    NSString *logText = [logs componentsJoinedByString:@"\r\n"];
    NSData *logData = [MOBFData compressDataUsingGZip:[logText dataUsingEncoding:NSUTF8StringEncoding]];
    
    MOBFHttpService *service = [[MOBFHttpService alloc] initWithURLString:[self getRequestURL:@"/log"]];
    [service setMethod:@"POST"];
    [service setBody:logData];
    service.timeout = TimeOut;
    
    [service sendRequestOnResult:^(NSHTTPURLResponse *response, NSData *responseData) {
        
        NSDictionary *responder = [MOBFJson objectFromJSONData:responseData];
        NSLog(@"send receipt response = %@", responder);
        
        if ([responder [@"status"] integerValue] == 200)
        {
            if (handler)
            {
                handler (nil);
            }
        }
        else
        {
            if (handler)
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:responder, @"responder", nil];
                NSError *err = [NSError errorWithDomain:@"APIServiceErrorDomain" code:100 userInfo:userInfo];
                handler (err);
            }
        }
        
    } onFault:^(NSError *error) {
        
        [self checkHostWithError:error];
        
        if (handler)
        {
            handler (error);
        }
        
    } onUploadProgress:nil];
}

+ (void)getBootAd:(void (^)(NSArray *adList, NSError *error))handler
{
    [self getBootAdListByLeanCloud:^(NSArray<Ad *> *adList, NSError *error) {
       
        if (!error)
        {
            if (handler)
            {
                handler (adList, error);
            }
        }
        else
        {
            [self getBootAdListByGithub:handler];
        }
        
    }];
}

#pragma mark - Private

/**
 获取请求地址

 @param path 路径
 @return 请求地址
 */
+ (NSString *)getRequestURL:(NSString *)path
{
    NSString *baseUrl = [[NSUserDefaults standardUserDefaults] stringForKey:@"BaseUrl"];
    if (!baseUrl)
    {
        baseUrl = DefaultBaseUrl;
    }
    
    return [NSString stringWithFormat:@"%@%@", baseUrl, path];
}


/**
 检测连接地址是否可用

 @param error 错误
 */
+ (void)checkHostWithError:(NSError *)error
{
    if (!checkingHost)
    {
        checkingHost = YES;
        
        dispatch_async(queue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            //重置令牌
            token = nil;
            
            [APIService getHostByLeanCloud:^(NSString *encHostStr) {
                
                if (!encHostStr)
                {
                    [APIService getHostByGithub:^(NSString *encHostStr) {
                        
                        if (encHostStr)
                        {
                            [APIService decryptHostStr:encHostStr];
                        }
                        
                        checkingHost = NO;
                        dispatch_semaphore_signal(semaphore);
                        
                    }];
                }
                else
                {
                    [APIService decryptHostStr:encHostStr];
                    
                    checkingHost = NO;
                    dispatch_semaphore_signal(semaphore);
                }
                
            }];
            
        });
    }
}


/**
 通过LeanCloud获取启动广告列表

 @param handler 返回处理
 */
+ (void)getBootAdListByLeanCloud:(void (^)(NSArray<Ad *> *adList, NSError *error))handler
{
    AVQuery *query = [AVQuery queryWithClassName:@"Config"];
    [query selectKeys:@[@"name", @"value"]];
    [query whereKey:@"name" equalTo:@"boot"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (objects.count > 0)
        {
            AVObject *object = objects.firstObject;
            id value = [object objectForKey:@"value"];
            if ([value isKindOfClass:[NSString class]])
            {
                NSDictionary *boots = [MOBFJson objectFromJSONString:value];
                if (handler)
                {
                    handler (boots[@"boots"], nil);
                }
            }
            else
            {
                if (handler)
                {
                    handler (nil, nil);
                }
            }
        }
        else
        {
            if (handler)
            {
                handler (nil, error);
            }
        }
        
    }];
}


/**
 通过Github获取启动广告列表

 @param handler 返回处理
 */
+ (void)getBootAdListByGithub:(void (^)(NSArray<Ad *> *adList, NSError *error))handler
{
    //从Github上获取新的服务器地址
    [MOBFHttpService sendHttpRequestByURLString:@"https://raw.githubusercontent.com/cellv/VPNBrowser/master/boot.json"
                                         method:kMOBFHttpMethodGet
                                     parameters:nil
                                        headers:nil
                                       onResult:^(NSHTTPURLResponse *response, NSData *responseData) {
                                           
                                           if (response.statusCode == 200)
                                           {
                                               NSDictionary *boots = [MOBFJson objectFromJSONData:responseData];
                                               
                                               if (handler)
                                               {
                                                   handler (boots[@"boots"], nil);
                                               }
                                           }
                                           else
                                           {
                                               if (handler)
                                               {
                                                   handler (nil, nil);
                                               }
                                           }
                                           
                                       } onFault:^(NSError *error) {
                                           
                                           if (handler)
                                           {
                                               handler (nil, error);
                                           }
                                           
                                       } onUploadProgress:nil];
}

/**
 通过LeanCloud获取Host
 
 @param block 返回回调
 */
+ (void)getHostByLeanCloud:(void (^)(NSString *encHostStr))block
{
    AVQuery *query = [AVQuery queryWithClassName:@"Config"];
    [query selectKeys:@[@"name", @"value"]];
    [query whereKey:@"name" equalTo:@"host"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (objects.count > 0)
        {
            AVObject *object = objects.firstObject;
            id value = [object objectForKey:@"value"];
            if ([value isKindOfClass:[NSString class]])
            {
                NSString *responseStr = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (block)
                {
                    block (responseStr);
                }
            }
            else
            {
                if (block)
                {
                    block (nil);
                }
            }
        }
        else
        {
            if (block)
            {
                block (nil);
            }
        }
        
    }];
}


/**
 通过Github获取Host

 @param block 返回回调
 */
+ (void)getHostByGithub:(void (^)(NSString *encHostStr))block
{
    //从Github上获取新的服务器地址
    [MOBFHttpService sendHttpRequestByURLString:@"https://raw.githubusercontent.com/cellv/VPNBrowser/master/config"
                                         method:kMOBFHttpMethodGet
                                     parameters:nil
                                        headers:nil
                                       onResult:^(NSHTTPURLResponse *response, NSData *responseData) {
                                           
                                           if (response.statusCode == 200)
                                           {
                                               NSString *responseStr = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                               
                                               if (block)
                                               {
                                                   block (responseStr);
                                               }
                                           }
                                           else
                                           {
                                               if (block)
                                               {
                                                   block (nil);
                                               }
                                           }
                                           
                                       } onFault:^(NSError *error) {
                                           
                                           if (block)
                                           {
                                               block (nil);
                                           }
                                           
                                       } onUploadProgress:nil];
}


/**
 解密主机地址

 @param hostStr 加密的主机地址
 */
+ (void)decryptHostStr:(NSString *)hostStr
{
    NSData *data = [MOBFString dataByBase64DecodeString:hostStr];
    NSData *keyData = [MOBFData md5Data:[[MOBFApplication bundleId] dataUsingEncoding:NSUTF8StringEncoding]];
    data = [MOBFData aes128DecryptData:data key:keyData options:kCCOptionPKCS7Padding | kCCOptionECBMode];
    
    NSString *baseUrl = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Refresh host success = %@", baseUrl);
    
    [[NSUserDefaults standardUserDefaults] setObject:baseUrl forKey:@"BaseUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  获取令牌
 *
 *  @param handler 回调方法
 */
+ (void) getToken:(void (^) (NSString *token))handler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        semaphore = dispatch_semaphore_create(1);
        queue = dispatch_queue_create("RequestQueue", DISPATCH_QUEUE_SERIAL);
    });
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if (token)
        {
            dispatch_semaphore_signal(semaphore);
            
            if (handler)
            {
                handler (token);
            }
        }
        else
        {
            //组织参数
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           @"IOS", @"plat",
                                           [MOBFDevice macAddress], @"mac",
                                           [self idfv], @"idfa",
                                           [self duid], @"udid",
                                           nil];
            [params setObject:[NSString stringWithFormat:@"%@ %@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion] forKey:@"sysver"];
            [params setObject:@"apple" forKey:@"factory"];
            [params setObject:[MOBFDevice deviceModel] forKey:@"model"];
            
            MOBFHttpService *service = [[MOBFHttpService alloc] initWithURLString:[self getRequestURL:@"/token"]];
            [service setMethod:@"POST"];
            NSData *bodyData = [self encryptParams:params token:nil];
            
            NSString *hashStr = [MOBFData hexStringByData:[MOBFData md5Data:bodyData]];
            [service addHeader:@"hash" value:hashStr];
            [service setBody:bodyData];
            service.timeout = TimeOut;
            
            [service sendRequestOnResult:^(NSHTTPURLResponse *response, NSData *responseData) {
                
                NSDictionary *responder = [MOBFJson objectFromJSONData:[self decryptResponse:responseData token:nil]];
                NSLog(@"get token responder = %@", responder);
                if ([responder [@"status"] integerValue] == 200)
                {
                    [Context sharedInstance].deviceId = responder [@"did"];
                    token = responder [@"token"];
                    timeFixed = [responder[@"timestamp"] doubleValue] - [[NSDate date] timeIntervalSince1970];
                    
                    if (handler)
                    {
                        handler (token);
                    }
                }
                else
                {
                    NSLog(@"get token error = (%ld) %@", (long)response.statusCode, [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]);
                    
                    if (handler)
                    {
                        handler (nil);
                    }
                }
                
                dispatch_semaphore_signal(semaphore);
                
            } onFault:^(NSError *error) {
                
                NSLog(@"get token error = %@", error);
                [self checkHostWithError:error];
                
                if (handler)
                {
                    handler (nil);
                }
                
                dispatch_semaphore_signal(semaphore);
                
            } onUploadProgress:nil];
        }
        
    });
    
}

/**
 *  加密参数
 *
 *  @param params 参数集合
 *  @param token  令牌
 *
 *  @return 加密数据
 */
+ (NSData *) encryptParams:(NSMutableDictionary *)params token:(NSString *)token
{
    static NSString *const AESKey = @"4ae3c5b5cf79fc09aba5f9a7c006f707";
    
    NSData *data = [MOBFJson jsonDataFromObject:params];
    
    //手动填充空格符
    NSMutableData *srcData = [NSMutableData dataWithData:data];
    NSInteger count = 16 - srcData.length % 16;
    if (count > 0)
    {
        static Byte padding = ' ';
        for (int i = 0; i < count; i++)
        {
            [srcData appendBytes:(const void *)&padding length:1];
        }
    }
    
    NSData *key = nil;
    if (token)
    {
        key = [MOBFData md5Data:[token dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
        key = [MOBFString dataByHexString:AESKey];
    }
    
    return [MOBFData aes128EncryptData:srcData key:key options:kCCOptionPKCS7Padding | kCCOptionECBMode];
}

/**
 *  解密回复数据
 *
 *  @param data  回复数据
 *  @param token 令牌
 *
 *  @return 解密后数据
 */
+ (NSData *) decryptResponse:(NSData *)data token:(NSString *)token
{
    static NSString *const AESKey = @"4ae3c5b5cf79fc09aba5f9a7c006f707";
    
    NSData *key = nil;
    if (token)
    {
        key = [MOBFData md5Data:[token dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
    {
        key = [MOBFString dataByHexString:AESKey];
    }
    
    return [MOBFData aes128DecryptData:data key:key options:kCCOptionPKCS7Padding | kCCOptionECBMode];
}

/**
 *  获取基础参数集合
 *
 *  @return 参数集合
 */
+ (NSMutableDictionary *)standardParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"IOS", @"plat",
                                   [Context sharedInstance].deviceId, @"did",
                                   nil];
    return params;
}

@end
