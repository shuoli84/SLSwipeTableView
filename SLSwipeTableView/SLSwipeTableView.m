//
//  SLSwipeTableView.m
//  SLSwipeTableView
//
//  Created by Li Shuo on 13-11-30.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import "SLSwipeTableView.h"

typedef NS_ENUM(NSInteger, ShowMode){
    ShowModeDefault,
    ShowModeLeft,
    ShowModeRight,
};

@interface SLSwipeTableView() <UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGPoint panRecognizerStartPoint;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UITableViewCell *selectedTableViewCell;
@property (nonatomic, strong) UIView *backContainerView;

@property (nonatomic, assign) ShowMode showMode;
@property (nonatomic, strong) NSArray* leftItems;
@property (nonatomic, strong) NSArray* rightItems;

@property (nonatomic, strong) NSArray* leftButtons;
@property (nonatomic, strong) NSArray* rightButtons;
@end

@implementation SLSwipeTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:panGestureRecognizer];

        self.showMode = ShowModeDefault;
        self.backContainerView = [[UIView alloc]init];
    }
    return self;
}

-(void)pan:(UIGestureRecognizer *)gestureRecognizer{
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer*)gestureRecognizer;
    CGPoint location = [gestureRecognizer locationInView:self];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
        self.panRecognizerStartPoint = location;
        CGPoint v = [panGestureRecognizer velocityInView:self];
        if(ABS(v.x) < ABS(v.y)){
            gestureRecognizer.enabled = NO;
            gestureRecognizer.enabled = YES;
        }
        else{
            //Make self's other pan gesture recognizer fail
            for(UIGestureRecognizer* rec in self.gestureRecognizers){
                if([rec isKindOfClass:[UIPanGestureRecognizer class]]){
                    if(![rec isEqual:gestureRecognizer]){
                        rec.enabled = NO;
                        rec.enabled = YES;
                    }
                }
            }

            self.selectedIndexPath = [self indexPathForRowAtPoint:location];
            self.selectedTableViewCell = [self cellForRowAtIndexPath:self.selectedIndexPath];

            self.backContainerView.frame = self.selectedTableViewCell.contentView.frame;
            [self.selectedTableViewCell insertSubview:self.backContainerView atIndex:0];
            self.selectedTableViewCell.selected = NO;
        }
    }
    else if(gestureRecognizer.state != UIGestureRecognizerStateFailed){
        CGPoint originalCenter = CGPointMake(self.bounds.size.width/2, self.selectedTableViewCell.contentView.center.y);
        CGPoint newCenter =  CGPointMake(originalCenter.x + location.x - self.panRecognizerStartPoint.x,
        originalCenter.y);

        self.selectedTableViewCell.contentView.center = newCenter;

        int selectedIndex;
        BOOL left = newCenter.x > originalCenter.x + 2.f;
        BOOL right = newCenter.x < originalCenter.x - 2.f;
        if(left || right){
            ShowMode targetShowMode = left?ShowModeLeft:ShowModeRight;
            if(self.showMode != targetShowMode){
                self.showMode = targetShowMode;

                if((left && self.leftItems == nil) || (right && self.rightItems == nil)){
                    if([self.delegate respondsToSelector:@selector(swipeTableView:itemsForIndexPath:onLeft:)]){
                        if(left){
                            self.leftItems = [self.delegate swipeTableView:self itemsForIndexPath:self.selectedIndexPath onLeft:YES];
                        }
                        else{
                            self.rightItems = [self.delegate swipeTableView:self itemsForIndexPath:self.selectedIndexPath onLeft:NO];
                        }
                    }
                }

                NSArray *targetArray = left?self.leftItems:self.rightItems;

                NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:targetArray.count];
                for(NSObject *item in targetArray){
                    if([item isKindOfClass:[UIButton class]]){
                        [mutableArray addObject:item];
                    }
                    else if([item isKindOfClass:[NSString class]]){
                        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                        [button setBackgroundImage:[SLSwipeTableView imageForColor:[UIColor grayColor]] forState:UIControlStateNormal];
                        [button setBackgroundImage:[SLSwipeTableView imageForColor:self.tintColor] forState:UIControlStateHighlighted];

                        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

                        button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);

                        [button setTitle:(NSString *)item forState:UIControlStateNormal];

                        [mutableArray addObject:button];
                    }
                }

                if(left){
                    self.leftButtons = mutableArray;
                }
                else{
                    self.rightButtons = mutableArray;
                }

                NSArray *targetButtonArray = left?self.leftButtons:self.rightButtons;

                float x = left?self.separatorInset.left:-(self.bounds.size.width - self.separatorInset.left - self.selectedTableViewCell.contentView.bounds.size.width);
                for(UIButton *button in targetButtonArray){
                    [button sizeToFit];
                    CGRect rect = button.frame;
                    rect.size.height = self.selectedTableViewCell.bounds.size.height;
                    rect.origin.x = left?x:(self.selectedTableViewCell.contentView.bounds.size.width - x - button.bounds.size.width);
                    button.frame = rect;

                    [self.backContainerView addSubview:button];

                    x = x + button.bounds.size.width;
                }
            }
        }

        float distance = ABS(location.x - self.panRecognizerStartPoint.x);
        selectedIndex = [self updateButtonStateForDistance:distance left:left];

        typeof(self) __weak weakSelf = self;
        if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
            if(selectedIndex != NSNotFound){
                if([self.delegate respondsToSelector:@selector(swipeTableView:didSelectedForIndexPath:index:onLeft:)]){
                    [self.delegate swipeTableView:self didSelectedForIndexPath:self.selectedIndexPath index:selectedIndex onLeft:left];
                }
            }
            [UIView animateWithDuration:0.3 animations:^{
                self.selectedTableViewCell.contentView.center = CGPointMake(self.bounds.size.width/2, self.selectedTableViewCell.contentView.center.y);
            } completion:^(BOOL finished){
                [weakSelf.backContainerView removeFromSuperview];
                for(UIView *view in weakSelf.backContainerView.subviews){
                    [view removeFromSuperview];
                }
                weakSelf.showMode = ShowModeDefault;
                weakSelf.leftItems = nil;
                weakSelf.rightItems = nil;
                weakSelf.selectedTableViewCell = nil;
                weakSelf.selectedIndexPath = nil;
            }];
        }
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

+(UIImage*)imageForColor:(UIColor*)color{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

-(int)updateButtonStateForDistance:(float)distance left:(BOOL)left{
    NSArray *buttons;
    if(left){
        buttons = self.leftButtons;
    }
    else{
        buttons = self.rightButtons;
    }

    float offset = 0.f;
    UIButton *selectedButton;
    for(UIButton *button in buttons){
        if(offset + button.bounds.size.width < distance){
            selectedButton = button;
            offset += button.bounds.size.width;
        }
    }

    if(selectedButton){
        for (UIButton *button in buttons){
            if(![button isEqual:selectedButton]){
                [button setHighlighted:NO];
            }
            else{
                [button setHighlighted:YES];
            }
        }
    }

    if(selectedButton){
        return [buttons indexOfObject:selectedButton];
    }
    else{
        return NSNotFound;
    }
}

/*
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)gestureRecognizer;
    CGPoint v = [pan velocityInView:self];
    NSLog(@"v: %@", NSStringFromCGPoint(v));
    if(ABS(v.x) > ABS(v.y)){
        return YES;
    }
    else{
        return NO;
    }
}
 */

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end