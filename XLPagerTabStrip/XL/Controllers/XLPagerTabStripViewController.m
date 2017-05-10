//
//  XLPagerTabStripViewController
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

#import "XLPagerTabStripViewController.h"

@interface XLPagerTabStripViewController ()

@property (readonly) NSArray *pagerTabStripChildViewControllersForScrolling;
@property (nonatomic) NSUInteger currentIndex;

@end

@implementation XLPagerTabStripViewController
{
    NSUInteger _lastPageNumber;
    CGFloat _lastContentOffset;
    NSUInteger _pageBeforeRotate;
    CGSize _lastSize;
}

@synthesize currentIndex = _currentIndex;
@synthesize pagerTabStripChildViewControllersForScrolling = _pagerTabStripChildViewControllersForScrolling;

#pragma maek - initializers

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self pagerTabStripViewControllerInit];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self pagerTabStripViewControllerInit];
    }
    return self;
}

- (instancetype)init {
    ASDisplayNode *node = [[ASDisplayNode alloc] init];
    
    self = [super initWithNode:node];
    if(self) {
        self.node.automaticallyManagesSubnodes = YES;
        self.node.backgroundColor = [UIColor lightGrayColor];
        
        [self pagerTabStripViewControllerInit];
        
        ASPagerFlowLayout *flowLayout = [[ASPagerFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumLineSpacing = 0.0f;
        flowLayout.minimumInteritemSpacing = 0.0f;
        
        self.containerPagerNode = [[ASPagerNode alloc] initWithCollectionViewLayout:flowLayout];
        self.containerPagerNode.allowsAutomaticInsetsAdjustment = YES;
        self.containerPagerNode.view.collectionNode.delegate = self;
        
        [self.containerPagerNode setDelegate:self];
        [self.containerPagerNode setDataSource:self];
    }
    return self;
}

#pragma mark - ASPager code start -

#pragma mark - ASPagerNodeDataSource

- (NSInteger)numberOfPagesInPagerNode:(ASPagerNode *)pagerNode
{
    return self.pagerTabStripChildViewControllersForScrolling.count;
}

- (ASCellNodeBlock)pagerNode:(ASPagerNode *)pagerNode nodeBlockAtIndex:(NSInteger)index
{
    id childViewController = [self.pagerTabStripChildViewControllersForScrolling objectAtIndex:index];
    
    return ^{
        ASCellNode *cellNode = [[ASCellNode alloc] initWithViewControllerBlock:^UIViewController * _Nonnull {
            return childViewController;
        } didLoadBlock:nil];
        return cellNode;
    };
}

#pragma mark - ASPagerNodeDelegate

- (void)collectionNode:(ASCollectionNode *)collectionNode willDisplayItemWithNode:(ASCellNode *)node {
    //self.currentIndex = [collectionNode indexPathForNode:node].item;
    NSLog(@"Curren Index: %lu", (unsigned long)self.currentIndex);
}

#pragma mark - ASPager code end -

-(void)dealloc
{
    self.containerPagerNode.view.delegate = nil;
}

-(void)pagerTabStripViewControllerInit
{
    _currentIndex = 0;
    _delegate = self;
    _dataSource = self;
    _lastContentOffset = 0.0f;
    _isElasticIndicatorLimit = NO;
    _skipIntermediateViewControllers = YES;
    _isProgressiveIndicator = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.dataSource){
        _pagerTabStripChildViewControllers = [self.dataSource childViewControllersForPagerTabStripViewController:self];
    }
    
    //self.containerPagerNode.clipsToBounds = YES;
    //self.containerPagerNode.view.bounces = YES;
    //self.containerPagerNode.view.alwaysBounceHorizontal = NO;
    //self.containerPagerNode.view.alwaysBounceVertical = NO;
    //self.containerPagerNode.view.scrollsToTop = NO;
    //self.containerPagerNode.view.delegate = self;
    //self.containerPagerNode.view.showsVerticalScrollIndicator = NO;
    //self.containerPagerNode.view.showsHorizontalScrollIndicator = NO;
    //self.containerPagerNode.view.pagingEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _lastSize = self.containerPagerNode.bounds.size;
    [self updateIfNeeded];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateIfNeeded];
    if  ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending){
        // SYSTEM_VERSION_LESS_THAN 8.0
        [self.node layoutIfNeeded];
    }
}

