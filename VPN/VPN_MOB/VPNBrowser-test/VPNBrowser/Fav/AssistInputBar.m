//
//  AssistInputBar.m
//  VPNConnector
//
//  Created by fenghj on 15/12/22.
//  Copyright © 2015年 vimfung. All rights reserved.
//

#import "AssistInputBar.h"
#import <MOBFoundation/MOBFoundation.h>

static const CGFloat Gap = 8.0;

@interface AssistInputBar ()

/**
 *  按钮列表
 */
@property (nonatomic, strong) NSMutableArray *buttonList;

/**
 *  内容宽度
 */
@property (nonatomic) CGFloat contentWidth;

/**
 *  辅助文本事件处理器
 */
@property (nonatomic, copy) void (^textHandler) (NSString *text);

@end

@implementation AssistInputBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        static const CGFloat Spacing = 7;
        
        self.backgroundColor = [MOBFColor colorWithRGB:0xc8c8c8];
        
        self.buttonList = [NSMutableArray array];
        self.contentWidth = 0.0;
        
        //www.
        UIButton *wwwBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        wwwBtn.backgroundColor = [UIColor whiteColor];
        wwwBtn.layer.cornerRadius = 4;
        [wwwBtn setTitle:@"www." forState:UIControlStateNormal];
        [wwwBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [wwwBtn sizeToFit];
        wwwBtn.frame = CGRectMake(0.0, 0.0, wwwBtn.frame.size.width + 2 * Spacing, wwwBtn.frame.size.height);
        [wwwBtn addTarget:self action:@selector(textButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonList addObject:wwwBtn];
        [self addSubview:wwwBtn];
        
        self.contentWidth += wwwBtn.frame.size.width + Gap;
        
        //.
        UIButton *dotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        dotBtn.backgroundColor = [UIColor whiteColor];
        dotBtn.layer.cornerRadius = 4;
        [dotBtn setTitle:@"." forState:UIControlStateNormal];
        [dotBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dotBtn sizeToFit];
        dotBtn.frame = CGRectMake(0.0, 0.0, dotBtn.frame.size.width + 2 * Spacing, dotBtn.frame.size.height);
        [dotBtn addTarget:self action:@selector(textButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonList addObject:dotBtn];
        [self addSubview:dotBtn];
        
        self.contentWidth += dotBtn.frame.size.width + Gap;
        
        //斜杆
        UIButton *diagonalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        diagonalBtn.backgroundColor = [UIColor whiteColor];
        diagonalBtn.layer.cornerRadius = 4;
        [diagonalBtn setTitle:@"/" forState:UIControlStateNormal];
        [diagonalBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [diagonalBtn sizeToFit];
        diagonalBtn.frame = CGRectMake(0.0, 0.0, diagonalBtn.frame.size.width + 2 * Spacing, diagonalBtn.frame.size.height);
        [diagonalBtn addTarget:self action:@selector(textButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonList addObject:diagonalBtn];
        [self addSubview:diagonalBtn];
        
        self.contentWidth += diagonalBtn.frame.size.width + Gap;
        
        //.cn
        UIButton *cnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cnBtn.backgroundColor = [UIColor whiteColor];
        cnBtn.layer.cornerRadius = 4;
        [cnBtn setTitle:@".cn" forState:UIControlStateNormal];
        [cnBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cnBtn sizeToFit];
        cnBtn.frame = CGRectMake(0.0, 0.0, cnBtn.frame.size.width + 2 * Spacing, cnBtn.frame.size.height);
        [cnBtn addTarget:self action:@selector(textButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonList addObject:cnBtn];
        [self addSubview:cnBtn];
        
        self.contentWidth += cnBtn.frame.size.width + Gap;
        
        //.com
        UIButton *comBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        comBtn.backgroundColor = [UIColor whiteColor];
        comBtn.layer.cornerRadius = 4;
        [comBtn setTitle:@".com" forState:UIControlStateNormal];
        [comBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [comBtn sizeToFit];
        comBtn.frame = CGRectMake(0.0, 0.0, comBtn.frame.size.width + 2 * Spacing, comBtn.frame.size.height);
        [comBtn addTarget:self action:@selector(textButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonList addObject:comBtn];
        [self addSubview:comBtn];
        
        self.contentWidth += comBtn.frame.size.width;

    }
    return self;
}

- (void)onText:(void (^)(NSString *content))handler
{
    self.textHandler = handler;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    __weak AssistInputBar *theBar = self;
    __block CGFloat left = (self.frame.size.width - self.contentWidth) / 2;
    [self.buttonList enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.frame = CGRectMake(left, (theBar.frame.size.height - obj.frame.size.height) / 2, obj.frame.size.width, obj.frame.size.height);
        left += obj.frame.size.width + Gap;
    }];
}

#pragma mark - Private

/**
 *  文本按钮点击
 *
 *  @param sender 事件对象
 */
- (void)textButtonClickHandler:(UIButton *)sender
{
    if (self.textHandler)
    {
        self.textHandler (sender.titleLabel.text);
    }
}

@end
