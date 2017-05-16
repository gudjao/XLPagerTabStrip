//
//  XLButtonBarPagerTabStripViewController.m
//  XLPagerTabStrip ( https://github.com/xmartlabs/XLPagerTabStrip )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XLButtonBarViewCell.h"
#import "XLButtonBarPagerTabStripViewController.h"

@interface XLButtonBarPagerTabStripViewController () <ASCollectionDelegate, ASCollectionDataSource>

@property (nonatomic) XLButtonBarView * buttonBarView;
@property (nonatomic) BOOL shouldUpdateButtonBarView;
@property (nonatomic) BOOL isViewAppearing;
@property (nonatomic) BOOL isViewRotating;

@end

@implementation XLButtonBarPagerTabStripViewController

#pragma mark - Initialisation

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldUpdateButtonBarView = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.shouldUpdateButtonBarView = YES;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldUpdateButtonBarView = YES;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _buttonBarView = [[XLButtonBarView alloc] initWithCollectionViewLayout:flowLayout];
        _buttonBarView.backgroundColor = [UIColor orangeColor];
        _buttonBarView.selectedBar.backgroundColor = [UIColor yellowColor];
        _buttonBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _buttonBarView.delegate = self;
        _buttonBarView.dataSource = self;
        
        __weak typeof(self) weakSelf = self;
        
        self.node.layoutSpecBlock = ^ASLayoutSpec *(ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            
            weakSelf.buttonBarView.style.preferredSize = CGSizeMake(constrainedSize.max.width, 44.0f);
            weakSelf.containerPagerNode.style.preferredSize = constrainedSize.max;
            weakSelf.containerPagerNode.style.flexShrink = 1.0f;
            
            ASStackLayoutSpec *buttonViewStack =
            [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                    spacing:0.0f
                                             justifyContent:ASStackLayoutJustifyContentStart
                                                 alignItems:ASStackLayoutAlignItemsStretch
                                                   children:@[weakSelf.buttonBarView,
                                                              weakSelf.containerPagerNode]];
            
            return buttonViewStack;
        };
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttonBarView.labelFont = [UIFont boldSystemFontOfSize:18.0f];
    self.buttonBarView.leftRightMargin = 8;
    self.buttonBarView.view.scrollsToTop = NO;
    self.buttonBarView.view.showsHorizontalScrollIndicator = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.buttonBarView moveToIndex:self.currentIndex animated:NO swipeDirection:XLPagerTabStripDirectionNone pagerScroll:XLPagerScrollOnlyIfOutOfScreen];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.buttonBarView layoutIfNeeded];
    self.isViewAppearing = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isViewAppearing = NO;
}

//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//
//    if (self.isViewAppearing || self.isViewRotating) {
//        // Force the UICollectionViewFlowLayout to get laid out again with the new size if
//        // a) The view is appearing.  This ensures that
//        //    collectionView:layout:sizeForItemAtIndexPath: is called for a second time
//        //    when the view is shown and when the view *frame(s)* are actually set
//        //    (we need the view frame's to have been set to work out the size's and on the
//        //    first call to collectionView:layout:sizeForItemAtIndexPath: the view frame(s)
//        //    aren't set correctly)
//        // b) The view is rotating.  This ensures that
//        //    collectionView:layout:sizeForItemAtIndexPath: is called again and can use the views
//        //    *new* frame so that the buttonBarView cell's actually get resized correctly
//        self.cachedCellWidths = nil; // Clear/invalidate our cache of cell widths
//        UICollectionViewFlowLayout *flowLayout = (id)self.buttonBarView.collectionViewLayout;
//        [flowLayout invalidateLayout];
//
//        // Ensure the buttonBarView.frame is sized correctly after rotation on iOS 7 devices
//        [self.buttonBarView layoutIfNeeded];
//
//        // When the view first appears or is rotated we also need to ensure that the barButtonView's
//        // selectedBar is resized and its contentOffset/scroll is set correctly (the selected
//        // tab/cell may end up either skewed or off screen after a rotation otherwise)
//        [self.buttonBarView moveToIndex:self.currentIndex animated:NO swipeDirection:XLPagerTabStripDirectionNone pagerScroll:XLPagerScrollOnlyIfOutOfScreen];
//    }
//}


