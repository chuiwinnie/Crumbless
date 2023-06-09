//
//  UIViewController+formatDateTime.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 26/4/2023.
//

import Foundation
import UIKit

extension UIViewController {
    // Convert date to string
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = UserDefaults.standard.string(forKey: "dateFormat") ?? "dd-MM-yyyy"
        return dateFormatter.string(from: date)
    }
    
    // Convert string to date
    func stringToDate(dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = UserDefaults.standard.string(forKey: "dateFormat") ?? "dd-MM-yyyy"
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    // Convert time to string
    func timeToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
}


/**
 References
 - Date format options: https://auth0.com/blog/introduction-date-time-programming-swift-2/
 - Formatting time: https://stackoverflow.com/questions/61546387/how-to-get-only-time-from-date-in-swift
 */
