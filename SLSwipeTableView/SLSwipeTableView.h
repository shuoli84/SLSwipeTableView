//
//  SLSwipeTableView.h
//  SLSwipeTableView
//
//  Created by Li Shuo on 13-11-30.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLSwipeTableView;

@protocol SLSwipeTableViewDelegate <NSObject, UITableViewDelegate>

/**
 * Return the items for row on left or right sides, the items should be UIButton's array.
 */
-(NSArray*)swipeTableView:(SLSwipeTableView *)tableView itemsForIndexPath:(NSIndexPath*)indexPath onLeft:(BOOL)left;

/**
* Button selected
*/
-(void)swipeTableView:(SLSwipeTableView *)tableView didSelectedForIndexPath:(NSIndexPath*)indexPath
                index:(NSInteger)index
               onLeft:(BOOL)left;

@end

@interface SLSwipeTableView : UITableView

@property (nonatomic, weak) id<SLSwipeTableViewDelegate> delegate;

@end
