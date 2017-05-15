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
    self.isProgressiveIndicator = YES;
}

#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    NSDictionary *attrsText = @{
                                NSFontAttributeName: [UIFont boldSystemFontOfSize:35.0f],
                                NSForegroundColorAttributeName: [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleLight]
                                };
    
    ChildViewController *childA = [[ChildViewController alloc] init];
    childA.labelTextNode.attributedText = [[NSAttributedString alloc] initWithString:@"Child A"
                                                                          attributes:attrsText];
    ChildViewController *childB = [[ChildViewController alloc] init];
    childB.labelTextNode.attributedText = [[NSAttributedString alloc] initWithString:@"Child B"
                                                                          attributes:attrsText];
    ChildViewController *childC = [[ChildViewController alloc] init];
    childC.labelTextNode.attributedText = [[NSAttributedString alloc] initWithString:@"Child C"
                                                                          attributes:attrsText];
    ChildViewController *childD = [[ChildViewController alloc] init];
    childD.labelTextNode.attributedText = [[NSAttributedString alloc] initWithString:@"Child D"
                                                                          attributes:attrsText];
    ChildViewController *childE = [[ChildViewController alloc] init];
    childE.labelTextNode.attributedText = [[NSAttributedString alloc] initWithString:@"Child E"
                                                                          attributes:attrsText];
    ChildViewController *childF = [[ChildViewController alloc] init];
    childF.labelTextNode.attributedText = [[NSAttributedString alloc] initWithString:@"Child F"
                                                                          attributes:attrsText];
    
    return @[childA, childB, childC, childD, childE, childF];
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