#pragma mark - Properties

- (NSArray *)pagerTabStripChildViewControllersForScrolling
{
    // If a temporary re-ordered version of the view controllers is available return that
    // (i.e. skipIntermediateViewControllers==YES, the user has tapped a tab/cell and
    // we're animating using the re-ordered version)
    // Otherwise just return the normally ordered pagerTabStripChildViewControllers
    return _pagerTabStripChildViewControllersForScrolling ?: self.pagerTabStripChildViewControllers;
}

#pragma mark - move to another view controller

-(void)moveToViewControllerAtIndex:(NSUInteger)index
{
    [self moveToViewControllerAtIndex:index animated:YES];
}


-(void)moveToViewControllerAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (!self.isViewLoaded || !self.view.window){
        self.currentIndex = index;
    }
    else{
        if (animated && self.skipIntermediateViewControllers && ABS(self.currentIndex - index) > 1){
            NSMutableArray * tempChildViewControllers = [NSMutableArray arrayWithArray:self.pagerTabStripChildViewControllers];
            UIViewController *currentChildVC = [self.pagerTabStripChildViewControllers objectAtIndex:self.currentIndex];
            NSUInteger fromIndex = (self.currentIndex < index) ? index - 1 : index + 1;
            UIViewController *fromChildVC = [self.pagerTabStripChildViewControllers objectAtIndex:fromIndex];
            [tempChildViewControllers setObject:fromChildVC atIndexedSubscript:self.currentIndex];
            [tempChildViewControllers setObject:currentChildVC atIndexedSubscript:fromIndex];
            _pagerTabStripChildViewControllersForScrolling = tempChildViewControllers;
            //            [self.containerPagerNode.view setContentOffset:CGPointMake([self pageOffsetForChildIndex:fromIndex], 0) animated:NO];
            if (self.navigationController){
                self.navigationController.view.userInteractionEnabled = NO;
            }
            else{
                self.node.userInteractionEnabled = NO;
            }
            [self.containerPagerNode scrollToPageAtIndex:index animated:YES];
            //            [self.containerPagerNode.view setContentOffset:CGPointMake([self pageOffsetForChildIndex:index], 0) animated:YES];
        }
        else{
            [self.containerPagerNode scrollToPageAtIndex:index animated:animated];
            //            [self.containerPagerNode.view setContentOffset:CGPointMake([self pageOffsetForChildIndex:index], 0) animated:animated];
        }
        
    }
}

-(void)moveToViewController:(UIViewController *)viewController
{
    [self moveToViewControllerAtIndex:[self.pagerTabStripChildViewControllers indexOfObject:viewController]];
}

-(void)moveToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self moveToViewControllerAtIndex:[self.pagerTabStripChildViewControllers indexOfObject:viewController] animated:animated];
}


#pragma mark - XLPagerTabStripViewControllerDelegate

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex{
    
}

-(void)pagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
          updateIndicatorFromIndex:(NSInteger)fromIndex
                           toIndex:(NSInteger)toIndex
            withProgressPercentage:(CGFloat)progressPercentage
                   indexWasChanged:(BOOL)indexWasChanged
{
}


#pragma mark - XLPagerTabStripViewControllerDataSource

-(NSArray *)childViewControllersForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController
{
    NSAssert(NO, @"Sub-class must implement the XLPagerTabStripViewControllerDataSource childViewControllersForPagerTabStripViewController: method");
    return nil;
}


#pragma mark - Helpers

-(void)updateIfNeeded
{
    if (!CGSizeEqualToSize(_lastSize, self.containerPagerNode.bounds.size)){
        [self updateContent];
    }
}

-(XLPagerTabStripDirection)scrollDirection
{
    if (self.containerPagerNode.view.contentOffset.x > _lastContentOffset){
        return XLPagerTabStripDirectionLeft;
    }
    else if (self.containerPagerNode.view.contentOffset.x < _lastContentOffset){
        return XLPagerTabStripDirectionRight;
    }
    return XLPagerTabStripDirectionNone;
}

-(BOOL)canMoveToIndex:(NSUInteger)index
{
    return (self.currentIndex != index && self.pagerTabStripChildViewControllers.count > index);
}

