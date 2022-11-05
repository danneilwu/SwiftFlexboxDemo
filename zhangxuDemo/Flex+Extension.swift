

import CoreGraphics

postfix operator %

extension Int {
    public static postfix func % (value: Int) -> YGValue {
        return YGValue(value: Double(value), unit: .percent)
    }
}

extension Float {
    public static postfix func % (value: Float) -> YGValue {
        return YGValue(value: Double(value), unit: .percent)
    }
}

extension CGFloat {
    public static postfix func % (value: CGFloat) -> YGValue {
        return YGValue(value: Double(value), unit: .percent)
    }
}

extension YGValue: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public init(integerLiteral value: Int) {
        self = YGValue(value: Double(value), unit: .point)
    }
    
    public init(floatLiteral value: Float) {
        self = YGValue(value: Double(value), unit: .point)
    }
    
    public init(_ value: Float) {
        self = YGValue(value: Double(value), unit: .point)
    }
    
    public init(_ value: CGFloat) {
        self = YGValue(value: Double(value), unit: .point)
    }
}

