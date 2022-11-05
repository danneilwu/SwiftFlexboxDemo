

import UIKit

private var flexItemAssociatedFlex = 10_00_00
private var flexLayoutAssociatedItem = 10_00_01

extension FlexItem {
    public var flex: Flex {
        if let flex = objc_getAssociatedObject(self, &flexItemAssociatedFlex) as? Flex {
            return flex
        } else {
            let flex = Flex(item: self)
            objc_setAssociatedObject(self, &flexItemAssociatedFlex, flex, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return flex
        }
    }
    
    public var isFlexEnabled: Bool {
        (objc_getAssociatedObject(self, &flexItemAssociatedFlex) as? Flex) != nil
    }
}


