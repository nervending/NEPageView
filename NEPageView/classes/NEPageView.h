//
//  NEPageView.h
//  NEPageView
//
//  Created by virl on 14/11/28.
//  Copyright (c) 2014年 virl. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NEPageView;

@protocol NEPageViewDataSource <NSObject>
-(UIView*)pageView:(NEPageView*)pageView pageForIndex:(NSUInteger)index;
-(NSUInteger)pageCount:(NEPageView*)pageView;

@end

@interface NEPageView : UIView
@property (nonatomic, weak) id<NEPageViewDataSource> dataSource;
@property (nonatomic, assign) CGFloat indicatorBottomMargin;

-(UIView*)dequePage;

@end
