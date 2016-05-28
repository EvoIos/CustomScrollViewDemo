//
//  CustomScrollView.m
//  CustomScrollViewDemo
//
//  Created by zhenglanchun on 16/5/29.
//  Copyright © 2016年 LC. All rights reserved.
//

#import "CustomScrollView.h"
#import "LCDynamicItem.h"

#define MaxHigh 44 * 50 - self.tableView.frame.size.height

static CGFloat rubberBandDistance(CGFloat offset, CGFloat dimension) {
    const CGFloat constant = 0.55f;
    CGFloat result = (constant * fabs(offset) * dimension) / (dimension + constant * fabs(offset));
    // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
    return offset < 0.0f ? -result : result;
}


@interface CustomScrollView()<UITableViewDelegate,UITableViewDataSource>
@property CGRect startBounds;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIDynamicItemBehavior *decelerationBehavior;
@property (nonatomic, weak) UIAttachmentBehavior *springBehavior;
@property (nonatomic, strong) LCDynamicItem *dynamicItem;
@property (nonatomic, strong) LCDynamicItem *dynamicTableItem;
@property (nonatomic) CGPoint lastPointInBounds;

@property (nonatomic,strong) UITableView *tableView;


//记录上一次的translation，用于判断滑动方向
@property (nonatomic) CGFloat lastTranslation;
//每次pan动作开始时，记录tableView的contentOffset，在此基础上进行设定offset
@property (nonatomic) CGPoint lastOffset;

//滚动顶部时
@property (nonatomic) CGFloat upPoint;
@property (nonatomic) BOOL upEdgeFlag;

//tableView offset 超过滚动最大值和最小值时刻的，translation.y值
@property (nonatomic) CGFloat edgeAfterOffsetPoint;

@property (nonatomic) BOOL scrollStateBetweenInitAndTop;

@property (nonatomic) CGRect lastBounds;

@property (nonatomic) NSInteger lastDirection;// 1 up; -1 down; 0 no direction

@property (nonatomic) CGPoint lastOffsetForEndState;
@end

