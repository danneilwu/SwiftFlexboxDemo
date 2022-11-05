

import UIKit

public final class Flex {
    
    public private(set) weak var item: FlexItem?
    public private(set) weak var view: UIView?
    private let yoga: FlexYoga
    
    public var intrinsicSize: CGSize {
        return yoga.intrinsicSize
    }
    
    init(item: FlexItem) {
        self.item = item
        self.yoga = item.yoga
        
        yoga.isEnabled = true
    }
    
    init(view: UIView) {
        self.view = view
        self.yoga = view.item.yoga
        
        yoga.isEnabled = true
    }
    
    @discardableResult
    public func addItem() -> Flex {
        let item = FlexItem()
        return addItem(item)
    }
    
    public func addView() -> Flex {
        let view = UIView()
        return addView(view)
    }
    
    @discardableResult
    public func addItem(_ item: FlexItem ) -> Flex {
        if let host = self.item {
            host.addSubitem(item)
            return item.flex
        } else {
            preconditionFailure("Trying to modify deallocated host item")
        }
    }
    
    @discardableResult
    public func addView(_ view: UIView) -> Flex {
        if let host = self.view {
            host.addSubview(view)
            return view.flex
        } else {
            preconditionFailure("Trying to modify deallocated host view")
        }
    }
    
    @discardableResult
    public func define(_ closure: (_ flex: Flex) -> Void) -> Flex {
        closure(self)
        return self
    }
    
