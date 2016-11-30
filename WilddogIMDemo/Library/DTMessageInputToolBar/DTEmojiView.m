//
//  DTEmojiView.m
//  WildIMKitApp
//
//  Created by junpengwang on 16/3/7.
//  Copyright © 2016年 wilddog. All rights reserved.
//

#import "DTEmojiView.h"
#import "DTUtility.h"

#define DT_Lines    3
#define DT_TO_LEFT 18
#define DT_DELETE_TAG -1
int DT_FACE_SIZE = 41;

@interface DTEmojiView ()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) UIButton *sendBtn;

@end

@implementation DTEmojiView

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 50, DT_SCREEN_WIDTH, 216);
        self.backgroundColor = [DTUtility colorWithHex:@"f4f4f5"];
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self setup];
        
    }
    return self;
}

- (UIPageControl *)pageControl
{
    if (_pageControl == nil) {
        int pageControlHeight = 30.f;
        UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, DT_TO_LEFT + (DT_FACE_SIZE) * DT_Lines, DT_SCREEN_WIDTH, pageControlHeight)];
        pageControl.backgroundColor = self.backgroundColor;
        pageControl.hidesForSinglePage = YES;
        pageControl.defersCurrentPageDisplay = YES;
        int numPerLine = (DT_SCREEN_WIDTH - DT_TO_LEFT) / DT_FACE_SIZE;
        pageControl.numberOfPages = self.emojis.count / (DT_Lines * numPerLine - 1) + 1;
        pageControl.pageIndicatorTintColor = [DTUtility colorWithHex:@"bbbbbc"];
        pageControl.currentPageIndicatorTintColor = [DTUtility colorWithHex:@"8d8d8d"];
        
        
        [self addSubview:pageControl];
        self.pageControl = pageControl;

    }
    return _pageControl;
}

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        int gap = 40.f;
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-gap)];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        int numPerLine = (DT_SCREEN_WIDTH - DT_TO_LEFT) / DT_FACE_SIZE;
        NSInteger pageCount = [self emojis].count / (DT_Lines * numPerLine - 1) + 1;
        [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.bounds) * pageCount, CGRectGetHeight(_scrollView.bounds))];
    }
    return _scrollView;
}

- (UIButton *)sendBtn
{
    if (_sendBtn == nil) {
        int btnX = self.bounds.size.width - 60;
        int btnY = self.bounds.size.height - 35;
        int btnW = 60;
        int btnH = 35;
        self.sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_sendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_sendBtn];
    }
    return _sendBtn;
}

- (NSArray *)emojis
{
    NSBundle  *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"Emoji" ofType:@"plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    return array;
}

- (void)setup
{
    
    int numPerLine = (DT_SCREEN_WIDTH - DT_TO_LEFT) / DT_FACE_SIZE;
    DT_FACE_SIZE = (DT_SCREEN_WIDTH - DT_TO_LEFT * 2) / numPerLine;
    

    for (int i = 0 ; i < [self emojis].count; i++){
        
        int col = i % numPerLine;
        int row = i / numPerLine % DT_Lines;
        int page = i / (numPerLine * DT_Lines);
        
        UIButton *factButton = [UIButton buttonWithType:UIButtonTypeCustom];
        factButton.titleLabel.font = [UIFont systemFontOfSize:30];
        
        factButton.frame = CGRectMake(CGRectGetWidth(self.bounds) * page + DT_TO_LEFT + (DT_FACE_SIZE ) * col,
                                DT_TO_LEFT + (DT_FACE_SIZE) * row,
                                DT_FACE_SIZE,
                                DT_FACE_SIZE);
        [self.scrollView addSubview:factButton];
        
        if (i == ((numPerLine * DT_Lines ) * (page + 1) - 1)) {
            [factButton setImage:[UIImage imageNamed:@"ToolViewDeleteEmoji"]
                              forState:UIControlStateNormal];
            factButton.tag = DT_DELETE_TAG;
            
        }else{
            int index = i - page;
            NSString *emoji = (index < self.emojis.count) ? self.emojis[index] : @"";
            [factButton setTitle:emoji
                              forState:UIControlStateNormal];
        }
        [factButton addTarget:self
                             action:@selector(faceClick:)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self pageControl];
    [self sendBtn];
}

- (void)faceClick:(UIButton *)button
{
    if (button.tag == DT_DELETE_TAG) {
        if ([_delegate respondsToSelector:@selector(faceViewDidDelete)]) {
            [_delegate faceViewDidDelete];
        }
    }
    else{
        if ([_delegate respondsToSelector:@selector(faceViewDidSelected:)]) {
            [_delegate faceViewDidSelected:[button titleForState:UIControlStateNormal]];
        }
    }
}

- (void)sendAction:(id)sender
{
    if ([_delegate respondsToSelector:@selector(sendEmojiAction:)]) {
        [_delegate sendEmojiAction:nil];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.pageControl setCurrentPage:currentPage];
}

@end
