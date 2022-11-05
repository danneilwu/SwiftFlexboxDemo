//
//  BDFlexYoga.mm
//  MessagingKit
//
//  Created by 孙旭让 on 2022/8/30.
//

#import "BDFlexYoga.h"
#import "BDFlexYogaMacros.h"
#import "BDFlexItem.h"

static YGConfigRef globalConfig;

YGValue YGPointValue(CGFloat value) {
    return (YGValue) { .value = (float) value, .unit = (YGUnit) YGUnitPoint };
}
YGValue YGPercentValue(CGFloat value) {
    return (YGValue) { .value = (float) value, .unit = YGUnitPercent };
}

@interface BDFlexYoga ()

@property (nonatomic, weak) BDFlexItem *item;
@property (nonatomic, assign) YGNodeRef node;

@end

@implementation BDFlexYoga

#pragma mark - Life Cycle

- (void)dealloc {
    YGNodeFree(self.node);
}

+ (void)initialize {
    globalConfig = YGConfigNew();
    YGConfigSetExperimentalFeatureEnabled(globalConfig, YGExperimentalFeatureWebFlexBasis, true);
    YGConfigSetPointScaleFactor(globalConfig, [UIScreen mainScreen].scale);
}

- (instancetype)initWithItem:(BDFlexItem *)item {
    self = [super init];
    if (self) {
        self.item = item;
        
        _isEnabled = NO;
        _isIncludedInLayout = YES;
        
        _node = YGNodeNewWithConfig(globalConfig);
        YGNodeSetContext(_node, (__bridge void *) item);
    }
    return self;
}

#pragma mark - Dirty

- (BOOL)isDirty {
    return YGNodeIsDirty(self.node);
}

- (void)markDirty {
    if (self.isDirty || !self.isLeaf) {
        return;
    }
    
    const YGNodeRef node = self.node;
    YGNodeSetMeasureFunc(node, YGMeasureItem);
//    if (YGNodeGetMeasureFunc(node) == NULL) {
//        YGNodeSetMeasureFunc(node, YGMeasureItem);
//    }
    
    YGNodeMarkDirty(node);
}

#pragma mark - Style

- (YGPositionType)position {
    return YGNodeStyleGetPositionType(self.node);
}

- (void)setPosition:(YGPositionType)position {
    YGNodeStyleSetPositionType(self.node, position);
}

#pragma mark - Layout and Sizing

- (YGDirection)resolvedDirection {
    return YGNodeLayoutGetDirection(self.node);
}

- (CGSize)intrinsicSize {
    const CGSize constrainedSize = {
        .width = YGUndefined,
        .height = YGUndefined,
    };
    return [self calculateLayoutWithSize:constrainedSize];
}

- (NSUInteger)numberOfChildren {
    return YGNodeGetChildCount(self.node);
}

