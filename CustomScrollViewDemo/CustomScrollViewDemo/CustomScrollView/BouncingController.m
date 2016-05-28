//
//  BouncingController.m
//  CustomScrollViewDemo
//
//  Created by zhenglanchun on 16/5/28.
//  Copyright © 2016年 LC. All rights reserved.
//

#import "BouncingController.h"
#import "LCDynamicItem.h"

@interface BouncingController ()
@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation BouncingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height - 50, 50, 50)];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    UIView *normalView = [[UIView alloc] initWithFrame:CGRectMake(100, self.view.frame.size.height - 50, 50, 50)];
    normalView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:normalView];
    
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        {
            LCDynamicItem *dynamicItem =  [[LCDynamicItem alloc] init];
            dynamicItem.center = redView.frame.origin;
            
            UIDynamicItemBehavior *decelerationBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[dynamicItem]] ;
            [decelerationBehavior addLinearVelocity:CGPointMake(0, -1000) forItem:dynamicItem];
            decelerationBehavior.resistance = 2.0;
            
            __block BOOL onlyOnce = YES;
            
            decelerationBehavior.action = ^{
                CGRect frame = redView.frame;
                frame.origin = dynamicItem.center;
                if (frame.origin.y > 64) {
                    redView.frame  = frame;
                }
                if (onlyOnce) {
                    //add attachment
                    UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:dynamicItem attachedToAnchor:CGPointMake(20, self.view.frame.size.height - 50)];
                    springBehavior.frequency = 2.0;
                    springBehavior.length = 0;
                    springBehavior.damping = 1;
                    [self.animator addBehavior:springBehavior];
                    
                    onlyOnce = NO;
                }
            };
            
            [self.animator addBehavior:decelerationBehavior];
        }
    
        //normal deceleration
        {
            LCDynamicItem *dynamicItem =  [[LCDynamicItem alloc] init];
            dynamicItem.center = normalView.frame.origin;
            
            UIDynamicItemBehavior *decelerationBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[dynamicItem]] ;
            [decelerationBehavior addLinearVelocity:CGPointMake(0, -1000) forItem:dynamicItem];
            decelerationBehavior.resistance = 2.0;
            
            decelerationBehavior.action = ^{
                CGRect frame = normalView.frame;
                frame.origin = dynamicItem.center;
                if (frame.origin.y > 64) {
                    normalView.frame  = frame;
                }
            };
            
            [self.animator addBehavior:decelerationBehavior];
        }
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
