//
//

#import <Foundation/Foundation.h>
#import "Yoga.h"
#import "BDFlexYoga.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(FlexItem)
@interface BDFlexItem : NSObject

@property (nonatomic, assign) BOOL isYogaEnabled;
@property (nonatomic, assign) BOOL enableAsync;

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect bounds;

//@property (nonatomic, strong) BDFlexYoga *yoga;
@property (nonatomic, strong) NSMutableArray *subitems;

- (void)addSubitem:(BDFlexItem *)item;

- (CGSize)sizeThatFits:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