- (BOOL)isLeaf {
    if (!self.item.enableAsync) {
        NSAssert([NSThread isMainThread], @"This method must be called on the main thread.");
    }
    
    if (self.isEnabled) {
        for (BDFlexItem *subitem in self.item.subitems) {
            BDFlexYoga *const yoga = subitem.yoga;
            if (yoga.isEnabled && yoga.isIncludedInLayout) {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - Apply Layout

- (void)applyLayout {
    [self calculateLayoutWithSize:self.item.bounds.size];
    YGApplyLayoutToItemHierarchy(self.item, NO);
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin {
    [self calculateLayoutWithSize:self.item.bounds.size];
    YGApplyLayoutToItemHierarchy(self.item, preserveOrigin);
}

- (void)applyLayoutPreservingOrigin:(BOOL)preserveOrigin dimensionFlexibility:(YGDimensionFlexibility)dimensionFlexibility {
    CGSize size = self.item.bounds.size;
    
    if (dimensionFlexibility & YGDimensionFlexibilityFlexibleWidth) {
        size.width = YGUndefined;
    }
    if (dimensionFlexibility & YGDimensionFlexibilityFlexibleHeight) {
        size.height = YGUndefined;
    }
    
    [self calculateLayoutWithSize:size];
    
    YGApplyLayoutToItemHierarchy(self.item, preserveOrigin);
}

- (CGSize)calculateLayoutWithSize:(CGSize)size {
    if (!self.item.enableAsync) {
        NSAssert([NSThread isMainThread], @"This method must be called on the main thread.");
    }
    NSAssert(self.isEnabled, @"Yoga is not enabled for this Item.");
    
    YGAttachNodesFromItemHierachy(self.item);
    
    const YGNodeRef node = self.node;
    YGNodeCalculateLayout(node, size.width, size.height, YGNodeStyleGetDirection(node));
    
    return (CGSize) {
        .width = YGNodeLayoutGetWidth(node),
        .height = YGNodeLayoutGetHeight(node),
    };
}

#pragma mark - Private

static void YGAttachNodesFromItemHierachy(BDFlexItem *const item) {
    BDFlexYoga *const yoga = item.yoga;
    const YGNodeRef node = yoga.node;
    
    // Only leaf nodes should have a measure function
    if (yoga.isLeaf) {
        YGRemoveAllChildren(node);
        YGNodeSetMeasureFunc(node, YGMeasureItem);
    } else {
        YGNodeSetMeasureFunc(node, NULL);
        
        NSMutableArray<BDFlexItem *> *subitemsToInclude = [[NSMutableArray alloc] initWithCapacity:item.subitems.count];
        
        for (BDFlexItem *subitem in item.subitems) {
            if (subitem.yoga.isIncludedInLayout) {
                [subitemsToInclude addObject:subitem];
            }
        }
        
        if (!YGNodeHasExactSameChildren(node, subitemsToInclude)) {
            YGRemoveAllChildren(node);
            for (int i=0; i<subitemsToInclude.count; i++) {
                YGNodeRef child = subitemsToInclude[i].yoga.node;
                YGNodeRef parent = YGNodeGetParent(child);
                if (parent != NULL) {
                    YGNodeRemoveChild(parent, child);
                }
                YGNodeInsertChild(node, child, i);
            }
        }
        
        for (BDFlexItem *const subitem in subitemsToInclude) {
            YGAttachNodesFromItemHierachy(subitem);
        }
    }
}

static void YGRemoveAllChildren(const YGNodeRef node) {
    if (node == NULL) {
        return;
    }
    
    while (YGNodeGetChildCount(node) > 0) {
        YGNodeRemoveChild(node, YGNodeGetChild(node, YGNodeGetChildCount(node) - 1));
    }
}

static void YGApplyLayoutToItemHierarchy(BDFlexItem *item , BOOL preserveOrigin) {
    const BDFlexYoga *yoga = item.yoga;
    
    if (!yoga.isIncludedInLayout) {
        return;
    }
    
    YGNodeRef node = yoga.node;
    const CGPoint topLeft = {
        YGNodeLayoutGetLeft(node),
        YGNodeLayoutGetTop(node),
    };
    
    const CGPoint bottomRight = {
        topLeft.x + YGNodeLayoutGetWidth(node),
        topLeft.y + YGNodeLayoutGetHeight(node),
    };
    
    const CGPoint origin = preserveOrigin ? item.frame.origin : CGPointZero;
    item.frame = (CGRect) {
        .origin = {
            .x = YGRoundPixelValue(topLeft.x + origin.x),
            .y = YGRoundPixelValue(topLeft.y + origin.y),
        },
            .size = {
                .width = YGRoundPixelValue(bottomRight.x) - YGRoundPixelValue(topLeft.x),
                .height = YGRoundPixelValue(bottomRight.y) - YGRoundPixelValue(topLeft.y),
            },
    };
    
    if (!yoga.isLeaf) {
        for (NSUInteger i = 0; i < item.subitems.count; i++) {
            YGApplyLayoutToItemHierarchy(item.subitems[i], NO);
        }
    }
}

static CGFloat YGRoundPixelValue(CGFloat value) {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(){
        scale = [UIScreen mainScreen].scale;
    });
    
    return roundf(value * scale) / scale;
}

static YGSize YGMeasureItem(YGNodeRef node, float width, YGMeasureMode widthMode, float height, YGMeasureMode heightMode) {
    const CGFloat constrainedWidth = (widthMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : width;
    const CGFloat constrainedHeight = (heightMode == YGMeasureModeUndefined) ? CGFLOAT_MAX: height;
    
    BDFlexItem *item = (__bridge BDFlexItem*) YGNodeGetContext(node);
    const CGSize sizeThatFits = [item sizeThatFits:(CGSize) {
        .width = constrainedWidth,
        .height = constrainedHeight,
    }];
    
    return (YGSize) {
        .width = (float) YGSanitizeMeasurement(constrainedWidth, sizeThatFits.width, widthMode),
        .height = (float) YGSanitizeMeasurement(constrainedHeight, sizeThatFits.height, heightMode),
    };
}

static CGFloat YGSanitizeMeasurement(CGFloat constrainedSize, CGFloat measuredSize, YGMeasureMode measureMode) {
    CGFloat result;
    if (measureMode == YGMeasureModeExactly) {
        result = constrainedSize;
    } else if (measureMode == YGMeasureModeAtMost) {
        result = MIN(constrainedSize, measuredSize);
    } else {
        result = measuredSize;
    }
    
    return result;
}

static BOOL YGNodeHasExactSameChildren(const YGNodeRef node, NSArray<BDFlexItem *> *subitems) {
    if (YGNodeGetChildCount(node) != subitems.count) {
        return NO;
    }
    
    for (int i=0; i<subitems.count; i++) {
        if (YGNodeGetChild(node, i) != subitems[i].yoga.node) {
            return NO;
        }
    }
    
    return YES;
}

YG_ADAPT_PROPERTY(YGDirection, direction, Direction)
YG_ADAPT_PROPERTY(YGFlexDirection, flexDirection, FlexDirection)
YG_ADAPT_PROPERTY(YGJustify, justifyContent, JustifyContent)
YG_ADAPT_PROPERTY(YGAlign, alignContent, AlignContent)
YG_ADAPT_PROPERTY(YGAlign, alignItems, AlignItems)
YG_ADAPT_PROPERTY(YGAlign, alignSelf, AlignSelf)
YG_ADAPT_PROPERTY(YGWrap, flexWrap, FlexWrap)
YG_ADAPT_PROPERTY(YGOverflow, overflow, Overflow)
YG_ADAPT_PROPERTY(YGDisplay, display, Display)

YG_ADAPT_PROPERTY(CGFloat, flexGrow, FlexGrow)
YG_ADAPT_PROPERTY(CGFloat, flexShrink, FlexShrink)
YG_ADAPT_AUTO_VALUE_PROPERTY(flexBasis, FlexBasis)

YG_ADAPT_VALUE_EDGE_PROPERTY(left, Left, Position, YGEdgeLeft)
YG_ADAPT_VALUE_EDGE_PROPERTY(top, Top, Position, YGEdgeTop)
YG_ADAPT_VALUE_EDGE_PROPERTY(right, Right, Position, YGEdgeRight)
YG_ADAPT_VALUE_EDGE_PROPERTY(bottom, Bottom, Position, YGEdgeBottom)
YG_ADAPT_VALUE_EDGE_PROPERTY(start, Start, Position, YGEdgeStart)
YG_ADAPT_VALUE_EDGE_PROPERTY(end, End, Position, YGEdgeEnd)
YG_ADAPT_VALUE_EDGES_PROPERTIES(margin, Margin)
YG_ADAPT_VALUE_EDGES_PROPERTIES(padding, Padding)

YG_ADAPT_EDGE_PROPERTY(borderLeftWidth, BorderLeftWidth, Border, YGEdgeLeft)
YG_ADAPT_EDGE_PROPERTY(borderTopWidth, BorderTopWidth, Border, YGEdgeTop)
YG_ADAPT_EDGE_PROPERTY(borderRightWidth, BorderRightWidth, Border, YGEdgeRight)
YG_ADAPT_EDGE_PROPERTY(borderBottomWidth, BorderBottomWidth, Border, YGEdgeBottom)
YG_ADAPT_EDGE_PROPERTY(borderStartWidth, BorderStartWidth, Border, YGEdgeStart)
YG_ADAPT_EDGE_PROPERTY(borderEndWidth, BorderEndWidth, Border, YGEdgeEnd)
YG_ADAPT_EDGE_PROPERTY(borderWidth, BorderWidth, Border, YGEdgeAll)

YG_ADAPT_AUTO_VALUE_PROPERTY(width, Width)
YG_ADAPT_AUTO_VALUE_PROPERTY(height, Height)
YG_VALUE_PROPERTY(minWidth, MinWidth)
YG_VALUE_PROPERTY(minHeight, MinHeight)
YG_VALUE_PROPERTY(maxWidth, MaxWidth)
YG_VALUE_PROPERTY(maxHeight, MaxHeight)
YG_ADAPT_PROPERTY(CGFloat, aspectRatio, AspectRatio)

@end
