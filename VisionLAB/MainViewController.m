//
//  ViewController.m
//  VisionLAB
//
//  Created by chance on 22/9/2017.
//  Copyright © 2017 Bychance. All rights reserved.
//

#import "MainViewController.h"

typedef NS_ENUM(NSInteger, EntranceType) {
    EntranceTypeUnknown = -1,
    EntranceTypeLab = 0,
    EntranceTypeCourse,
};

@interface EntranceInfo : NSObject
@property (nonatomic, copy) NSAttributedString *title;
@property (nonatomic, copy) NSString *viewControllerName;
@end

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSArray <EntranceInfo *> *_mainList;
    NSMutableArray <EntranceInfo *> *_labEntranceList;
    NSMutableArray <EntranceInfo *> *_courseEntranceList;
    EntranceType _currentEntranceType;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarItem;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // add LAB entrances
    [self addLabEntranceWithTitle:@"Base OpenCV" className:@"HelloOpenCVViewController"];
    [self addLabEntranceWithTitle:@"Edge Detection" className:@"EdgeDetectionViewController"];
    [self addLabEntranceWithTitle:@"Camera Test" className:@"CameraViewController"];
    [self addLabEntranceWithTitle:@"Renderer Test" className:@"RendererViewController"];
    
    
    // add Course entrances
    [self addCourseEntranceWithTitle:@"2A-L1 Images as functions" className:@"C2AL1ViewController"];
    [self addCourseEntranceWithTitle:@"2A-L2 Filtering" className:@"C2AL2ViewController"];
    [self addCourseEntranceWithTitle:@"2A-L3 Linearity and convolution" className:@"C2AL3ViewController"];
    [self addCourseEntranceWithTitle:@"2A-L4 Renderer as templates" className:@"C2AL4ViewController"];
    [self addCourseEntranceWithTitle:@"2A-L5 Edge detection: Gradients" className:@"C2AL5ViewController"];
    [self addCourseEntranceWithTitle:@"2A-L6 Edge detection: 2D operators" className:@"C2AL6ViewController"];
    
    [self addCourseEntranceWithTitle:@"2B-L1 Hough transforms: Lines" className:@"C2BL1ViewController"];
    
    
    _currentEntranceType = EntranceTypeUnknown;
    [self swtichToEntrance:EntranceTypeCourse animated:NO];
    [self quickEnterViewControllerAtIndex:6];
}


- (void)addLabEntranceWithTitle:(NSString *)title className:(NSString *)vcClassName {
    if (!_labEntranceList) {
        _labEntranceList = [NSMutableArray arrayWithCapacity:10];
    }
    
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:title];
    [titleStr setAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor],
                              NSFontAttributeName : [UIFont systemFontOfSize:21 weight:UIFontWeightThin]}
                      range:NSMakeRange(0, title.length)];
    EntranceInfo *info = [EntranceInfo new];
    info.title = titleStr;
    info.viewControllerName = vcClassName;
    [_labEntranceList addObject:info];
}


- (void)addCourseEntranceWithTitle:(NSString *)title className:(NSString *)vcClassName {
    if (!_courseEntranceList) {
        _courseEntranceList = [NSMutableArray arrayWithCapacity:10];
    }
    
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:title];
    [titleStr setAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor],
                              NSFontAttributeName : [UIFont systemFontOfSize:20 weight:UIFontWeightRegular]}
                      range:NSMakeRange(5, title.length - 5)];
    [titleStr setAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor],
                              NSFontAttributeName : [UIFont systemFontOfSize:18 weight:UIFontWeightThin]}
                      range:NSMakeRange(0, 5)];
    EntranceInfo *info = [EntranceInfo new];
    info.title = titleStr;
    info.viewControllerName = vcClassName;
    [_courseEntranceList addObject:info];
}


- (void)quickEnterViewControllerAtIndex:(NSInteger)idx {
    if (idx >= _mainList.count) {
        NSLog(@"Error: invalid entrance index: %d", (int)idx);
        return;
    }
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
}


- (void)swtichToEntrance:(EntranceType)entranceType animated:(BOOL)animated {
    if (_currentEntranceType == entranceType) {
        return;
    }
    
    _currentEntranceType = entranceType;
    if (entranceType == EntranceTypeLab) {
        _mainList = [_labEntranceList copy];
        self.rightBarItem.image = [UIImage imageNamed:@"book_icon"];
        self.title = @"Vision LAB";
    } else {
        _mainList = [_courseEntranceList copy];
        self.rightBarItem.image = [UIImage imageNamed:@"lab_icon"];
        self.title = @"Introduction to Computer Vision";
    }
    if (animated) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation: UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }
}


- (IBAction)onSwitchEntrance:(UIBarButtonItem *)sender {
    if (_currentEntranceType == EntranceTypeLab) {
        [self swtichToEntrance:EntranceTypeCourse animated:YES];
        
    } else {
        [self swtichToEntrance:EntranceTypeLab animated:YES];
    }
}


#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mainList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainListCell"];
    EntranceInfo *info = _mainList[indexPath.row];
    cell.textLabel.attributedText = info.title;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EntranceInfo *info = _mainList[indexPath.row];
    if (!info.viewControllerName.length) {
        NSLog(@"Error: no view controller name");
        return;
    }
    if (![[NSBundle mainBundle] pathForResource:info.viewControllerName ofType:@"storyboardc"]) {
        NSLog(@"Error: can not find storyboard for %@", info.viewControllerName);
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:info.viewControllerName bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:info.viewControllerName];
    
    if (_currentEntranceType == EntranceTypeCourse) {
        vc.title = [info.title.string substringFromIndex:5];
    } else {
        vc.title = info.title.string;
    }
    [self.navigationController pushViewController:vc animated:YES];
}


@end


@implementation EntranceInfo
@end


