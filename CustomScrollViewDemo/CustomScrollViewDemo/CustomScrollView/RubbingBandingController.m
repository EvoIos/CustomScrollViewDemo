//
//  RubbingBandingController.m
//  CustomScrollViewDemo
//
//  Created by zhenglanchun on 16/5/28.
//  Copyright © 2016年 LC. All rights reserved.
//

#import "RubbingBandingController.h"

//OC 函数实现： 正规版本
static CGFloat rubberBandDistance(CGFloat offset, CGFloat dimension) {
    
    const CGFloat constant = 0.55f;
    CGFloat result = (constant * fabs(offset) * dimension) / (dimension + constant * fabs(offset));
    // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
    return offset < 0.0f ? -result : result;
}

//最初版本：
static CGFloat previousRubberBandDistance(CGFloat offset) {
    CGFloat result = fabs(offset) * 0.5;
    return offset < 0.0f ? -result : result;
}


@interface RubbingBandingController ()
{
    CGRect frame1 ;
    CGRect frame2 ;
    CGRect frame3 ;
}
@property (nonatomic,strong) UIView *previousView ;
@property (nonatomic,strong) UIView *rubberBandView ;
@property (nonatomic,strong) UIView *normalView ;

@end

@implementation RubbingBandingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.previousView =  [[UIView alloc] initWithFrame:CGRectMake(0, 100, 50, 50)];
    self.previousView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.previousView];
    self.rubberBandView =  [[UIView alloc] initWithFrame:CGRectMake(0, 200, 50, 50)];
    self.rubberBandView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.rubberBandView];
    self.normalView =  [[UIView alloc] initWithFrame:CGRectMake(0, 300, 50, 50)];
    self.normalView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.normalView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
}


- (void)pan:(UIPanGestureRecognizer *)gr {
    CGPoint translation = [gr translationInView:self.view];
    
    switch (gr.state) {
        case UIGestureRecognizerStateBegan:
        {
             frame1 = self.previousView.frame;
             frame2 = self.rubberBandView.frame;
             frame3 = self.normalView.frame;
        }
        case UIGestureRecognizerStateChanged:
        {
            frame1.origin.x = previousRubberBandDistance(translation.x);
            frame2.origin.x = rubberBandDistance(translation.x, self.view.frame.size.width);
            frame3.origin.x = translation.x;
            
            self.previousView.frame = frame1;
            self.rubberBandView.frame = frame2;
            self.normalView.frame = frame3;
            
            NSLog(@"frame2: %f %f %f",frame2.origin.x,frame2.origin.y,frame2.size.width);
        }
            break;
        case UIGestureRecognizerStateEnded:
            
            break;
        default:
            break;
    }
    
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
