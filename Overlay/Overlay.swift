//
//  Overlay.swift
//  Overlay
//
//  Created by Blain Ellis on 29/04/2021.
//

import UIKit

struct Constants {
    static let overlayFadeAnimationDuration: TimeInterval = 0.3
    static let coachMarkFadeAnimationDuration: TimeInterval = 0.3
}

struct InstructionsColor {
    static let overlay: UIColor = {
        let defaultColor = #colorLiteral(red: 0.02740859985, green: 0, blue: 0.08537127585, alpha: 1)

        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                if traits.userInterfaceStyle == .dark {
                    return #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 0.75)
                } else {
                    return defaultColor
                }
            }
        } else {
            return defaultColor
        }
    }()
}
