//
//  XLButtonBarViewCell.m
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

@interface XLButtonBarViewCell()

@property ASImageNode * imageView;
@property ASTextNode * label;

@end

@implementation XLButtonBarViewCell

- (instancetype)init {
    self = [super init];
    if(self) {
        // Auto add subnodes
        self.automaticallyManagesSubnodes = YES;
        
        _label = [[ASTextNode alloc] init];
        _label.maximumNumberOfLines = 1;
        
        _imageView = [[ASImageNode alloc] init];
    }
    return self;
}

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize {
//    if(_imageView.image) {
//    // Label with image
//    ASStackLayoutSpec *stackContent = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
//                                                                              spacing:0.0f
//                                                                       justifyContent:ASStackLayoutJustifyContentStart
//                                                                           alignItems:ASStackLayoutAlignItemsStretch
//                                                                             children:@[,
//                                                                                        ]];
//    }
    
//    // Main
//    ASRatioLayoutSpec *ratioProfile = [ASRatioLayoutSpec ratioLayoutSpecWithRatio:1.0f
//                                                                            child:self.profileImageNode];
//    ratioProfile.style.width = ASDimensionMakeWithPoints(54.0f);
//    
//    stackContent.style.flexShrink = 1.0f;
//    
//    ASStackLayoutSpec *stackMain = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
//                                                                           spacing:12.0f
//                                                                    justifyContent:ASStackLayoutJustifyContentStart
//                                                                        alignItems:ASStackLayoutAlignItemsStretch
//                                                                          children:@[ratioProfile,
//                                                                                     stackContent]];
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(10.0f, 12.0f, 12.0f, 12.0f)
                                                  child:_label];
}

@end
