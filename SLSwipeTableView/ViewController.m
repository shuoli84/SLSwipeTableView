//
//  ViewController.m
//  SLSwipeTableView
//
//  Created by Li Shuo on 13-11-30.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import "ViewController.h"
#import "SLSwipeTableView.h"

@interface ViewController () <UITableViewDataSource, SLSwipeTableViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    SLSwipeTableView *tableView = [[SLSwipeTableView alloc]initWithFrame:self.view.bounds];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:tableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    
    return cell;
}

-(NSArray*)swipeTableView:(SLSwipeTableView *)tableView itemsForIndexPath:(NSIndexPath *)indexPath onLeft:(BOOL)left{
    if(left){
        return @[
                 @"Insert",
                @"Add To List",
                 ];
    }
    else{
         UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"right" forState:UIControlStateNormal];
        return @[
            @"Right 1",
            @"Right 2",
                 ];
    }
}

-(void)swipeTableView:(SLSwipeTableView *)tableView didSelectedForIndexPath:(NSIndexPath *)indexPath index:(NSInteger)index onLeft:(BOOL)left {
    NSLog(@"indexPath: %@ index:%d left:%d", indexPath, index, left);
}
@end
