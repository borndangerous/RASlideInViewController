//
//  RACardViewController.m
//  RACardViewController
//
//  Created by Ryo Aoyama on 4/28/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import "StackViewController.h"

JREnumDefine(RASlideViewSlideInDirection);

@interface StackViewController ()

@property (nonatomic, assign) BOOL appered;

@end

@implementation StackViewController
{
    UIView *_backDropView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"initWithCoder");
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"init");
        [self initialSetup];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    //configure
    [self configure];
}

- (void)viewDidAppear:(BOOL)animated {
    //back drop view
    _backDropView = [self backDropView];
    if (!_appered)
    {
        //alpha
        self.view.alpha = 1.f;
        
        //backDropView superview alpha 0
        self.presentingViewController.presentingViewController.view.alpha = 0;
        
        //animation
        [UIView animateWithDuration:_animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGSize viewSize = self.view.bounds.size;
            self.view.frame = [self appearedAnimationStandbyPosition];
            self.view.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
            self.view.window.backgroundColor = [UIColor colorWithWhite:0 alpha:1.f];
            //back drop view
            CGAffineTransform transform;
            if (!_shiftBackDropView) {
                transform = CGAffineTransformMakeScale(_backdropViewScaleReductionRatio, _backdropViewScaleReductionRatio);
            }else {
                CGAffineTransform scale = CGAffineTransformMakeScale(_backdropViewScaleReductionRatio, _backdropViewScaleReductionRatio);
                CGAffineTransform shift = [self calculateBackdropShiftFromProgress:0];
                transform = CGAffineTransformConcat(scale, shift);
            }
            _backDropView.alpha = _backDropViewAlpha;
            _backDropView.transform = transform;
        }completion:^(BOOL finished){
            _appered = YES;
            //User intraction of superView
            _backDropView.userInteractionEnabled = NO;
        }];
    }
}

- (void)initialSetup {
    NSLog(@"initialSetup");
    //initial property value
    _slideInDirection = RASlideInDirectionBottomToTop;
    _shiftBackDropView = NO;
    _animationDuration = .3f;
    _backdropViewScaleReductionRatio = .9f;
    _shiftBackDropViewValue = 100.f;
    _backDropViewAlpha = 0;
    
    self.view.backgroundColor = [self randomColor];
}

- (void)configure {
    NSLog(@"configure");
    //initial alpha
    self.view.alpha = 0;
    
    //modal style
    //self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    self.providesPresentationContextTransitionStyle = YES;
    self.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    //shadow
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = [self shadowOffsetByDirection];
    self.view.layer.shadowOpacity = .5f;
    self.view.layer.shadowRadius = 2.f;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    self.view.layer.shouldRasterize = YES;
    //self.view.layer.cornerRadius = 6;
    //self.view.layer.masksToBounds = YES;
    self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    //pan Gesture
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTransitionView:)];
    [self.view addGestureRecognizer:pan];
}

- (CGRect)appearedAnimationStandbyPosition {
    CGSize viewSize = self.view.bounds.size;
    switch (_slideInDirection) {
        case RASlideInDirectionBottomToTop:
            return CGRectMake(0, viewSize.height, viewSize.width, viewSize.height);
        case RASlideInDirectionRightToLeft:
            return CGRectMake(viewSize.width, 0, viewSize.width, viewSize.height);
        case RASlideInDirectionTopToBottom:
            return CGRectMake(0, -viewSize.height, viewSize.width, viewSize.height);
        case RASlideInDirectionLeftToRight:
            return CGRectMake(-viewSize.width, 0, viewSize.width, viewSize.height);
        default:
            return CGRectMake(0, viewSize.height, viewSize.width, viewSize.height);
    }
}

- (CGSize)shadowOffsetByDirection
{
    switch (_slideInDirection) {
        case RASlideInDirectionBottomToTop:
            return CGSizeMake(0, -4.f);
        case RASlideInDirectionRightToLeft:
            return CGSizeMake(-4.f, 0);
        case RASlideInDirectionTopToBottom:
            return CGSizeMake(0, 4.f);
        case RASlideInDirectionLeftToRight:
            return CGSizeMake(4.f, 0);
        default:
            return CGSizeMake(0, -4.f);
    }
}

