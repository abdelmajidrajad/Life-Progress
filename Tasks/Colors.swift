import UIKit
extension UIColor {
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }
        
    public static let startBlueLightColor = #colorLiteral(red: 0, green: 0.8640504479, blue: 0.9947199225, alpha: 1)
    public static let endBlueLightColor = #colorLiteral(red: 0.1376876533, green: 0.4835700989, blue: 0.9543175101, alpha: 1)
    public static let startVioletColor = #colorLiteral(red: 0.6492916346, green: 0.5663512945, blue: 0.8998132348, alpha: 1)
    public static let endVioletColor =  #colorLiteral(red: 0.5171393156, green: 0.2561190426, blue: 0.998118341, alpha: 1)    //grad)
    public static let startOrangeColor = #colorLiteral(red: 1, green: 0.6498119235, blue: 0, alpha: 1)
    public static let endOrangeColor = #colorLiteral(red: 1, green: 0.4601106644, blue: 0.2887434065, alpha: 1)     //gra)
    public static let startGreenColor = #colorLiteral(red: 0.2549019608, green: 0.7647058824, blue: 0, alpha: 1)
    public static let endGreenColor = #colorLiteral(red: 0, green: 0.5450980392, blue: 0, alpha: 1)
    public static let startRedColor = #colorLiteral(red: 1, green: 0.4868322015, blue: 0.7333707809, alpha: 1)
    public static let endRedColor = #colorLiteral(red: 1, green: 0.2532556951, blue: 0.1206482723, alpha: 1)
    public static let startPinkColor = #colorLiteral(red: 1, green: 0.470400393, blue: 0.8110726476, alpha: 1)
    public static let endPinkColor = #colorLiteral(red: 0.7167868018, green: 0.3949707448, blue: 1, alpha: 1)
    public static let redColor = UIColor(red: 255, green: 54, blue: 54)
    
}

import SwiftUI
let colors: () -> [Color] = {    
    [UIColor.startBlueLightColor,
     .endBlueLightColor,
     .startVioletColor,
     .endVioletColor,
     .startOrangeColor,
     .endOrangeColor,
     .startGreenColor,
     .endGreenColor,
     .startRedColor,
     .endRedColor,
     .startPinkColor,
     .endPinkColor,
     .redColor
    ].map(Color.init)
}