#pragma mark - View Rotation

// Called on iOS 8+ only
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.isViewRotating = YES;
    __typeof__(self) __weak weakSelf = self;
    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     weakSelf.isViewRotating = NO;
                                 }];
}

// Called on iOS 7 only
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.isViewRotating = YES;
}

#pragma mark - Public methods

-(void)reloadPagerTabStripView
{
    [super reloadPagerTabStripView];
    if ([self isViewLoaded]){
        [self.buttonBarView reloadData];
        [self.buttonBarView moveToIndex:self.currentIndex animated:NO swipeDirection:XLPagerTabStripDirectionNone pagerScroll:XLPagerScrollYES];
    }
}

#pragma mark - XLPagerTabStripViewControllerDelegate

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
{
    if (self.shouldUpdateButtonBarView){
        XLPagerTabStripDirection direction = XLPagerTabStripDirectionLeft;
        if (toIndex < fromIndex){
            direction = XLPagerTabStripDirectionRight;
        }
        [self.buttonBarView moveToIndex:toIndex animated:YES swipeDirection:direction pagerScroll:XLPagerScrollYES];
        if (self.changeCurrentIndexBlock) {
            XLButtonBarViewCell *oldCell = (XLButtonBarViewCell*)[self.buttonBarView nodeForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex != fromIndex ? fromIndex : toIndex inSection:0]];
            XLButtonBarViewCell *newCell = (XLButtonBarViewCell*)[self.buttonBarView nodeForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
            self.changeCurrentIndexBlock(oldCell, newCell, YES);
        }
    }
}

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
            withProgressPercentage:(CGFloat)progressPercentage
                   indexWasChanged:(BOOL)indexWasChanged
{
    if (self.shouldUpdateButtonBarView){
        [self.buttonBarView moveFromIndex:fromIndex
                                  toIndex:toIndex
                   withProgressPercentage:progressPercentage pagerScroll:XLPagerScrollYES];
        
        if (self.changeCurrentIndexProgressiveBlock) {
            XLButtonBarViewCell *oldCell = (XLButtonBarViewCell*)[self.buttonBarView nodeForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex != fromIndex ? fromIndex : toIndex inSection:0]];
            XLButtonBarViewCell *newCell = (XLButtonBarViewCell*)[self.buttonBarView nodeForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
            self.changeCurrentIndexProgressiveBlock(oldCell, newCell, progressPercentage, indexWasChanged, YES);
        }
    }
}

#pragma mark - ASCollectionNodeDelegateFlowLayout

- (ASSizeRange)collectionNode:(ASCollectionNode *)collectionNode constrainedSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float collectioNodeHeight = collectionNode.frame.size.height;
    
    //NSLog(@"%f", collectionNode.frame.size.width);
    
    if(self.fitAllChildren) {
        return ASSizeRangeMake(CGSizeMake(collectionNode.frame.size.width / self.pagerTabStripChildViewControllers.count, collectioNodeHeight));
    } else {
        return ASSizeRangeMake(CGSizeMake(0, collectioNodeHeight), CGSizeMake(FLT_MAX, collectioNodeHeight));
    }
//    if (self.cachedCellWidths.count > indexPath.row)
//    {
//        NSNumber *cellWidthValue = self.cachedCellWidths[indexPath.row];
//        CGFloat cellWidth = [cellWidthValue floatValue];
//        return ASSizeRangeMake(CGSizeMake(cellWidth, collectionNode.frame.size.height));
//    }
//    return ASSizeRangeZero;
}

