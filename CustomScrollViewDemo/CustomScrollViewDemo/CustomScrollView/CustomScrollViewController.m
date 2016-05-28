//
//  CustomScrollViewController.m
//  CustomScrollViewDemo
//
//  Created by zhenglanchun on 16/5/29.
//  Copyright © 2016年 LC. All rights reserved.
//

#import "CustomScrollViewController.h"
#import "CustomScrollView.h"


@interface CustomScrollViewController ()

@end

@implementation CustomScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect frame = self.view.bounds;
    frame.origin.y = 64;
    frame.size.height -= 64;
    CustomScrollView *customScrollView = [[CustomScrollView alloc] initWithFrame:frame];
    
    //注意：这里的高度是tableView的高度+200。 200 是tableView与头部的距离
    customScrollView.contentSize = CGSizeMake(customScrollView.frame.size.width,customScrollView.frame.size.height + 200 );
    customScrollView.bounceVertical = YES;
    customScrollView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:customScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
