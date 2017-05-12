//
//  XLButtonBarView.m
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


#import "XLButtonBarView.h"

#import "XLButtonBarViewCell.h"

@interface XLButtonBarView ()

@property ASDisplayNode * selectedBar;
@property NSUInteger selectedOptionIndex;

@end

@implementation XLButtonBarView

- (instancetype)init {
    self = [super init];
    if(self) {
        self.automaticallyManagesSubnodes = YES;
        
        _selectedOptionIndex = 0;
        _selectedBarHeight = 5;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 35, 0, 35);
        self.collectionNode = [[ASCollectionNode alloc] initWithCollectionViewLayout:flowLayout];
        
        self.selectedBar = [[ASDisplayNode alloc] init];
        self.selectedBar.layer.zPosition = 9999;
        self.selectedBar.backgroundColor = [UIColor yellowColor];
        self.selectedBar.frame = CGRectMake(35, 44.0f - _selectedBarHeight, 0, _selectedBarHeight);
        //CGRectMake(0, self.frame.size.height - _selectedBarHeight, 0, _selectedBarHeight)];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
    self.collectionNode.style.preferredSize = constrainedSize.max;
    
    CGPoint point = self.selectedBar.frame.origin;
    //point.y = constrainedSize.max.height - _selectedBarHeight;
    CGSize size = self.selectedBar.frame.size;
    
    self.selectedBar.style.layoutPosition = point;
    self.selectedBar.style.preferredSize = size;
    
    return [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:[ASAbsoluteLayoutSpec absoluteLayoutSpecWithChildren:@[self.selectedBar]]
                                                      background:self.collectionNode];
}

- (void)animateLayoutTransition:(id<ASContextTransitioning>)context {
    CGRect initialNameFrame = [context initialFrameForNode:self.selectedBar];
    self.selectedBar.frame = initialNameFrame;
    [UIView animateWithDuration:0.4 animations:^{
        self.selectedBar.frame = [context finalFrameForNode:self.selectedBar];
    } completion:^(BOOL finished) {
        [context completeTransition:finished];
    }];
}

-(void)moveToIndex:(NSUInteger)index animated:(BOOL)animated swipeDirection:(XLPagerTabStripDirection)swipeDirection pagerScroll:(XLPagerScroll)pagerScroll
{
    self.selectedOptionIndex = index;
    
    XLButtonBarViewCell *cell = [self.collectionNode nodeForItemAtIndexPath:[NSIndexPath indexPathForItem:index
                                                                                                inSection:0]];
    
    // Check if cell node is loaded
    if(cell.isNodeLoaded) {
        //CGRect originRect = [self.collectionNode convertRect:CGRectZero fromNode:cell];
        
        [self updateSelectedBarPositionWithAnimation:animated swipeDirection:swipeDirection pagerScroll:pagerScroll];
    } else {
        [cell onDidLoad:^(__kindof ASDisplayNode * _Nonnull node) {
            [self updateSelectedBarPositionWithAnimation:animated swipeDirection:swipeDirection pagerScroll:pagerScroll];
        }];
    }
}

