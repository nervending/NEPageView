//
//  NEPageView.m
//  NEPageView
//
//  Created by virl on 14/11/28.
//  Copyright (c) 2014年 virl. All rights reserved.
//

#import "NEPageView.h"

@interface NEPageView() <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIPageControl* pageControl;

@end

@implementation NEPageView {
    NSMutableArray* _unusedViews;
    NSNumber* _currentPageIndex;
    NSMutableDictionary* _pageMap;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        
        _unusedViews = [NSMutableArray new];
        _currentPageIndex = @0;
        _pageControl = [[UIPageControl alloc] init];
        _pageMap = [NSMutableDictionary new];
        self.indicatorBottomMargin = 10;
        
        [self addSubview:_scrollView];
        [self addSubview:_pageControl];
    }
    return self;
}

-(void)layoutSubviews {
    _scrollView.frame = self.bounds;
    CGRect frame = _pageControl.frame;
    frame.origin.x = (self.bounds.size.width - _pageControl.frame.size.width) / 2;
    frame.origin.y = self.bounds.size.height - _pageControl.frame.size.height-self.indicatorBottomMargin;
    _pageControl.frame = frame;
    [self configScrollViewContent];
}

-(void)setIndicatorBottomMargin:(CGFloat)indicatorBottomMargin {
    _indicatorBottomMargin = indicatorBottomMargin;
    CGRect frame = _pageControl.frame;
    frame.origin.x = (self.bounds.size.width - _pageControl.frame.size.width) / 2;
    frame.origin.y = self.bounds.size.height - _pageControl.frame.size.height-self.indicatorBottomMargin;
    _pageControl.frame = frame;
}

-(void)setDataSource:(id<NEPageViewDataSource>)dataSource {
    _dataSource = dataSource;
    _pageControl.numberOfPages = [_dataSource pageCount:self];
    _pageControl.currentPage = 0;
    [self configScrollViewContent];
}

-(void)reloadPages {
    [_pageMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [(UIView*)obj removeFromSuperview];
    }];
    [_pageMap removeAllObjects];
    if(_currentPageIndex.unsignedIntegerValue >= [self.dataSource pageCount:self]) {
        _currentPageIndex = [NSNumber numberWithUnsignedInteger:[self.dataSource pageCount:self]];
    }
    [self configScrollViewContent];
}

-(void)reloadPageAtIndex:(NSUInteger)index {
    NSNumber* pageIndex = [NSNumber numberWithUnsignedInteger:index];
    UIView* pageView = [_pageMap objectForKey:pageIndex];
    
    if(pageView) {
        [pageView removeFromSuperview];
        [_pageMap removeObjectForKey:pageIndex];
    }
    [self loadPage:pageIndex];
}

-(void)configScrollViewContent {
    if(!self.dataSource) {
        return;
    }
    CGSize size =self.frame.size;
    NSUInteger count = [self.dataSource pageCount:self];
    _scrollView.contentSize = CGSizeMake(size.width * count, size.height);
    [self fixPagesFrame];
    
    [self preparePageAndLeftRight:_currentPageIndex];
}

-(void)preparePageAndLeftRight:(NSNumber*)pageIndex {
    NSUInteger index = pageIndex.unsignedIntegerValue;
    if(index > 0) {
        [self loadPage:[NSNumber numberWithUnsignedInteger:index-1]];
    }
    [self loadPage:pageIndex];
    if(index + 1 < [self.dataSource pageCount:self]) {
        [self loadPage:[NSNumber numberWithUnsignedInteger:index + 1]];
    }
}

-(UIView*)pageForIndex:(NSUInteger)pageIndex {
    UIView* page = [_pageMap objectForKey:[NSNumber numberWithUnsignedInteger:pageIndex]];
    if(!page) {
        page = [self.dataSource pageView:self pageForIndex:pageIndex];
        [_pageMap setObject:page forKey:[NSNumber numberWithUnsignedInteger:pageIndex]];
    }
    return page;
}

-(void)fixPagesFrame {
    [_pageMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSUInteger index = [(NSNumber*)key unsignedIntegerValue];
        [(UIView*)obj setFrame:[self frameForPage:index]];
    }];
}

-(CGRect)frameForPage:(NSUInteger)pageIndex {
    CGSize size = self.frame.size;
    CGRect frame = CGRectMake(pageIndex * size.width, 0, size.width, size.height);
    return frame;
}

-(void)clearMorePage {
    NSUInteger currentIndex = _currentPageIndex.unsignedIntegerValue;
    NSMutableArray* needRemoveIndexes = [NSMutableArray new];
    [_pageMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSUInteger index = [(NSNumber*)key unsignedIntegerValue];
        if(index + 2 <= currentIndex) {
            [needRemoveIndexes addObject:key];
            [(UIView*)obj removeFromSuperview];
            [_unusedViews addObject:obj];
        }
    }];
    [_pageMap removeObjectsForKeys:needRemoveIndexes];
}

-(void)loadPage:(NSNumber*)pageIndex{
    UIView* page = [_pageMap objectForKey:pageIndex];
    if(!page) {
        page = [self.dataSource pageView:self pageForIndex:pageIndex.unsignedIntegerValue];
        [_pageMap setObject:page forKey:pageIndex];
        page.frame = [self frameForPage:pageIndex.unsignedIntegerValue];
        [_scrollView addSubview:page];
    }
}

-(UIView *)dequePage {
    UIView* last = _unusedViews.lastObject;
    if(last) {
        [_unusedViews removeLastObject];
    }
    return last;
}

#pragma mark NEPageView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    NSUInteger page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    _currentPageIndex = [NSNumber numberWithUnsignedInteger:page];
    [self preparePageAndLeftRight:_currentPageIndex];
    [self clearMorePage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}



@end
