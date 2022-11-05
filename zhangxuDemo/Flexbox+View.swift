
//

import Foundation

private var viewAssociatedItem = 20_00_00
private var viewAssociatedFlex = 20_00_01

extension UIView {
    public var item: FlexItem {
        if let item = objc_getAssociatedObject(self, &viewAssociatedItem) as? FlexItem {
            return item
        } else {
            let item = ViewItem(view: self) as FlexItem
            objc_setAssociatedObject(self, &viewAssociatedItem, item, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
    }
    
    public var flex: Flex {
        if let flex = objc_getAssociatedObject(self, &viewAssociatedFlex) as? Flex {
            return flex
        } else {
            let flex = Flex(view: self)
            objc_setAssociatedObject(self, &viewAssociatedFlex, flex, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return flex
        }
    }
    
    public var isFlexEnabled: Bool {
        (objc_getAssociatedObject(self, &viewAssociatedFlex) as? Flex) != nil
    }
}

fileprivate class ViewItem: FlexItem {
    
    fileprivate private(set) weak var view: UIView?
    
    fileprivate override var frame: CGRect {
        get { return view?.frame ?? .zero }
        set { view?.frame = newValue}
    }
    
    fileprivate override var bounds: CGRect {
        get { return view?.bounds ?? .zero }
        set { view?.bounds = newValue}
    }
    
    fileprivate override var subitems: NSMutableArray {
        get{
            let items = NSMutableArray()
            guard let subviews = view?.subviews else {
                return items
            }
            for view in subviews {
                items.add(view.item)
            }
            return items
        }
        set{ }
    }
    
    fileprivate override func sizeThatFits(_ size: CGSize) -> CGSize {
        return view?.sizeThatFits(size) ?? .zero
    }
    
    fileprivate init(view: UIView) {
        self.view = view
        super.init()
        self.enableAsync = false
    }
}

