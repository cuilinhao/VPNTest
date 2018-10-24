//
//  MOBCPinger.m
//  Mobconv
//
//  Created by fenghj on 15/11/4.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "MOBCPinger.h"
#import "MOBCSimplePing.h"
#import <MOBFoundation/MOBFDebug.h>

@interface MOBCPinger () <MOBCSimplePingDelegate>

/**
 *  地址
 */
@property (nonatomic, copy) NSString *address;

/**
 *  次数
 */
@property (nonatomic) NSInteger count;

/**
 *  总次数
 */
@property (nonatomic) NSInteger totalCount;

/**
 *  超时计时器
 */
@property (nonatomic) NSTimer *timeoutTimer;

/**
 *  Ping对象
 */
@property (nonatomic, strong) MOBCSimplePing *pinger;

/**
 *  发送数
 */
@property (nonatomic) NSInteger sendCount;

/**
 *  接收数
 */
@property (nonatomic) NSInteger recvCount;

/**
 *  最长时间
 */
@property (nonatomic) CFAbsoluteTime maxTime;

/**
 *  最短时间
 */
@property (nonatomic) CFAbsoluteTime minTime;

/**
 *  总时间
 */
@property (nonatomic) CFAbsoluteTime totalTime;

/**
 *  发送时间
 */
@property (nonatomic) CFAbsoluteTime sendTime;

/**
 *  完成回调
 */
@property (nonatomic, copy) void (^completedHandler) (NSDictionary *statusInfo);

@end

@implementation MOBCPinger

- (instancetype) initWithAddress:(NSString *)address
{
    if (self = [super init])
    {
        self.address = address;
        self.count = 0;
        self.pinger = [MOBCSimplePing simplePingWithHostName:address];
        self.pinger.delegate = self;
    }
    
    return self;
}

- (void) ping:(NSInteger)count
  onCompleted:(void (^) (NSDictionary *statusInfo))handler
{
    [self _reset];
    
    self.totalCount = count;
    self.completedHandler = handler;
    [self.pinger start];
}

- (void)dealloc
{
    [self.pinger stop];
}

#pragma mark - Private

/**
 *  重置数据
 */
- (void) _reset
{
    self.count = 0;
    
    self.sendCount = 0;
    self.recvCount = 0;
    self.maxTime = 0;
    self.minTime = 0;
    self.totalTime = 0;
}

/**
 *  返回
 */
- (void) _result
{
    if (self.completedHandler)
    {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        CFAbsoluteTime avageTime = 0;
        if (self.minTime > 0)
        {
            avageTime = self.totalTime / self.recvCount * 1000;
        }
        
        info [self.address] = @[@(self.sendCount), @(self.recvCount), @(self.sendCount - self.recvCount), @(self.maxTime * 1000), @(self.minTime * 1000), @(avageTime)];
        
        self.completedHandler (info);
        self.completedHandler = nil;
        
        [self.pinger stop];
    }
}

/**
 *  发送Ping数据
 */
- (void) _sendPing
{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    
    if (self.count < self.totalCount)
    {
        self.sendTime = CFAbsoluteTimeGetCurrent();
        [self.pinger sendPingWithData:nil];
        
        self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(_pingTimeout) userInfo:nil repeats:NO];
    }
    else
    {
        //返回结果
        [self _result];
        [self _reset];
    }
}

/**
 *  发送下一个Ping数据
 */
- (void) _nextPing
{
    self.count ++;
    [self performSelector:@selector(_sendPing) withObject:nil afterDelay:0.1];
}

/**
 *  统计耗时
 *
 *  @param costTime 时间
 */
- (void) _statCostTime:(CFAbsoluteTime)costTime
{
    if (costTime > self.maxTime)
    {
        self.maxTime = costTime;
    }
    if (costTime <  self.minTime || self.minTime == 0)
    {
        self.minTime = costTime;
    }
    self.totalTime += costTime;
}

/**
 *  Ping超时
 */
- (void) _pingTimeout
{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
    
    [self _nextPing];
}

#pragma mark - MOBCSimplePingDelegate

- (void) simplePing:(MOBCSimplePing *)pinger didStartWithAddress:(NSData *)address
{
    [MOBFDebug log:@"didStartWithAddress"];
    
    //发送Ping数据
    [self _sendPing];
}

- (void) simplePing:(MOBCSimplePing *)pinger didFailWithError:(NSError *)error
{
    [MOBFDebug log:@"didFailWithError"];
    
    //返回回调
    [self _result];
    [self _reset];
}

- (void) simplePing:(MOBCSimplePing *)pinger didSendPacket:(NSData *)packet
{
    [MOBFDebug log:@"didSendPacket"];
    
    self.sendCount ++;
}

- (void) simplePing:(MOBCSimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error
{
    [MOBFDebug log:@"didFailToSendPacket"];
    
    //累计次数，并进行下一次发送
    [self _nextPing];
}

- (void) simplePing:(MOBCSimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet
{
    [MOBFDebug log:@"didReceivePingResponsePacket"];
    
    self.recvCount ++;
    [self _statCostTime:CFAbsoluteTimeGetCurrent() - self.sendTime];
    
    //累计次数，并进行下一次发送
    [self _nextPing];
}

- (void) simplePing:(MOBCSimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    [MOBFDebug log:@"didReceiveUnexpectedPacket"];
    
    self.recvCount ++;
    [self _statCostTime:CFAbsoluteTimeGetCurrent() - self.sendTime];
    
    //累计次数，并进行下一次发送
    [self _nextPing];
}

@end
