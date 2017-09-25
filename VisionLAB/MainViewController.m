//
//  ViewController.m
//  VisionLAB
//
//  Created by chance on 22/9/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "MainViewController.h"

@interface EntranceInfo : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *viewControllerName;
@end

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray <EntranceInfo *> *_entrances;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // add entrances
    [self addEntranceWithTitle:@"Base OpenCV" className:@"HelloOpenCVViewController"];
    [self addEntranceWithTitle:@"Convolution Test" className:@"BassOpenCVViewController"];
    [self addEntranceWithTitle:@"Gaussian Filter" className:nil];
    [self addEntranceWithTitle:@"Edge Detection" className:@""];

    [self quickEnterViewControllerAtIndex:0];
}


- (void)addEntranceWithTitle:(NSString *)title className:(NSString *)vcClassName {
    if (!_entrances) {
        _entrances = [NSMutableArray arrayWithCapacity:10];
    }
    EntranceInfo *info = [EntranceInfo new];
    info.title = title;
    info.viewControllerName = vcClassName;
    [_entrances addObject:info];
}


- (void)quickEnterViewControllerAtIndex:(NSInteger)idx {
    [self tableView:nil didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
}


#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _entrances.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainListCell"];
    EntranceInfo *info = _entrances[indexPath.row];
    cell.textLabel.text = info.title;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EntranceInfo *info = _entrances[indexPath.row];
    Class clazz = NSClassFromString(info.viewControllerName);
    if (!clazz) {
        NSLog(@"Error: Can not find view controller with name:%@", info.viewControllerName);
        return;
    }
    UIViewController *vc = [[clazz alloc] init];
    if ([vc isKindOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        NSLog(@"Error: class is not UIViewController !!!");
    }
}


@end


@implementation EntranceInfo
@end


