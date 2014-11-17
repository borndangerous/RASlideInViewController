//
//  RACardViewController.h
//  RACardViewController
//
//  Created by Ryo Aoyama on 4/28/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JREnum.h>

JREnumDeclare(RASlideViewSlideInDirection,
              RASlideInDirectionBottomToTop,
              RASlideInDirectionRightToLeft,
              RASlideInDirectionTopToBottom,
              RASlideInDirectionLeftToRight);

@interface StackViewController : UIViewController

@property (nonatomic, assign) RASlideViewSlideInDirection slideInDirection; //default RASlideInDirectionBottomToTop;

@property (nonatomic, assign) CGFloat animationDuration; //default .3f

@property (nonatomic, assign) BOOL shiftBackDropView; //default NO
@property (nonatomic, assign) CGFloat shiftBackDropViewValue; //default 100.f

@property (nonatomic, assign) CGFloat backdropViewScaleReductionRatio; //default .9f
@property (nonatomic, assign) CGFloat backDropViewAlpha; //default 0

@end
