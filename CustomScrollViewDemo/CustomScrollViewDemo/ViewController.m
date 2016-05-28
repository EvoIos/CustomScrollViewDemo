//
//  ViewController.m
//  CustomScrollViewDemo
//
//  Created by zhenglanchun on 16/5/28.
//  Copyright © 2016年 LC. All rights reserved.
//

#import "ViewController.h"
#import "RubbingBandingController.h"
#import "BouncingController.h"
#import "CustomScrollView/CustomScrollViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)rubberbanding:(id)sender {
    RubbingBandingController *vc =  [[RubbingBandingController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)bouncing:(id)sender {
    BouncingController *vc =  [[BouncingController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)customScrollViewtableView:(id)sender {
    CustomScrollViewController *vc =  [[CustomScrollViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