- (UIView *)backDropView {
    UIView *superView;
    if (self.presentingViewController){
        superView = self.presentingViewController.view;
        return superView;
    } else {
        NSArray *windows = [UIApplication sharedApplication].windows;
        NSInteger index = [windows indexOfObject:self.view.window];
        if([windows count] > 1){
            superView = ((UIWindow *)[windows objectAtIndex:index - 1]).rootViewController.view;
            return superView;
        } else {
            return nil;
        }
    }
}

- (void)panTransitionView:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:self.view];
    CGPoint velocity = [sender velocityInView:self.view];
    
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
            //transition
            [self transformFrontView:translation];
            [self transformBackdropViewWithProgress:[self calcprogress]];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            if ([self didEndDragingHandllerWithVelocity:velocity]) {
                [self dismissFrontView];
            }else {
                [self refocusFrontView];
            }
            break;
        default:
            break;
    }
}

- (BOOL)didEndDragingHandllerWithVelocity:(CGPoint)velocity
{
    switch (_slideInDirection) {
        case RASlideInDirectionBottomToTop:
            if (velocity.y >= 500.f) {
                return YES;
            }
            return NO;
        case RASlideInDirectionRightToLeft:
            if (velocity.x >= 500.f) {
                return YES;
            }
            return NO;
        case RASlideInDirectionTopToBottom:
            if (velocity.y <= -500.f) {
                return YES;
            }
            return NO;
        case RASlideInDirectionLeftToRight:
            if (velocity.x <= -500.f) {
                return YES;
            }
            return NO;
        default:
            if (velocity.y >= 500.f) {
                return YES;
            }
            return NO;
    }
}

- (CGFloat)calcprogress
{
    switch (_slideInDirection) {
        case RASlideInDirectionBottomToTop:
            return self.view.frame.origin.y / [UIScreen mainScreen].bounds.size.height;
            break;
        case RASlideInDirectionRightToLeft:
            return self.view.frame.origin.x / [UIScreen mainScreen].bounds.size.width;
            break;
        case RASlideInDirectionTopToBottom:
            return (-self.view.frame.origin.y) / [UIScreen mainScreen].bounds.size.height;
            break;
        case RASlideInDirectionLeftToRight:
            return (-self.view.frame.origin.x) / [UIScreen mainScreen].bounds.size.width;
            break;
        default:
            return self.view.frame.origin.y / [UIScreen mainScreen].bounds.size.height;
            break;
    }
}

- (void)transformFrontView:(CGPoint)translation {
    //transition
    switch (_slideInDirection) {
        case RASlideInDirectionBottomToTop:
            self.view.transform = CGAffineTransformMakeTranslation(0, translation.y);
            if (self.view.frame.origin.y <= 0) {
                self.view.transform = CGAffineTransformIdentity;
            }
            break;
        case RASlideInDirectionRightToLeft:
            self.view.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            if (self.view.frame.origin.x <= 0) {
                self.view.transform = CGAffineTransformIdentity;
            }
            break;
        case RASlideInDirectionTopToBottom:
            self.view.transform = CGAffineTransformMakeTranslation(0, translation.y);
            if (self.view.frame.origin.y >= 0) {
                self.view.transform = CGAffineTransformIdentity;
            }
            break;
        case RASlideInDirectionLeftToRight:
            self.view.transform = CGAffineTransformMakeTranslation(translation.x, 0);
            if (self.view.frame.origin.x >= 0) {
                self.view.transform = CGAffineTransformIdentity;
            }
            break;
        default:
            self.view.transform = CGAffineTransformMakeTranslation(0, translation.y);
            if (self.view.frame.origin.y <= 0) {
                self.view.transform = CGAffineTransformIdentity;
            }
            break;
    }
}

