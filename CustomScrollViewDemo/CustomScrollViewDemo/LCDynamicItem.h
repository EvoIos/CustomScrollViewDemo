//
//  LCDynamicItem.h
//  CustomScrollViewByUseDynamicDemo
//
//  Created by z on 16/5/19.
//  Copyright © 2016年 z. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LCDynamicItem : NSObject  <UIDynamicItem>
@property (nonatomic, readwrite) CGPoint center;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readwrite) CGAffineTransform transform;

@end