@implementation CustomScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.clipsToBounds = YES;
    _bounceVertical = NO;
    _bounceHorizontal = NO;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    [self addGestureRecognizer:panGestureRecognizer];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    self.dynamicItem = [[LCDynamicItem alloc] init];
    self.dynamicTableItem = [[LCDynamicItem alloc] init];
    
    CGRect frame = self.bounds;
    frame.origin.y = 200;
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.bounces = NO;
        tableView.scrollEnabled = NO;
        tableView;
    });
    [self addSubview:self.tableView];
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.startBounds = self.bounds;
            self.lastOffset = self.tableView.contentOffset;
            _lastTranslation = 0;
            _upPoint = 0;
            _upEdgeFlag = YES;
            _edgeAfterOffsetPoint = 0.0;
            _lastDirection = 0;
           
            if (self.bounds.origin.y >= 200 && self.tableView.contentOffset.y >= 0 ) {
                _scrollStateBetweenInitAndTop = YES;
            } else {
                _scrollStateBetweenInitAndTop = NO;
            }
            
            [self.animator removeAllBehaviors];
        }
            // fall through
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGestureRecognizer translationInView:self];
            
            CGRect bounds = self.startBounds;
            
            if (!self.scrollHorizontal && !_bounceHorizontal) {
                translation.x = 0.0;
            }
            if (!self.scrollVertical && !_bounceVertical) {
                translation.y = 0.0;
            }
            
            bounds.origin.x =  [self getBoundsOrigin:bounds translation:(bounds.origin.x - translation.x) width:YES];
            bounds.origin.y = [self getBoundsOrigin:bounds translation:(bounds.origin.y - translation.y) width:NO];
            
            //向上滚动时，当tableView位移到(0，200)的时候，如果继续向上滚动的话，设定offset为0.6，为了进入下一步判断中。
            if (self.lastTranslation - (-translation.y)  < 0) {
                if (self.tableView.contentOffset.y <= 0 && self.bounds.origin.y >=200) {
                    self.tableView.contentOffset= CGPointMake(0, 0.6);
                    if (_upEdgeFlag == YES) {
                        _upPoint = -translation.y;
                        _upEdgeFlag = NO;
                    }
                }
            }
            
            if ((self.tableView.contentOffset.y < MaxHigh && self.tableView.contentOffset.y > 0)&& self.bounds.origin.y >= 200){
                bounds.origin.y = 200;
                self.tableView.contentOffset = CGPointMake(0, self.lastOffset.y + (-translation.y) - self.upPoint);
                
                if (self.tableView.contentOffset.y >= MaxHigh) {
                    self.tableView.contentOffset = CGPointMake(0, MaxHigh);
                    _edgeAfterOffsetPoint = -translation.y;
                    
                }
                
                if (self.tableView.contentOffset.y < 0) {
                    self.tableView.contentOffset = CGPointMake(0, 0);
                    _edgeAfterOffsetPoint = -translation.y;
                }
            }
            else {
               
                if ((self.lastTranslation - (-translation.y)) > 0) { //down
                    if ((self.bounds.origin.y <= 200) && (self.tableView.contentOffset.y > 0 && self.tableView.contentOffset.y <= MaxHigh ) ) {
                        bounds.origin.y = 200;
                        if ((self.lastOffset.y + (-translation.y)) < MaxHigh ) {
                            self.tableView.contentOffset = CGPointMake(0, self.lastOffset.y + (-translation.y));
                        } else {
                            self.tableView.contentOffset = CGPointMake(0, MaxHigh);
                        }
                    } else {
                        if (self.tableView.contentOffset.y <= MaxHigh ) {
                            if (self.tableView.contentOffset.y <= 0) {
                                self.tableView.contentOffset = CGPointMake(0, 0);
                            }
                            CGFloat newBoundsOriginY = 0;
                            if (_scrollStateBetweenInitAndTop == NO ) {//
                                newBoundsOriginY = self.lastBounds.origin.y - translation.y ;
                            } else {
                                newBoundsOriginY = self.lastBounds.origin.y - translation.y - _edgeAfterOffsetPoint;
                            }
                            
                            if (bounds.origin.y <200 && bounds.origin.y > 0) {
                                bounds.origin.y = newBoundsOriginY;
                            } else {
                                bounds.origin.y = [self getBoundsOrigin:bounds translation:newBoundsOriginY width:NO];
                            }
                        } else {
                            //bounds跳变,丢弃这一次的变化
                            bounds.origin.y = 200;
                        }
                    }
                    self.lastDirection = -1;
                }
                else if ((self.lastTranslation - (-translation.y)) < 0) { // up
                    if (bounds.origin.y > 200 && self.tableView.contentOffset.y >= MaxHigh)  {
                        bounds.origin.y = [self getBoundsOrigin:bounds translation:(200 - _edgeAfterOffsetPoint - translation.y) width:NO];
                        self.tableView.contentOffset = CGPointMake(0, MaxHigh);
                    }
                    self.lastDirection = 1;
                }
                else {//other
                    if (self.lastDirection == 1) { //up
                        if (bounds.origin.y > 200 && self.tableView.contentOffset.y >= MaxHigh)  {
                            bounds.origin.y =  [self getBoundsOrigin:bounds translation:(200 - _edgeAfterOffsetPoint - translation.y) width:NO];
                            self.tableView.contentOffset = CGPointMake(0, MaxHigh);
                        }
                        
                    }
                    else if(self.lastDirection == -1  ) { //down
                        CGFloat newBoundsOriginY = 0;
                        if (_scrollStateBetweenInitAndTop == NO ) {//
                            newBoundsOriginY = self.lastBounds.origin.y - translation.y ;
                        } else {
                            newBoundsOriginY = self.lastBounds.origin.y - translation.y - _edgeAfterOffsetPoint;
                        }
                        bounds.origin.y = [self getBoundsOrigin:bounds translation:newBoundsOriginY width:NO];
                    
                    } else {
                        //丢弃这一次的变化bounds.y
                        return;
                    }
                }
            }
            self.lastTranslation = -translation.y;
            self.bounds = bounds;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            CGPoint velocity = [panGestureRecognizer velocityInView:self];
            
            velocity.x = -velocity.x;
            velocity.y = -velocity.y;
            
            if (![self scrollHorizontal] || [self outsideBoundsMinimum] || [self outsideBoundsMaximum]) {
                velocity.x = 0;
            }
            if (![self scrollVertical] || [self outsideBoundsMinimum] || [self outsideBoundsMaximum]) {
                velocity.y = 0;
            }
            
            self.dynamicItem.center = self.bounds.origin;
            
            UIDynamicItemBehavior *decelerationBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.dynamicItem]];
            [decelerationBehavior addLinearVelocity:velocity forItem:self.dynamicItem];
            decelerationBehavior.resistance = 2.0;
            
            
            __weak typeof(self)weakSelf = self;
            __weak typeof(decelerationBehavior) weakBehavior = decelerationBehavior;
            
            __block BOOL isFirstPassVelocityDown = YES;
            __block BOOL isTmpFirstDown = YES;
            
            __block BOOL isFirstPassVelocity = YES;
            __block BOOL isTmpFirst = YES;
            
            decelerationBehavior.action = ^{
                __block CGRect bounds = weakSelf.bounds;
                bounds.origin = weakSelf.dynamicItem.center;
                CGPoint  weakVelocity =[weakBehavior linearVelocityForItem:weakSelf.dynamicItem];
                
                
                if (velocity.y > 0  ) {//down
                    if (bounds.origin.y >= 200 && weakSelf.tableView.contentOffset.y < MaxHigh) {
                        bounds.origin.y  = 200;
                    
                        if (isFirstPassVelocityDown == YES) {
                            LCDynamicItem *tmpItem = [[LCDynamicItem alloc] init];
                            tmpItem.center = weakSelf.tableView.contentOffset;
                            UIDynamicItemBehavior *tmpItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[tmpItem] ];
                            [tmpItemBehavior addLinearVelocity:weakVelocity forItem:tmpItem];
                            tmpItemBehavior.resistance = 2.0;
                            [self.animator addBehavior:tmpItemBehavior];
                            
                            tmpItemBehavior.action = ^{
                                if (weakSelf.tableView.contentOffset.y < MaxHigh) {
                                    weakSelf.tableView.contentOffset = CGPointMake(0, tmpItem.center.y);
                                }
                                if (weakSelf.tableView.contentOffset.y >= MaxHigh) {
                                    weakSelf.tableView.contentOffset = CGPointMake(0, MaxHigh);
                                }
                                if ((weakSelf.tableView.contentOffset.y >= MaxHigh) && (isTmpFirstDown==YES) ) {
                                    
                                    weakSelf.dynamicItem.center = CGPointMake(0, 200);
                                    [weakSelf.animator updateItemUsingCurrentState:weakSelf.dynamicItem];
                                    isTmpFirstDown = NO;
                                }
                            };
                            isFirstPassVelocityDown = NO;
                            
                        }
                    }
                    
                }
                else if (velocity.y < 0){ //up
                    if (bounds.origin.y <= 200 && weakSelf.tableView.contentOffset.y > 0) {
                        bounds.origin.y  = 200;
                        if (isFirstPassVelocity == YES) {
                            LCDynamicItem *tmpItem = [[LCDynamicItem alloc] init];
                        
                            tmpItem.center = weakSelf.tableView.contentOffset;
                            UIDynamicItemBehavior *tmpItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[tmpItem] ];
                            [tmpItemBehavior addLinearVelocity:weakVelocity forItem:tmpItem];
                            tmpItemBehavior.resistance = 2.0;
                            [self.animator addBehavior:tmpItemBehavior];
                            
                            tmpItemBehavior.action = ^{
                                if (weakSelf.tableView.contentOffset.y > 0) {
                                    weakSelf.tableView.contentOffset = CGPointMake(0, tmpItem.center.y);
                                }
                                if (weakSelf.tableView.contentOffset.y <= 0) {
                                    weakSelf.tableView.contentOffset = CGPointMake(0, 0);
                                }
                                if ((weakSelf.tableView.contentOffset.y == 0) && (isTmpFirst==YES) ) {
                                    weakSelf.dynamicItem.center = CGPointMake(0, 200);
                                    [weakSelf.animator updateItemUsingCurrentState:weakSelf.dynamicItem];
                                    isTmpFirst = NO;
                                }
                            };
                            isFirstPassVelocity = NO;
                        }
                    }
                }
                
                weakSelf.bounds = bounds;
                weakSelf.lastBounds = bounds;
            };
            
            [self.animator addBehavior:decelerationBehavior];
            self.decelerationBehavior = decelerationBehavior;
        }
            break;
            
        default:
            break;
    }
    
}

