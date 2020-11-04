import Foundation
import UIKit

@objc(UIColorValueTransformer)
final class ColorValueTransformer: ValueTransformer {

    /// The name of the transformer. This is the name used to register the transformer using `ValueTransformer.setValueTrandformer(_"forName:)`.
    static let name = NSValueTransformerName(rawValue: String(describing: ColorValueTransformer.self))
    
    
    override class func transformedValueClass() -> AnyClass {
        return UIColor.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
            guard let color = value as? UIColor else { return nil }
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true)
                return data
            } catch {
                assertionFailure("Failed to transform `UIColor` to `Data`")
                return nil
            }
        }
        
        override public func reverseTransformedValue(_ value: Any?) -> Any? {
            guard let data = value as? NSData else { return nil }
            
            do {
                let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data as Data)
                return color
            } catch {
                assertionFailure("Failed to transform `Data` to `UIColor`")
                return nil
            }
        }

    /// Registers the transformer.
    public static func register() {
        let transformer = ColorValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
