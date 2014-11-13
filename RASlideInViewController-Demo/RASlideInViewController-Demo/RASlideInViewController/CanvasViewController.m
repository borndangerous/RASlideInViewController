//
//  RAViewController.m
//  RACardViewController
//
//  Created by Ryo Aoyama on 4/28/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import "CanvasViewController.h"
#import "RASlideInViewController.h"
#import "RANewSlideInViewController.h"

@interface CanvasViewController ()

@property (nonatomic, strong) UIWindow *subWindow;

@end

@implementation CanvasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    RASlideInViewController *frontViewController = [RASlideInViewController new];
    frontViewController.shiftBackDropView = NO;
    frontViewController.backdropViewScaleReductionRatio = 1;
    [frontViewController.view setBackgroundColor:[UIColor yellowColor]];
    [self presentViewController:frontViewController animated:NO completion:^{
        
        RASlideInViewController *nextViewController = [RASlideInViewController new];
        [nextViewController setSlideInDirection:RASlideInDirectionBottomToTop];
        nextViewController.backdropViewScaleReductionRatio = 0.97;
        [nextViewController.view setBackgroundColor:[UIColor cyanColor]];
        [self.presentedViewController presentViewController:nextViewController animated:NO completion:nil];
        
    }];
}

- (IBAction)addNewView:(UIButton *)sender
{
//    UIStoryboard *storyboard = self.storyboard;
//    RANewSlideInViewController *slideViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([RANewSlideInViewController class])];
    RANewSlideInViewController *slideViewController = [[RANewSlideInViewController alloc] init];
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;  //***
    
    [self presentViewController:slideViewController animated:NO completion:nil];
}

- (IBAction)addNewWindow:(UIButton *)sender
{
    //UIStoryboard *storyboard = self.storyboard;
    RASlideInViewController *slideViewController = [RASlideInViewController new];
    
    //slideViewController.slideInDirection = RASlideInDirectionLeftToRight;
    
    _subWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _subWindow.windowLevel = UIWindowLevelStatusBar;
    _subWindow.rootViewController = slideViewController;
    [_subWindow makeKeyAndVisible];
}

@end