- (CGFloat)getBoundsOrigin:(CGRect )bounds translation:(CGFloat )translation width:(BOOL)isWidth{
    if (isWidth) {
        CGFloat newBoundsOriginX = translation;
        CGFloat minBoundsOriginX = 0.0;
        CGFloat maxBoundsOriginX = self.contentSize.width - bounds.size.width;
        CGFloat constraintedBoundsOriginX = fmax(minBoundsOriginX, fmin(newBoundsOriginX, maxBoundsOriginX));
        CGFloat rubberBandedX = rubberBandDistance(newBoundsOriginX - constraintedBoundsOriginX, CGRectGetWidth(self.bounds));
        return  constraintedBoundsOriginX + rubberBandedX;
    } else {
        CGFloat newBoundsOriginY = translation;
        CGFloat minBoundsOriginY = 0.0;
        CGFloat maxBoundsOriginY = self.contentSize.height - bounds.size.height;
        CGFloat constrainedBoundsOriginY = fmax(minBoundsOriginY, fmin(newBoundsOriginY, maxBoundsOriginY));
        CGFloat rubberBandedY = rubberBandDistance(newBoundsOriginY - constrainedBoundsOriginY, CGRectGetHeight(self.bounds));
        return constrainedBoundsOriginY + rubberBandedY;
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES; //otherGestureRecognizer is your custom pan gesture
}


- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    if (([self outsideBoundsMinimum] || [self outsideBoundsMaximum]) &&
        (self.decelerationBehavior && !self.springBehavior)) {
        
        CGPoint target = [self anchor];
        
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.dynamicItem attachedToAnchor:target];
        // Has to be equal to zero, because otherwise the bounds.origin wouldn't exactly match the target's position.
        springBehavior.length = 0;
        // These two values were chosen by trial and error.
        springBehavior.damping = 1;
        springBehavior.frequency = 2;
        
        [self.animator addBehavior:springBehavior];
        self.springBehavior = springBehavior;
    }
    
    if (![self outsideBoundsMinimum] && ![self outsideBoundsMaximum]) {
        self.lastPointInBounds = bounds.origin;
    }
}

