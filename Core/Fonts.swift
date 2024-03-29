import UIKit

extension UIFont {
    /// Returns a bolded version of `self`.
    public var bolded: UIFont {
        return self.fontDescriptor.withSymbolicTraits(.traitBold)
            .map { UIFont(descriptor: $0, size: 0.0) } ?? self
    }
    
    /// Returns a italicized version of `self`.
    public var italicized: UIFont {
        return self.fontDescriptor.withSymbolicTraits(.traitItalic)
            .map { UIFont(descriptor: $0, size: 0.0) } ?? self
    }
    
    /// Returns a fancy monospaced font for the countdown.
    public var countdownMonospaced: UIFont {
        let monospacedDescriptor = self.fontDescriptor
            .addingAttributes(
                [
                    UIFontDescriptor.AttributeName.featureSettings: [
                        [
                            UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                            UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
                        ],
                        [
                            UIFontDescriptor.FeatureKey.featureIdentifier: kStylisticAlternativesType,
                            UIFontDescriptor.FeatureKey.typeIdentifier: kStylisticAltTwoOnSelector
                        ],
                        [
                            UIFontDescriptor.FeatureKey.featureIdentifier: kStylisticAlternativesType,
                            UIFontDescriptor.FeatureKey.typeIdentifier: kStylisticAltOneOnSelector
                        ]
                    ]
                ]
        )
        
        return UIFont(descriptor: monospacedDescriptor, size: 0.0)
    }
    
    /// regular, 17pt font, 22pt leading, -24pt tracking
    public static func py_body(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .body, size: size)
    }
    
    /// regular, 16pt font, 21pt leading, -20pt tracking
    public static func py_callout(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .callout, size: size)
    }
    
    /// regular, 12pt font, 16pt leading, 0pt tracking
    public static func py_caption1(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .caption1, size: size)
    }
    
    /// regular, 11pt font, 13pt leading, 6pt tracking
    public static func py_caption2(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .caption2, size: size)
    }
    
    /// regular, 13pt font, 18pt leading, -6pt tracking
    public static func py_footnote(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .footnote, size: size)
    }
    
    /// semi-bold, 17pt font, 22pt leading, -24pt tracking
    public static func py_headline(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .headline, size: size)
    }
    
    /// regular, 15pt font, 20pt leading, -16pt tracking
    public static func py_subhead(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .subheadline, size: size)
    }
    
    /// light, 28pt font, 34pt leading, 13pt tracking
    public static func py_title1(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .title1, size: size)
    }
    
    /// regular, 22pt font, 28pt leading, 16pt tracking
    public static func py_title2(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .title2, size: size)
    }
    
    /// regular, 20pt font, 24pt leading, 19pt tracking
    public static func py_title3(size: CGFloat? = nil) -> UIFont {
        return .preferredFont(style: .title3, size: size)
    }
    
    /// Returns a monospaced font for numeric use.
    public var monospaced: UIFont {
        let monospacedDescriptor = self.fontDescriptor
            .addingAttributes(
                [
                    UIFontDescriptor.AttributeName.featureSettings: [
                        [
                            UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                            UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
                        ]
                    ]
                ]
        )
        
        return UIFont(descriptor: monospacedDescriptor, size: 0.0)
    }
    
    public var upperCaseSmallCaps: UIFont {
        let smallCapsDesc = self.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [
                    UIFontDescriptor.FeatureKey.featureIdentifier: kUpperCaseType,
                    UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseSmallCapsSelector
                ]
            ]
        ])
        return UIFont(descriptor: smallCapsDesc, size: 0.0)
    }
    
    public var lowerCaseSmallCaps: UIFont {
        let smallCapsDesc = self.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [
                    UIFontDescriptor.FeatureKey.featureIdentifier: kLowerCaseType,
                    UIFontDescriptor.FeatureKey.typeIdentifier: kLowerCaseSmallCapsSelector
                ]
            ]
        ])
        return UIFont(descriptor: smallCapsDesc, size: 0.0)
    }
    
    public static func preferredFont(style: UIFont.TextStyle, size: CGFloat? = nil) -> UIFont {
        
        let defaultSize: CGFloat
        switch style {
        case UIFont.TextStyle.body:         defaultSize = 17
        case UIFont.TextStyle.callout:      defaultSize = 16
        case UIFont.TextStyle.caption1:     defaultSize = 12
        case UIFont.TextStyle.caption2:     defaultSize = 11
        case UIFont.TextStyle.footnote:     defaultSize = 13
        case UIFont.TextStyle.headline:     defaultSize = 17
        case UIFont.TextStyle.subheadline:  defaultSize = 15
        case UIFont.TextStyle.title1:       defaultSize = 28
        case UIFont.TextStyle.title2:       defaultSize = 22
        case UIFont.TextStyle.title3:       defaultSize = 20
        default:                           defaultSize = 17
        }
        
        let font = UIFont.preferredFont(forTextStyle: style)
        let descriptor = font.fontDescriptor
        
        return UIFont(
            descriptor: descriptor,
            size: ceil(font.pointSize / defaultSize * (size ?? defaultSize))
        )
    }
}


import SwiftUI
extension Font {
    public static let preferred: (UIFont) -> Self = {
        //Font.custom($0.fontName, size: $0.pointSize)
        Font($0)
    }
}