-(CGFloat)pageOffsetForChildIndex:(NSUInteger)index
{
    return (index * CGRectGetWidth(self.containerPagerNode.bounds));
}

-(CGFloat)offsetForChildIndex:(NSUInteger)index
{
    if (CGRectGetWidth(self.containerPagerNode.bounds) > CGRectGetWidth(self.view.bounds)){
        return (index * CGRectGetWidth(self.containerPagerNode.bounds) + ((CGRectGetWidth(self.containerPagerNode.bounds) - CGRectGetWidth(self.view.bounds)) * 0.5));
    }
    return (index * CGRectGetWidth(self.containerPagerNode.bounds));
}

-(CGFloat)offsetForChildViewController:(UIViewController *)viewController
{
    NSInteger index = [self.pagerTabStripChildViewControllers indexOfObject:viewController];
    if (index == NSNotFound){
        @throw [NSException exceptionWithName:NSRangeException reason:nil userInfo:nil];
    }
    return [self offsetForChildIndex:index];
}

-(NSUInteger)pageForContentOffset:(CGFloat)contentOffset
{
    NSInteger result = [self virtualPageForContentOffset:contentOffset];
    return [self pageForVirtualPage:result];
}

-(NSInteger)virtualPageForContentOffset:(CGFloat)contentOffset
{
    NSInteger result = (contentOffset + (1.5f * [self pageWidth])) / [self pageWidth];
    return result - 1;
}

-(NSUInteger)pageForVirtualPage:(NSInteger)virtualPage
{
    if (virtualPage < 0){
        return 0;
    }
    if (virtualPage > self.pagerTabStripChildViewControllers.count - 1){
        return self.pagerTabStripChildViewControllers.count - 1;
    }
    return virtualPage;
}

-(CGFloat)pageWidth
{
    return CGRectGetWidth(self.containerPagerNode.bounds);
}

-(CGFloat)scrollPercentage
{
    if ([self scrollDirection] == XLPagerTabStripDirectionLeft || [self scrollDirection] == XLPagerTabStripDirectionNone){
        if (fmodf(self.containerPagerNode.view.contentOffset.x, [self pageWidth]) == 0.0) {
            return 1.0;
        }
        return fmodf(self.containerPagerNode.view.contentOffset.x, [self pageWidth]) / [self pageWidth];
    }
    return 1 - fmodf(self.containerPagerNode.view.contentOffset.x >= 0 ? self.containerPagerNode.view.contentOffset.x : [self pageWidth] + self.containerPagerNode.view.contentOffset.x, [self pageWidth]) / [self pageWidth];
}

