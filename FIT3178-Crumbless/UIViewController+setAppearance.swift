//
//  UIViewController+setAppearance.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 7/6/2023.
//

import Foundation
import UIKit

extension UIViewController {
    // Set UI appearance (light or dark mode)
    func setAppearance() {
        let userDefaults = UserDefaults.standard
        let darkMode = userDefaults.bool(forKey: "darkMode")
        
        // Override application UI style
        let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene
        if darkMode {
            scenes?.windows.first?.overrideUserInterfaceStyle = .dark
        } else {
            scenes?.windows.first?.overrideUserInterfaceStyle = .light
        }
    }
    
}


/**
 References
 - Setting dark mode: https://www.avanderlee.com/swift/dark-mode-support-ios/
 - Overriding UI style for the entire app: https://www.hackingwithswift.com/forums/swift/how-to-create-a-value-type-from-uiwindowscene/10485
 */