- (CGPoint)anchor
{
    CGRect bounds = self.bounds;
    CGPoint maxBoundsOrigin = [self maxBoundsOrigin];
    
    CGFloat deltaX = self.lastPointInBounds.x - bounds.origin.x;
    CGFloat deltaY = self.lastPointInBounds.y - bounds.origin.y;
    
    // solves a system of equations: y_1 = ax_1 + b and y_2 = ax_2 + b
    CGFloat a = deltaY / deltaX;
    CGFloat b = self.lastPointInBounds.y - self.lastPointInBounds.x * a;
    
    CGFloat leftBending = -bounds.origin.x;
    CGFloat topBending = -bounds.origin.y;
    CGFloat rightBending = bounds.origin.x - maxBoundsOrigin.x;
    CGFloat bottomBending = bounds.origin.y - maxBoundsOrigin.y;
    
    // Updates anchor's `y` based on already set `x`, i.e. y = f(x)
    void(^solveForY)(CGPoint*) = ^(CGPoint *anchor1) {
        // Updates `y` only if there was a vertical movement. Otherwise `y` based on current `bounds.origin` is already correct.
        if (deltaY != 0) {
            anchor1->y = a * anchor1->x + b;
        }
    };
    // Updates anchor's `x` based on already set `y`, i.e. x =  f^(-1)(y)
    void(^solveForX)(CGPoint*) = ^(CGPoint *anchor1) {
        if (deltaX != 0) {
            anchor1->x = (anchor1->y - b) / a;
        }
    };
    
    CGPoint anchor = bounds.origin;
    
    if (bounds.origin.x < 0.0 && leftBending > topBending && leftBending > bottomBending) {
        anchor.x = 0;
        solveForY(&anchor);
    } else if (bounds.origin.y < 0.0 && topBending > leftBending && topBending > rightBending) {
        anchor.y = 0;
        solveForX(&anchor);
    } else if (bounds.origin.x > maxBoundsOrigin.x && rightBending > topBending && rightBending > bottomBending) {
        anchor.x = maxBoundsOrigin.x;
        solveForY(&anchor);
    } else if (bounds.origin.y > maxBoundsOrigin.y) {
        anchor.y = maxBoundsOrigin.y;
        solveForX(&anchor);
    }
    
    
    return anchor;
}

- (BOOL)scrollVertical
{
    return self.contentSize.height > CGRectGetHeight(self.bounds);
}

- (BOOL)scrollHorizontal
{
    return self.contentSize.width > CGRectGetWidth(self.bounds);
}

- (CGPoint)maxBoundsOrigin
{
    return CGPointMake(self.contentSize.width - self.bounds.size.width,
                       self.contentSize.height - self.bounds.size.height);
}

- (BOOL)outsideBoundsMinimum
{
    return self.bounds.origin.x < 0.0 || self.bounds.origin.y < 0.0;
}

- (BOOL)outsideBoundsMaximum
{
    CGPoint maxBoundsOrigin = [self maxBoundsOrigin];
    return self.bounds.origin.x > maxBoundsOrigin.x || self.bounds.origin.y > maxBoundsOrigin.y;
}


#pragma mark -
#pragma mark tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"index: %ld",indexPath.row];
    return cell;
}

@end
