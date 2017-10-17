//
//  CourseListViewController.m
//  VisionLAB
//
//  Created by chance on 18/10/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "CourseListViewController.h"
#import "C2AL1ViewController.h"

@interface CourseInfo : NSObject
@property (nonatomic, copy) NSAttributedString *title;
@property (nonatomic, copy) NSString *viewControllerName;
@end

@interface CourseListViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray <CourseInfo *> *_entrances;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CourseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add entrances
    [self addEntranceWithTitle:@"2A-L1 Images as functions" className:@"C2AL1ViewController"];
    [self addEntranceWithTitle:@"2A-L2 Filtering" className:nil];
    [self addEntranceWithTitle:@"2A-L3 Linearity and convolution" className:nil];
    [self addEntranceWithTitle:@"2A-L4 Filter as templates" className:nil];
    [self addEntranceWithTitle:@"2A-L5 Edge Detection" className:nil];
    
    [self quickEnterViewControllerAtIndex:0];
}


- (void)addEntranceWithTitle:(NSString *)title className:(NSString *)vcClassName {
    if (!_entrances) {
        _entrances = [NSMutableArray arrayWithCapacity:10];
    }
    
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:title];
    [titleStr setAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor],
                              NSFontAttributeName : [UIFont systemFontOfSize:20 weight:UIFontWeightRegular]}
                      range:NSMakeRange(5, title.length - 5)];
    [titleStr setAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor],
                              NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightThin]}
                      range:NSMakeRange(0, 5)];
    CourseInfo *info = [CourseInfo new];
    info.title = [titleStr copy];
    info.viewControllerName = vcClassName;
    [_entrances addObject:info];
}


- (void)quickEnterViewControllerAtIndex:(NSInteger)idx {
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
}


#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _entrances.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourseListCell"];
    CourseInfo *info = _entrances[indexPath.row];
    cell.textLabel.attributedText = info.title;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CourseInfo *info = _entrances[indexPath.row];
    Class clazz = NSClassFromString(info.viewControllerName);
    if (!clazz) {
        NSLog(@"Error: Can not find view controller with name:%@", info.viewControllerName);
        return;
    }
    UIViewController *vc = [[clazz alloc] init];
    vc.title = [info.title.string substringFromIndex:5];
    NSLog(@"Titlt: %@", vc.title);
    if ([vc isKindOfClass:[UIViewController class]]) {
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        NSLog(@"Error: class is not UIViewController !!!");
    }
}


@end


@implementation CourseInfo
@end

