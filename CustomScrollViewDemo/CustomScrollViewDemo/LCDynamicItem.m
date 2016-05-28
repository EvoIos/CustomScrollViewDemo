//
//  LCDynamicItem.m
//  CustomScrollViewByUseDynamicDemo
//
//  Created by z on 16/5/19.
//  Copyright © 2016年 z. All rights reserved.
//

#import "LCDynamicItem.h"

@implementation LCDynamicItem
- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Sets non-zero `bounds`, because otherwise Dynamics throws an exception.
        _bounds = CGRectMake(0, 0, 1, 1);
    }
    
    return self;
}
@end