-(void)moveFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex withProgressPercentage:(CGFloat)progressPercentage pagerScroll:(XLPagerScroll)pagerScroll
{
    // First, calculate and set the frame of the 'selectedBar'
    
    self.selectedOptionIndex = (progressPercentage > 0.5 ) ? toIndex : fromIndex;
    
    CGRect fromFrame =[self.collectionNode.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0]].frame;
    NSInteger numberOfItems = [self.collectionNode.dataSource collectionNode:self.collectionNode numberOfItemsInSection:0];
    CGRect toFrame;
    if (toIndex < 0 || toIndex > numberOfItems - 1){
        if (toIndex < 0) {
            UICollectionViewLayoutAttributes * cellAtts = [self.collectionNode.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            toFrame = CGRectOffset(cellAtts.frame, -cellAtts.frame.size.width, 0);
        }
        else{
            UICollectionViewLayoutAttributes * cellAtts = [self.collectionNode.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:(numberOfItems - 1) inSection:0]];
            toFrame = CGRectOffset(cellAtts.frame, cellAtts.frame.size.width, 0);
        }
    }
    else{
        toFrame = [self.collectionNode.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]].frame;
    }
    CGRect targetFrame = fromFrame;
    targetFrame.size.height = self.selectedBar.frame.size.height;
    targetFrame.size.width += (toFrame.size.width - fromFrame.size.width) * progressPercentage;
    targetFrame.origin.x += (toFrame.origin.x - fromFrame.origin.x) * progressPercentage;
    
    self.selectedBar.frame = CGRectMake(targetFrame.origin.x, self.selectedBar.frame.origin.y, targetFrame.size.width, self.selectedBar.frame.size.height);
    
    // Next, calculate and set the contentOffset of the UICollectionView
    // (so it scrolls the selectedBar into the appriopriate place given the self.selectedBarAlignment)
    
    float targetContentOffset = 0;
    // Only bother calculating the contentOffset if there are sufficient tabs that the bar can actually scroll!
    if (self.collectionNode.view.contentSize.width > self.collectionNode.frame.size.width)
    {
        CGFloat toContentOffset = [self contentOffsetForCellWithFrame:toFrame index:toIndex];
        CGFloat fromContentOffset = [self contentOffsetForCellWithFrame:fromFrame index:fromIndex];
        
        targetContentOffset = fromContentOffset + ((toContentOffset - fromContentOffset) * progressPercentage);
    }
    
    // If there is a large difference between the current contentOffset and the contentOffset we're about to set
    // then the change might be visually jarring so animate it.  (This will likely occur if the user manually
    // scrolled the XLButtonBarView and then subsequently scrolled the UIPageViewController)
    // Alternatively if the fromIndex and toIndex are the same then this is the last call to this method in the
    // progression so as a precaution always animate this contentOffest change
    BOOL animated = (ABS(self.collectionNode.view.contentOffset.x - targetContentOffset) > 30) || (fromIndex == toIndex);
    [self.collectionNode.view setContentOffset:CGPointMake(targetContentOffset, 0) animated:animated];
}

-(void)updateSelectedBarPositionWithAnimation:(BOOL)animation swipeDirection:(XLPagerTabStripDirection __unused)swipeDirection pagerScroll:(XLPagerScroll)pagerScroll
{
    CGRect selectedBarFrame = self.selectedBar.frame;
    
    NSIndexPath *selectedCellIndexPath = [NSIndexPath indexPathForItem:self.selectedOptionIndex inSection:0];
    UICollectionViewLayoutAttributes *attributes = [self.collectionNode.collectionViewLayout layoutAttributesForItemAtIndexPath:selectedCellIndexPath];
    CGRect selectedCellFrame = attributes.frame;
    
    //CGRect cellFrameInSuperview = [collectionView convertRect:theAttributes.frame toView:[collectionView superview]];
    
    //CGRect cellFrameInSuperview = [self.collectionNode convertRect:attributes.frame toNode:self.collectionNode.supernode];
    //CGRect frameTest = [self.collectionNode convertRect:attributes.frame toNode:self];
    CGRect frameTest = [self.collectionNode convertRect:attributes.frame toNode:nil];
    
    //selectedCellFrame = frameTest;
    
    [self updateContentOffsetAnimated:animation pagerScroll:pagerScroll toFrame:selectedCellFrame toIndex:selectedCellIndexPath.row];
    
    selectedBarFrame.size.width = selectedCellFrame.size.width;
    selectedBarFrame.origin.x = selectedCellFrame.origin.x;
    //selectedBarFrame.origin.y = selectedCellFrame.size.height - _selectedBarHeight;
    //selectedBarFrame.size.height = _selectedBarHeight;
    
    self.selectedBar.frame = selectedBarFrame;
    
    [self transitionLayoutWithAnimation:animation shouldMeasureAsync:nil measurementCompletion:nil];
    
    return;
    
//    if (animation){
//        [UIView animateWithDuration:0.3 animations:^{
//            self.selectedBar.frame = selectedBarFrame;
//        }];
//    }
//    else{
//        self.selectedBar.frame = selectedBarFrame;
//    }
}