-(void)updateContent
{
    if (!CGSizeEqualToSize(_lastSize, self.containerPagerNode.bounds.size)){
        if (_lastSize.width != self.containerPagerNode.bounds.size.width){
            _lastSize = self.containerPagerNode.bounds.size;
            
            [self.containerPagerNode scrollToPageAtIndex:self.currentIndex animated:NO];
            
            //            [self.containerPagerNode setContentOffset:CGPointMake([self pageOffsetForChildIndex:self.currentIndex], 0) animated:NO];
        }
        else{
            _lastSize = self.containerPagerNode.bounds.size;
        }
    }
    
    NSArray * childViewControllers = self.pagerTabStripChildViewControllersForScrolling;
    self.containerPagerNode.view.contentSize = CGSizeMake(CGRectGetWidth(self.containerPagerNode.bounds) * childViewControllers.count, self.containerPagerNode.view.contentSize.height);
    
    NSUInteger oldCurrentIndex = self.currentIndex;
    NSInteger virtualPage = [self virtualPageForContentOffset:self.containerPagerNode.view.contentOffset.x];
    NSUInteger newCurrentIndex = [self pageForVirtualPage:virtualPage];
    self.currentIndex = newCurrentIndex;
    BOOL changeCurrentIndex = newCurrentIndex != oldCurrentIndex;
    
    if (self.isProgressiveIndicator){
        if ([self.delegate respondsToSelector:@selector(pagerTabStripViewController:updateIndicatorFromIndex:toIndex:withProgressPercentage:indexWasChanged:)]){
            CGFloat scrollPercentage = [self scrollPercentage];
            NSLog(@"Scroll Percentage: %f", scrollPercentage);
            if (scrollPercentage > 0) {
                NSInteger fromIndex = self.currentIndex;
                NSInteger toIndex = self.currentIndex;
                XLPagerTabStripDirection scrollDirection = [self scrollDirection];
                if (scrollDirection == XLPagerTabStripDirectionLeft){
                    if (virtualPage > self.pagerTabStripChildViewControllersForScrolling.count - 1){
                        fromIndex = self.pagerTabStripChildViewControllersForScrolling.count - 1;
                        toIndex = self.pagerTabStripChildViewControllersForScrolling.count;
                    }
                    else{
                        if (scrollPercentage >= 0.5f){
                            fromIndex = MAX(toIndex - 1, 0);
                        }
                        else{
                            toIndex = fromIndex + 1;
                        }
                    }
                }
                else if (scrollDirection == XLPagerTabStripDirectionRight) {
                    if (virtualPage < 0){
                        fromIndex = 0;
                        toIndex = -1;
                    }
                    else{
                        if (scrollPercentage > 0.5f){
                            fromIndex = MIN(toIndex + 1, self.pagerTabStripChildViewControllersForScrolling.count - 1);
                        }
                        else{
                            toIndex = fromIndex - 1;
                        }
                    }
                }
                [self.delegate pagerTabStripViewController:self updateIndicatorFromIndex:fromIndex toIndex:toIndex withProgressPercentage:(self.isElasticIndicatorLimit ? scrollPercentage : ( toIndex < 0 || toIndex >= self.pagerTabStripChildViewControllersForScrolling.count ? 0 : scrollPercentage )) indexWasChanged:changeCurrentIndex];
            }
        }
    }
    else{
        if ([self.delegate respondsToSelector:@selector(pagerTabStripViewController:updateIndicatorFromIndex:toIndex:)] && oldCurrentIndex != newCurrentIndex){
            [self.delegate pagerTabStripViewController:self
                              updateIndicatorFromIndex:MIN(oldCurrentIndex, self.pagerTabStripChildViewControllersForScrolling.count - 1)
                                               toIndex:newCurrentIndex];
        }
    }
}


-(void)reloadPagerTabStripView
{
    if ([self isViewLoaded]){
        [self.pagerTabStripChildViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController * childController = (UIViewController *)obj;
            if ([childController parentViewController]){
                [childController.view removeFromSuperview];
                [childController willMoveToParentViewController:nil];
                [childController removeFromParentViewController];
            }
        }];
        _pagerTabStripChildViewControllers = self.dataSource ? [self.dataSource childViewControllersForPagerTabStripViewController:self] : @[];
        self.containerPagerNode.view.contentSize = CGSizeMake(CGRectGetWidth(self.containerPagerNode.bounds) * self.pagerTabStripChildViewControllers.count, self.containerPagerNode.view.contentSize.height);
        if (self.currentIndex >= self.pagerTabStripChildViewControllers.count){
            self.currentIndex = self.pagerTabStripChildViewControllers.count - 1;
        }
        [self.containerPagerNode scrollToPageAtIndex:self.currentIndex animated:NO];
        //        [self.containerPagerNode setContentOffset:CGPointMake([self pageOffsetForChildIndex:self.currentIndex], 0)  animated:NO];
        [self updateContent];
    }
}

#pragma mark - UIScrollViewDelegte

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.containerPagerNode.view == scrollView){
        [self updateContent];
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.containerPagerNode.view == scrollView){
        _lastPageNumber = [self pageForContentOffset:scrollView.contentOffset.x];
        _lastContentOffset = scrollView.contentOffset.x;
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (self.containerPagerNode.view == scrollView && _pagerTabStripChildViewControllersForScrolling){
        _pagerTabStripChildViewControllersForScrolling = nil;
        
        [self updateContent];
    }
    
    if (self.navigationController){
        self.navigationController.view.userInteractionEnabled = YES;
    }
    else{
        self.node.userInteractionEnabled = YES;
    }
}

#pragma mark - Orientation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    _pageBeforeRotate = self.currentIndex;
    __typeof__(self) __weak weakSelf = self;
    [coordinator animateAlongsideTransition:nil
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                                     weakSelf.currentIndex = _pageBeforeRotate;
                                     [weakSelf updateIfNeeded];
                                 }];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _pageBeforeRotate = self.currentIndex;
}

@end
