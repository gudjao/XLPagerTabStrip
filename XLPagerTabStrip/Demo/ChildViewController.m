//
//  ChildViewController.m
//  XLPagerTabStrip
//
//  Created by Juston Paul Alcantara on 08/05/2017.
//  Copyright © 2017 Xmartlabs. All rights reserved.
//

#import "ChildViewController.h"

@interface ChildViewController ()

@end

@implementation ChildViewController

- (instancetype)init {
    self = [super initWithNode:[[ASDisplayNode alloc] init]];
    if(self) {
        self.node.automaticallyManagesSubnodes = YES;
        
        self.node.backgroundColor = [UIColor colorWithRandomFlatColorOfShadeStyle:UIShadeStyleDark];
        
        self.labelTextNode = [[ASTextNode alloc] init];
        
        __weak typeof(self) weakSelf = self;
        
        self.node.layoutSpecBlock = ^ASLayoutSpec *(ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            return [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                                              sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                                      child:weakSelf.labelTextNode];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return self.labelTextNode.attributedText.string;
}

-(UIColor *)colorForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    return [UIColor whiteColor];
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
