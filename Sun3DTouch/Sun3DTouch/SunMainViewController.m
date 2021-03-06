//
//  SunMainViewController.m
//  Sun3DTouch
//
//  Created by david on 2017/9/19.
//  Copyright © 2017年 David. All rights reserved.
//

#import "SunMainViewController.h"

#import "SunSecondController.h"


@interface SunMainViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)NSArray *arrData;

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation SunMainViewController

#pragma mark - lazy load
- (NSArray *)arrData {
    
    if (!_arrData) {
        
        _arrData = [NSArray array];
        
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i < 30; i++) {
            
            [arr addObject:@(i)];
        }
        
        _arrData = arr;
    }
    
    return _arrData;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        
    }
    
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self configTableView];

        
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"NOTIFICATION_RELOADDATA" object:nil];

}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView name:@"NOTIFICATION_RELOADDATA" object:nil];
}

- (void)configTableView {
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = self.view.bounds;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrData.count;
}

static NSString *reusedId = @"3dTouch";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusedId];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusedId];
    }
    
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    NSString *str = [NSString stringWithFormat:@"row [%@]", self.arrData[indexPath.row]];
    
    cell.textLabel.text = str;
    
    //注册3D Touch
    //只有在6s及其以上的设备才支持3D Touch,我们可以通过UITraitCollection这个类的UITraitEnvironment协议属性来判断
    /**
     UITraitCollection是UIViewController所遵守的其中一个协议，不仅包含了UI界面环境特征，而且包含了3D Touch的特征描述。
     从iOS9开始，我们可以通过这个类来判断运行程序对应的设备是否支持3D Touch功能。
     UIForceTouchCapabilityUnknown = 0,     //未知
     UIForceTouchCapabilityUnavailable = 1, //不可用
     UIForceTouchCapabilityAvailable = 2    //可用
     */
    
    if ([self respondsToSelector:@selector(traitCollection)]) {
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:(id)self sourceView:cell];
            }
        }
    }
    
    return cell;

}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.selected = NO;
    
    NSString *str = [NSString stringWithFormat:@"%@", self.arrData[indexPath.row]];

    SunSecondController *presentationVC = [[SunSecondController alloc] init];
    presentationVC.strInfo = str;
    
    [self.navigationController pushViewController:presentationVC animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 88.0;
}

#pragma mark - UIViewControllerPreviewingDelegate
#pragma mark peek(preview)
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0){
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
    NSString *str = [NSString stringWithFormat:@"%@",self.arrData[indexPath.row]];

    // 创建要预览的控制器
    SunSecondController *presentationVC = [[SunSecondController alloc] init];
    presentationVC.arrData = (NSMutableArray *)self.arrData;
    presentationVC.index = indexPath.row;
    presentationVC.strInfo = str;
    
    CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100);

    previewingContext.sourceRect = rect;
    
    return presentationVC;

}

#pragma mark pop(push)
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0){
    
    [self showViewController:viewControllerToCommit sender:self];

}
@end
