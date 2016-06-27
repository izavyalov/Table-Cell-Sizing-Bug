//
//  TableViewController.m
//  Table Cell Sizing Bug
//
//  Created by Tim Arnold on 12/4/14.
//  Copyright (c) 2014 Friends of The Web. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"

#define SHOW_BUG 1
/*
 * Delete cells in batch such that only invisible cell left, that would move to visible section after 
 * deletions done. However internals UITableView either request 'heightForRow...' if defined on delegate, 
 * or fails with exception
 * 'NSInternalInconsistencyException', reason: 'request for rect at invalid index path (<NSIndexPath: ..>)'
 */
#define DELETE_ALL_RETAIN_INVISIBLE_CELLS_BUG 1

@interface TableViewController()
@property (assign) deleteDone;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if SHOW_BUG
    self.tableView.estimatedRowHeight = 44.f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
#endif
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row != 0) {
        [tableView beginUpdates];
#if DELETE_ALL_RETAIN_INVISIBLE_CELLS_BUG
        if (!_deleteDone) {
            _deleteDone = YES;
            NSMutableArray *indexes = [[NSMutableArray alloc] initWithCapacity: 200];
            for (size_t i = 0; i < 200) {
                if (i == 195) // The cell 195 would be expected in top of list. 
                    continue;
                [indexes addObject: [NSIndexPath indexPathForRow:i inSection:0]];
            }
            [tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
        }
#else
        [tableView moveRowAtIndexPath:indexPath
                          toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
#endif
        [tableView endUpdates];
    }
}

#if !SHOW_BUG
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.f;
}
#endif

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_deleteDone)
        return 1;
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                          forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithHue:1 - (indexPath.row / 200.)
                                      saturation:1 - (indexPath.row / 200.)
                                      brightness:1 - (indexPath.row / 200.)
                                           alpha:1];
    return cell;
}


@end