#pragma mark - Helpers

- (void)updateContentOffsetAnimated:(BOOL)animated pagerScroll:(XLPagerScroll)pageScroller toFrame:(CGRect)selectedCellFrame toIndex:(NSUInteger)toIndex
{
    if (pageScroller != XLPagerScrollNO)
    {
        if (pageScroller == XLPagerScrollOnlyIfOutOfScreen)
        {
            if  ((selectedCellFrame.origin.x  >= self.collectionNode.view.contentOffset.x)
                 && (selectedCellFrame.origin.x < (self.collectionNode.view.contentOffset.x + self.collectionNode.frame.size.width - self.collectionNode.view.contentInset.left))){
                return;
            }
        }
        
        CGFloat targetContentOffset = 0;
        // Only bother calculating the contentOffset if there are sufficient tabs that the bar can actually scroll!
        if (self.collectionNode.view.contentSize.width > self.collectionNode.frame.size.width)
        {
            targetContentOffset = [self contentOffsetForCellWithFrame:selectedCellFrame index:toIndex];
        }
        
        [self.collectionNode.view setContentOffset:CGPointMake(targetContentOffset, 0) animated:animated];
    }
}

- (CGFloat)contentOffsetForCellWithFrame:(CGRect)cellFrame index:(NSUInteger)index
{
    UIEdgeInsets sectionInset = ((UICollectionViewFlowLayout *)self.collectionNode.collectionViewLayout).sectionInset;
    
    CGFloat alignmentOffset = 0;
    
    switch (self.selectedBarAlignment)
    {
        case XLSelectedBarAlignmentLeft:
        {
            alignmentOffset = sectionInset.left;
            break;
        }
        case XLSelectedBarAlignmentRight:
        {
            alignmentOffset = self.collectionNode.frame.size.width - sectionInset.right - cellFrame.size.width;
            break;
        }
        case XLSelectedBarAlignmentCenter:
        {
            alignmentOffset = (self.collectionNode.frame.size.width - cellFrame.size.width) * 0.5;
            break;
        }
        case XLSelectedBarAlignmentProgressive:
        {
            CGFloat cellHalfWidth = cellFrame.size.width * 0.5;
            CGFloat leftAlignmentOffest = sectionInset.left + cellHalfWidth;
            CGFloat rightAlignmentOffset = self.collectionNode.frame.size.width - sectionInset.right - cellHalfWidth;
            NSInteger numberOfItems = [self.collectionNode.dataSource collectionNode:self.collectionNode numberOfItemsInSection:0];
            CGFloat progress = index / (CGFloat)(numberOfItems - 1);
            alignmentOffset = leftAlignmentOffest + ((rightAlignmentOffset - leftAlignmentOffest) * progress) - cellHalfWidth;
            break;
        }
    }
    
    CGFloat contentOffset = cellFrame.origin.x - alignmentOffset;
    
    // Ensure that the contentOffset wouldn't scroll the UICollectioView passed the beginning
    contentOffset = MAX(0, contentOffset);
    // Ensure that the contentOffset wouldn't scroll the UICollectioView passed the end
    contentOffset = MIN(self.collectionNode.view.contentSize.width - self.collectionNode.frame.size.width, contentOffset);
    
    return contentOffset;
}

#pragma mark - Properties

- (void)setSelectedBarHeight:(CGFloat)selectedBarHeight
{
    _selectedBarHeight = selectedBarHeight;
    _selectedBar.frame = CGRectMake(_selectedBar.frame.origin.x, self.frame.size.height - _selectedBarHeight, _selectedBar.frame.size.width, _selectedBarHeight);
}

//- (ASDisplayNode *)selectedBar
//{
//    if (!_selectedBar) {
//        //_selectedBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - _selectedBarHeight, 0, _selectedBarHeight)];
//        _selectedBar = [[ASDisplayNode alloc] init];
//        _selectedBar.layer.zPosition = 9999;
//        _selectedBar.backgroundColor = [UIColor blackColor];
//    }
//    return _selectedBar;
//}

@end
