//
//

#import "BDFlexItem.h"

@implementation BDFlexItem

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isYogaEnabled = YES;
        self.enableAsync = YES;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeZero;
}

- (void)addSubitem:(BDFlexItem *)item {
    [self.subitems addObject:item];
}

- (CGRect)bounds {
    return CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

#pragma mark - Getter

- (BDFlexYoga *)yoga {
    if (_yoga == nil) {
        _yoga = [[BDFlexYoga alloc] initWithItem:self];
    }
    return _yoga;
}

- (NSMutableArray *)subitems {
    if (_subitems == nil) {
        _subitems = [NSMutableArray array];
    }
    return _subitems;
}

@end
