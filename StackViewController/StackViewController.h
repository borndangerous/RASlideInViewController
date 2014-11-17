//
//  RACardViewController.h
//  RACardViewController
//
//  Created by Ryo Aoyama on 4/28/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JREnum.h"

JREnumDeclare(SVCardOrigin,
              SVCardOriginBottom,
              SVCardOriginRight,
              SVCardOriginTop,
              SVCardOriginLeft);

@interface StackViewController : UIViewController

@property (nonatomic, assign) SVCardOrigin cardOrigin; //default SVCardOriginBottom;

@property (nonatomic, assign) CGFloat animationDuration; //default .3f

@property (nonatomic) UIView *handleView;

@property (nonatomic, assign) BOOL shiftBackDropView; //default NO
@property (nonatomic, assign) CGFloat shiftBackDropViewValue; //default 100.f

@property (nonatomic, assign) CGFloat backdropViewScaleReductionRatio; //default .9f
@property (nonatomic, assign) CGFloat backDropViewAlpha; //default 0

@property (nonatomic, assign, getter = isShadowEnabled) BOOL shadowEnabled;
@property (nonatomic, assign, getter = isCardStyle) BOOL cardStyle;
@property (nonatomic, assign) BOOL showsHandle;

-(void)setBackgroundColor:(UIColor*)color;

@end