    public func layout(mode: LayoutMode = .fitContainer) {
        if case .fitContainer = mode {
            yoga.applyLayout(preservingOrigin: true)
        } else {
            yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: mode == .adjustWidth ? YGDimensionFlexibility.flexibleWidth : YGDimensionFlexibility.flexibleHeight)
        }
    }
    
    public var isIncludedInLayout: Bool {
        get {
            return yoga.isIncludedInLayout
        }
        set {
            yoga.isIncludedInLayout = newValue
        }
    }
    
    @discardableResult
    public func isIncludedInLayout(_ included: Bool) -> Flex {
        self.isIncludedInLayout = included
        return self
    }
    
    @discardableResult
    public func markDirty() -> Flex {
        yoga.markDirty()
        return self
    }
    
    public func sizeThatFits(size: CGSize) -> CGSize {
        return yoga.calculateLayout(with: size)
    }
    
    // MARK: Direction, wrap, flow
    
    @discardableResult
    public func direction(_ value: Direction) -> Flex {
        yoga.flexDirection = value.yogaValue
        return self
    }
    
    @discardableResult
    public func wrap(_ value: Wrap) -> Flex {
        yoga.flexWrap = value.yogaValue
        return self
    }
    
    @discardableResult
    public func layoutDirection(_ value: LayoutDirection) -> Flex {
        yoga.direction = value.yogaValue
        return self
    }
    
    // MARK: justity, alignment, position
    
    @discardableResult
    public func justifyContent(_ value: JustifyContent) -> Flex {
        yoga.justifyContent = value.yogaValue
        return self
    }
    
    @discardableResult
    public func alignItems(_ value: AlignItems) -> Flex {
        yoga.alignItems = value.yogaValue
        return self
    }
    
    
    @discardableResult
    public func alignSelf(_ value: AlignSelf) -> Flex {
        yoga.alignSelf = value.yogaValue
        return self
    }
    
    @discardableResult
    public func alignContent(_ value: AlignContent) -> Flex {
        yoga.alignContent = value.yogaValue
        return self
    }
    
    // MARK: grow / shrink / basis
    
    @discardableResult
    public func grow(_ value: CGFloat) -> Flex {
        yoga.flexGrow = value
        return self
    }
    
    @discardableResult
    public func shrink(_ value: CGFloat) -> Flex {
        yoga.flexShrink = value
        return self
    }
    
    @discardableResult
    public func basis(_ value: CGFloat?) -> Flex {
        yoga.flexBasis = valueOrAuto(value)
        return self
    }
    
    @discardableResult
    public func basis(_ percent: FPercent) -> Flex {
        yoga.flexBasis = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    // MARK: Width / height / height
    
    @discardableResult
    public func width(_ value: CGFloat?) -> Flex {
        yoga.width = valueOrAuto(value)
        return self
    }
    
    @discardableResult
    public func width(_ percent: FPercent) -> Flex {
        yoga.width = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func height(_ value: CGFloat?) -> Flex {
        yoga.height = valueOrAuto(value)
        return self
    }
    
    @discardableResult
    public func height(_ percent: FPercent) -> Flex {
        yoga.height = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func size(_ size: CGSize?) -> Flex {
        yoga.width = valueOrAuto(size?.width)
        yoga.height = valueOrAuto(size?.height)
        return self
    }
    
    @discardableResult
    public func size(_ sideLength: CGFloat) -> Flex {
        yoga.width = YGValue(sideLength)
        yoga.height = YGValue(sideLength)
        return self
    }
    
    @discardableResult
    public func minWidth(_ value: CGFloat?) -> Flex {
        yoga.minWidth = valueOrUndefined(value)
        return self
    }
    
    @discardableResult
    public func minWidth(_ percent: FPercent) -> Flex {
        yoga.minWidth = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    
    @discardableResult
    public func maxWidth(_ value: CGFloat?) -> Flex {
        yoga.maxWidth = valueOrUndefined(value)
        return self
    }
    
    @discardableResult
    public func maxWidth(_ percent: FPercent) -> Flex {
        yoga.maxWidth = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func minHeight(_ value: CGFloat?) -> Flex {
        yoga.minHeight = valueOrUndefined(value)
        return self
    }
    
    @discardableResult
    public func minHeight(_ percent: FPercent) -> Flex {
        yoga.minHeight = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func maxHeight(_ value: CGFloat?) -> Flex {
        yoga.maxHeight = valueOrUndefined(value)
        
        return self
    }
    
    @discardableResult
    public func maxHeight(_ percent: FPercent) -> Flex {
        yoga.maxHeight = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func aspectRatio(_ value: CGFloat?) -> Flex {
        yoga.aspectRatio = value != nil ? value! : Double(YGValueUndefined.value)
        return self
    }
    
    @discardableResult
    public func aspectRatio(of imageView: UIImageView) -> Flex {
        if let imageSize = imageView.image?.size {
            yoga.aspectRatio = imageSize.width / imageSize.height
        }
        return self
    }
    
    // MARK: Absolute positionning
    
    @discardableResult
    public func position(_ value: Position) -> Flex {
        yoga.position = value.yogaValue
        return self
    }
    
    @discardableResult
    public func left(_ value: CGFloat) -> Flex {
        yoga.left = YGValue(value)
        return self
    }
    
    @discardableResult
    public func left(_ percent: FPercent) -> Flex {
        yoga.left = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func top(_ value: CGFloat) -> Flex {
        yoga.top = YGValue(value)
        return self
    }
    
    @discardableResult
    public func top(_ percent: FPercent) -> Flex {
        yoga.top = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func right(_ value: CGFloat) -> Flex {
        yoga.right = YGValue(value)
        return self
    }
    
    @discardableResult
    public func right(_ percent: FPercent) -> Flex {
        yoga.right = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func bottom(_ value: CGFloat) -> Flex {
        yoga.bottom = YGValue(value)
        return self
    }
    
    @discardableResult
    public func bottom(_ percent: FPercent) -> Flex {
        yoga.bottom = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func start(_ value: CGFloat) -> Flex {
        yoga.start = YGValue(value)
        return self
    }
    
    @discardableResult
    public func start(_ percent: FPercent) -> Flex {
        yoga.start = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func end(_ value: CGFloat) -> Flex {
        yoga.end = YGValue(value)
        return self
    }
    
    @discardableResult
    public func end(_ percent: FPercent) -> Flex {
        yoga.end = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func horizontally(_ value: CGFloat) -> Flex {
        yoga.left = YGValue(value)
        yoga.right = YGValue(value)
        return self
    }
    
    @discardableResult
    public func horizontally(_ percent: FPercent) -> Flex {
        yoga.left = YGValue(value: Double(percent.value), unit: .percent)
        yoga.right = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func vertically(_ value: CGFloat) -> Flex {
        yoga.top = YGValue(value)
        yoga.bottom = YGValue(value)
        return self
    }
    
    @discardableResult
    public func vertically(_ percent: FPercent) -> Flex {
        yoga.top = YGValue(value: Double(percent.value), unit: .percent)
        yoga.bottom = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func all(_ value: CGFloat) -> Flex {
        yoga.top = YGValue(value)
        yoga.left = YGValue(value)
        yoga.bottom = YGValue(value)
        yoga.right = YGValue(value)
        return self
    }
    
    @discardableResult
    public func all(_ percent: FPercent) -> Flex {
        yoga.top = YGValue(value: Double(percent.value), unit: .percent)
        yoga.left = YGValue(value: Double(percent.value), unit: .percent)
        yoga.bottom = YGValue(value: Double(percent.value), unit: .percent)
        yoga.right = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    // MARK: Margins
    
    @discardableResult
    public func marginTop(_ value: CGFloat) -> Flex {
        yoga.marginTop = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginTop(_ percent: FPercent) -> Flex {
        yoga.marginTop = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func marginLeft(_ value: CGFloat) -> Flex {
        yoga.marginLeft = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginLeft(_ percent: FPercent) -> Flex {
        yoga.marginLeft = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func marginBottom(_ value: CGFloat) -> Flex {
        yoga.marginBottom = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginBottom(_ percent: FPercent) -> Flex {
        yoga.marginBottom = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func marginRight(_ value: CGFloat) -> Flex {
        yoga.marginRight = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginRight(_ percent: FPercent) -> Flex {
        yoga.marginRight = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func marginStart(_ value: CGFloat) -> Flex {
        yoga.marginStart = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginStart(_ percent: FPercent) -> Flex {
        yoga.marginStart = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func marginEnd(_ value: CGFloat) -> Flex {
        yoga.marginEnd = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginEnd(_ percent: FPercent) -> Flex {
        yoga.marginEnd = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func marginHorizontal(_ value: CGFloat) -> Flex {
        yoga.marginHorizontal = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginHorizontal(_ percent: FPercent) -> Flex {
        yoga.marginHorizontal = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func marginVertical(_ value: CGFloat) -> Flex {
        yoga.marginVertical = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginVertical(_ percent: FPercent) -> Flex {
        yoga.marginVertical = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func margin(_ insets: UIEdgeInsets) -> Flex {
        yoga.marginTop = YGValue(insets.top)
        yoga.marginLeft = YGValue(insets.left)
        yoga.marginBottom = YGValue(insets.bottom)
        yoga.marginRight = YGValue(insets.right)
        return self
    }
    
    @available(tvOS 11.0, iOS 11.0, *)
    @discardableResult
    func margin(_ directionalInsets: NSDirectionalEdgeInsets) -> Flex {
        yoga.marginTop = YGValue(directionalInsets.top)
        yoga.marginStart = YGValue(directionalInsets.leading)
        yoga.marginBottom = YGValue(directionalInsets.bottom)
        yoga.marginEnd = YGValue(directionalInsets.trailing)
        return self
    }
    
    @discardableResult
    public func margin(_ value: CGFloat) -> Flex {
        yoga.margin = YGValue(value)
        return self
    }
    
    @discardableResult
    public func margin(_ percent: FPercent) -> Flex {
        yoga.margin = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult func margin(_ vertical: CGFloat, _ horizontal: CGFloat) -> Flex {
        yoga.marginVertical = YGValue(vertical)
        yoga.marginHorizontal = YGValue(horizontal)
        return self
    }
    
    @discardableResult func margin(_ vertical: FPercent, _ horizontal: FPercent) -> Flex {
        yoga.marginVertical = YGValue(value: Double(vertical.value), unit: .percent)
        yoga.marginHorizontal = YGValue(value: Double(horizontal.value), unit: .percent)
        return self
    }
    
    @discardableResult func margin(_ top: CGFloat, _ horizontal: CGFloat, _ bottom: CGFloat) -> Flex {
        yoga.marginTop = YGValue(top)
        yoga.marginHorizontal = YGValue(horizontal)
        yoga.marginBottom = YGValue(bottom)
        return self
    }
    
    @discardableResult func margin(_ top: FPercent, _ horizontal: FPercent, _ bottom: FPercent) -> Flex {
        yoga.marginTop = YGValue(value: Double(top.value), unit: .percent)
        yoga.marginHorizontal = YGValue(value: Double(horizontal.value), unit: .percent)
        yoga.marginBottom = YGValue(value: Double(bottom.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func margin(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> Flex {
        yoga.marginTop = YGValue(top)
        yoga.marginLeft = YGValue(left)
        yoga.marginBottom = YGValue(bottom)
        yoga.marginRight = YGValue(right)
        return self
    }
    
    @discardableResult
    public func margin(_ top: FPercent, _ left: FPercent, _ bottom: FPercent, _ right: FPercent) -> Flex {
        yoga.marginTop = YGValue(value: Double(top.value), unit: .percent)
        yoga.marginLeft = YGValue(value: Double(left.value), unit: .percent)
        yoga.marginBottom = YGValue(value: Double(bottom.value), unit: .percent)
        yoga.marginRight = YGValue(value: Double(right.value), unit: .percent)
        return self
    }
    
    // MARK: Padding
    
    @discardableResult
    public func paddingTop(_ value: CGFloat) -> Flex {
        yoga.paddingTop = YGValue(value)
        return self
    }
    
    @discardableResult
    public func paddingTop(_ percent: FPercent) -> Flex {
        yoga.paddingTop = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func paddingLeft(_ value: CGFloat) -> Flex {
        yoga.paddingLeft = YGValue(value)
        return self
    }
    
    @discardableResult
    public func paddingLeft(_ percent: FPercent) -> Flex {
        yoga.paddingLeft = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func paddingBottom(_ value: CGFloat) -> Flex {
        yoga.paddingBottom = YGValue(value)
        return self
    }
    
    @discardableResult
    public func paddingBottom(_ percent: FPercent) -> Flex {
        yoga.paddingBottom = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func paddingRight(_ value: CGFloat) -> Flex {
        yoga.paddingRight = YGValue(value)
        return self
    }
    
    @discardableResult
    public func paddingRight(_ percent: FPercent) -> Flex {
        yoga.paddingRight = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func paddingStart(_ value: CGFloat) -> Flex {
        yoga.paddingStart = YGValue(value)
        return self
    }
    
    @discardableResult
    public func paddingStart(_ percent: FPercent) -> Flex {
        yoga.paddingStart = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func paddingEnd(_ value: CGFloat) -> Flex {
        yoga.paddingEnd = YGValue(value)
        return self
    }
    
    @discardableResult
    public func paddingEnd(_ percent: FPercent) -> Flex {
        yoga.paddingEnd = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func paddingHorizontal(_ value: CGFloat) -> Flex {
        yoga.paddingHorizontal = YGValue(value)
        return self
    }
    
    @discardableResult
    public func paddingHorizontal(_ percent: FPercent) -> Flex {
        yoga.paddingHorizontal = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func paddingVertical(_ value: CGFloat) -> Flex {
        yoga.paddingVertical = YGValue(value)
        return self
    }
    
    @discardableResult
    public func paddingVertical(_ percent: FPercent) -> Flex {
        yoga.paddingVertical = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func padding(_ insets: UIEdgeInsets) -> Flex {
        yoga.paddingTop = YGValue(insets.top)
        yoga.paddingLeft = YGValue(insets.left)
        yoga.paddingBottom = YGValue(insets.bottom)
        yoga.paddingRight = YGValue(insets.right)
        return self
    }
    
    @available(tvOS 11.0, iOS 11.0, *)
    @discardableResult
    func padding(_ directionalInsets: NSDirectionalEdgeInsets) -> Flex {
        yoga.paddingTop = YGValue(directionalInsets.top)
        yoga.paddingStart = YGValue(directionalInsets.leading)
        yoga.paddingBottom = YGValue(directionalInsets.bottom)
        yoga.paddingEnd = YGValue(directionalInsets.trailing)
        return self
    }
    
    @discardableResult
    public func padding(_ value: CGFloat) -> Flex {
        yoga.padding = YGValue(value)
        return self
    }
    
    @discardableResult
    public func padding(_ percent: FPercent) -> Flex {
        yoga.padding = YGValue(value: Double(percent.value), unit: .percent)
        return self
    }
    
    @discardableResult func padding(_ vertical: CGFloat, _ horizontal: CGFloat) -> Flex {
        yoga.paddingVertical = YGValue(vertical)
        yoga.paddingHorizontal = YGValue(horizontal)
        return self
    }
    
    @discardableResult
    public func padding(_ vertical: FPercent, _ horizontal: FPercent) -> Flex {
        yoga.paddingVertical = YGValue(value: Double(vertical.value), unit: .percent)
        yoga.paddingHorizontal = YGValue(value: Double(horizontal.value), unit: .percent)
        return self
    }
    
    @discardableResult func padding(_ top: CGFloat, _ horizontal: CGFloat, _ bottom: CGFloat) -> Flex {
        yoga.paddingTop = YGValue(top)
        yoga.paddingHorizontal = YGValue(horizontal)
        yoga.paddingBottom = YGValue(bottom)
        return self
    }
    
    @discardableResult func padding(_ top: FPercent, _ horizontal: FPercent, _ bottom: FPercent) -> Flex {
        yoga.paddingTop = YGValue(value: Double(top.value), unit: .percent)
        yoga.paddingHorizontal = YGValue(value: Double(horizontal.value), unit: .percent)
        yoga.paddingBottom = YGValue(value: Double(bottom.value), unit: .percent)
        return self
    }
    
    @discardableResult
    public func padding(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> Flex {
        yoga.paddingTop = YGValue(top)
        yoga.paddingLeft = YGValue(left)
        yoga.paddingBottom = YGValue(bottom)
        yoga.paddingRight = YGValue(right)
        return self
    }
    
    @discardableResult
    public func padding(_ top: FPercent, _ left: FPercent, _ bottom: FPercent, _ right: FPercent) -> Flex {
        yoga.paddingTop = YGValue(value: Double(top.value), unit: .percent)
        yoga.paddingLeft = YGValue(value: Double(left.value), unit: .percent)
        yoga.paddingBottom = YGValue(value: Double(bottom.value), unit: .percent)
        yoga.paddingRight = YGValue(value: Double(right.value), unit: .percent)
        return self
    }
    
    // MARK: Display
    
    @discardableResult
    public func display(_ value: Display) -> Flex {
        yoga.display = value.yogaValue
        return self
    }
    
    // MARK: Enums
    
    public enum Direction {
        case column
        case columnReverse
        case row
        case rowReverse
    }
    
    public enum JustifyContent {
        case start
        case center
        case end
        case spaceBetween
        case spaceAround
        case spaceEvenly
    }
    
    public enum AlignContent {
        case stretch
        case start
        case center
        case end
        case spaceBetween
        case spaceAround
    }
    
    public enum AlignItems {
        case stretch
        case start
        case center
        case end
        case baseline
    }
    
    public enum AlignSelf {
        case auto
        case stretch
        case start
        case center
        case end
        case baseline
    }
    
    public enum Wrap {
        case noWrap
        case wrap
        case wrapReverse
    }
    
    public enum Position {
        case relative
        case absolute
    }
    
    public enum LayoutDirection {
        case inherit
        case ltr
        case rtl
    }
    
    public enum LayoutMode {
        case fitContainer
        case adjustHeight
        case adjustWidth
    }
    
    public enum Display {
        case flex
        case none
    }
    
    func valueOrUndefined(_ value: CGFloat?) -> YGValue {
        if let value = value {
            return YGValue(value)
        } else {
            return YGValueUndefined
        }
    }
    
    func valueOrAuto(_ value: CGFloat?) -> YGValue {
        if let value = value {
            return YGValue(value)
        } else {
            return YGValueAuto
        }
    }
}