- (void)transformBackdropViewWithProgress:(CGFloat)progress
{
    CGFloat alphaDiff = (1.f - _backDropViewAlpha) * (1.f - progress);
    _backDropView.alpha = 1.f - alphaDiff;
    CGAffineTransform transform;
    if (!_shiftBackDropView) {
        transform = CGAffineTransformMakeScale(_backdropViewScaleReductionRatio + ((1.f - _backdropViewScaleReductionRatio)*progress), _backdropViewScaleReductionRatio + ((1.f - _backdropViewScaleReductionRatio)*progress));
    }else {
        CGAffineTransform scale = CGAffineTransformMakeScale(_backdropViewScaleReductionRatio + ((1.f - _backdropViewScaleReductionRatio) * progress), _backdropViewScaleReductionRatio + ((1.f - _backdropViewScaleReductionRatio) * progress));
        CGAffineTransform shift = [self calculateBackdropShiftFromProgress:progress];
        transform = CGAffineTransformConcat(scale, shift);
    }
    _backDropView.transform = transform;
    if (!self.presentingViewController)
    {
        self.view.window.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }
}

- (CGAffineTransform)calculateBackdropShiftFromProgress:(CGFloat)progress {
    CGAffineTransform shift;
    switch (self.slideInDirection) {
        case RASlideInDirectionBottomToTop:
            shift = CGAffineTransformMakeTranslation(0, (1.f - progress) * -_shiftBackDropViewValue);
            return shift;
        case RASlideInDirectionRightToLeft:
            shift = CGAffineTransformMakeTranslation((1.f - progress) * -_shiftBackDropViewValue, 0);
            return shift;
        case RASlideInDirectionTopToBottom:
            shift = CGAffineTransformMakeTranslation(0, (1.f - progress) * _shiftBackDropViewValue);
            return shift;
        case RASlideInDirectionLeftToRight:
            shift = CGAffineTransformMakeTranslation((1.f - progress) * _shiftBackDropViewValue, 0);
            return shift;
        default:
            shift = CGAffineTransformMakeTranslation(0, (1.f - progress) * -_shiftBackDropViewValue);
            return shift;
    }
}

- (void)refocusFrontView {
    [UIView animateWithDuration:_animationDuration delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.transform = CGAffineTransformIdentity;
        _backDropView.alpha = _backDropViewAlpha;
        CGAffineTransform transform;
        if (!_shiftBackDropView) {
            transform = CGAffineTransformMakeScale(_backdropViewScaleReductionRatio, _backdropViewScaleReductionRatio);
        }else {
            CGAffineTransform scale = CGAffineTransformMakeScale(_backdropViewScaleReductionRatio, _backdropViewScaleReductionRatio);
            CGAffineTransform shift = [self calculateBackdropShiftFromProgress:0];
            transform = CGAffineTransformConcat(scale, shift);
        }
        _backDropView.transform = transform;
    }completion:^(BOOL finished){
        self.view.window.backgroundColor = [UIColor colorWithWhite:0 alpha:1.f];
    }];
}

- (void)dismissFrontView {
    [UIView animateWithDuration:_animationDuration delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        if (self.presentingViewController) {
            self.view.transform = [self getDirectionalDismissTransform];
        }else {
            self.view.transform = CGAffineTransformIdentity;
            self.view.window.transform = [self getDirectionalDismissTransform];
        }
        _backDropView.alpha = 1.f;
        _backDropView.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finised){
        _backDropView.userInteractionEnabled = YES;
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:NO completion:^{
                NSLog(@"dismissFrontView > Dismissed");
            }];
        }else {
            self.view.window.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            self.view.window.hidden = YES;
        }
    }];
}

- (CGAffineTransform)getDirectionalDismissTransform {
    switch (_slideInDirection) {
        case RASlideInDirectionBottomToTop:
            return CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height);
            break;
        case RASlideInDirectionRightToLeft:
            return CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
            break;
        case RASlideInDirectionTopToBottom:
            return CGAffineTransformMakeTranslation(0, -[UIScreen mainScreen].bounds.size.height);
            break;
        case RASlideInDirectionLeftToRight:
            return CGAffineTransformMakeTranslation(-[UIScreen mainScreen].bounds.size.width, 0);
            break;
        default:
            return CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.height);
            break;
    }
}

- (UIColor*)randomColor {
    CGFloat rValue = arc4random() % 256;
    CGFloat gValue = arc4random() % 256;
    CGFloat bValue = arc4random() % 256;
    
    return [UIColor colorWithRed:rValue/255.0 green:gValue/255.0 blue:bValue/255.0 alpha:1.0];
    
}


@end