#pragma mark - ASCollectionNodeDelegate

- (void)collectionNode:(ASCollectionNode *)collectionNode didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //There's nothing to do if we select the current selected tab
    if (indexPath.item == self.currentIndex)
        return;
    
    [self.buttonBarView moveToIndex:indexPath.item animated:YES swipeDirection:XLPagerTabStripDirectionNone pagerScroll:XLPagerScrollYES];
    self.shouldUpdateButtonBarView = NO;
    
    XLButtonBarViewCell *oldCell = (XLButtonBarViewCell*)[self.buttonBarView nodeForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
    XLButtonBarViewCell *newCell = (XLButtonBarViewCell*)[self.buttonBarView nodeForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
    
    if (self.isProgressiveIndicator) {
        if (self.changeCurrentIndexProgressiveBlock) {
            self.changeCurrentIndexProgressiveBlock(oldCell, newCell, 1, YES, YES);
        }
    }
    else{
        if (self.changeCurrentIndexBlock) {
            self.changeCurrentIndexBlock(oldCell, newCell, YES);
        }
    }
    
    [self moveToViewControllerAtIndex:indexPath.item];
}

#pragma merk - ASCollectionNodeDataSource

- (NSInteger)collectionNode:(ASCollectionNode *)collectionNode numberOfItemsInSection:(NSInteger)section
{
    return self.pagerTabStripChildViewControllers.count;
}

- (ASCellNodeBlock)collectionNode:(ASCollectionNode *)collectionNode nodeBlockForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController<XLPagerTabStripChildItem> * childController =   [self.pagerTabStripChildViewControllers objectAtIndex:indexPath.item];
    
    return ^{
        XLButtonBarViewCell *buttonBarCell = [[XLButtonBarViewCell alloc] init];
        buttonBarCell.backgroundColor = [UIColor greenColor];
        
        // Text Attributes
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        // Label
        UIFont *labelFont;
        if (self.buttonBarView.labelFont) {
            labelFont = self.buttonBarView.labelFont;
        } else {
            labelFont = [UIFont systemFontOfSize:14.0f weight:UIFontWeightMedium];
        }
        
        NSDictionary *attrsText = @{
                                    NSFontAttributeName: labelFont,
                                    NSForegroundColorAttributeName: [childController colorForPagerTabStripViewController:self],
                                    NSParagraphStyleAttributeName : paragraphStyle
                                    };
        
        buttonBarCell.label.attributedText = [[NSAttributedString alloc] initWithString:[childController titleForPagerTabStripViewController:self]
                                                                             attributes:attrsText];
        
        // Image
        if ([childController respondsToSelector:@selector(imageForPagerTabStripViewController:)]) {
            UIImage *image = [childController imageForPagerTabStripViewController:self];
            buttonBarCell.imageView.image = image;
        }
        
        if ([childController respondsToSelector:@selector(highlightedImageForPagerTabStripViewController:)]) {
            UIImage *image = [childController highlightedImageForPagerTabStripViewController:self];
#pragma warning - Deprecate? or Fix?
        }
        
        if (self.isProgressiveIndicator) {
            if (self.changeCurrentIndexProgressiveBlock) {
                self.changeCurrentIndexProgressiveBlock(self.currentIndex == indexPath.item ? nil : buttonBarCell , self.currentIndex == indexPath.item ? buttonBarCell : nil, 1, YES, NO);
            }
        }
        else{
            if (self.changeCurrentIndexBlock) {
                self.changeCurrentIndexBlock(self.currentIndex == indexPath.item ? nil : buttonBarCell , self.currentIndex == indexPath.item ? buttonBarCell : nil, NO);
            }
        }
        
        return buttonBarCell;
    };
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [super scrollViewDidEndScrollingAnimation:scrollView];
    if (scrollView == self.containerPagerNode.view){
        self.shouldUpdateButtonBarView = YES;
    }
}


@end
