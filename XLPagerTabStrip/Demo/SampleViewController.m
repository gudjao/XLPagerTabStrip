//
//  SampleViewController.m
//  XLPagerTabStrip
//
//  Created by Juston Paul Alcantara on 08/05/2017.
//  Copyright © 2017 Xmartlabs. All rights reserved.
//

#import "SampleViewController.h"

@interface SampleViewController ()

@end

@implementation SampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.isProgressiveIndicator = NO;
    
    [self.buttonBarView.selectedBar setBackgroundColor:[UIColor orangeColor]];
}

#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    ChildViewController *childA = [[ChildViewController alloc] init];
    ChildViewController *childB = [[ChildViewController alloc] init];
    
    return @[childA, childB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
