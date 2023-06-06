//
//  UIViewController+localNotifications.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 7/6/2023.
//

import Foundation
import UIKit

extension UIViewController {
    // Options for setting alert before expiry
    enum expiryAlertOptions: String {
        case none = "None"
        case oneDayBefore = "1 day before"
        case twoDaysBeofore = "2 days before"
        case threeDaysBefore = "3 days before"
        case oneWeekBefore = "1 week before"
        case twoWeeksBefore = "2 weeks before"
    }
    
    // Check if the alert is set before the expiry date
    func validateAlert(expiryDate: Date, alert: String) -> Bool {
        // Prevent setting alert for food expiring today
        let expiry = Calendar.current.dateComponents([.day, .year, .month], from: expiryDate)
        let today = Calendar.current.dateComponents([.day, .year, .month], from: Date())
        if expiry == today {
            return false
        }
        
        // Prevent setting alert on past date
        let daysBeforeExpiry = getDaysBeforeExpiry(expiryDate: expiryDate)
        let daysBeforeAlert = daysBeforeExpiry - getAlertDaysBeforeExpiry(alert: alert)
        if daysBeforeAlert < 0 {
            return false
        }
        return true
    }
    
    // Get the number of days remaining before food expiry
    func getDaysBeforeExpiry(expiryDate: Date) -> Int{
        let daysBeforeExpiry = (Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? -1) + 1
        return daysBeforeExpiry
    }
    
    // Get the number of days between the alert date and expiry date
    func getAlertDaysBeforeExpiry(alert: String) -> Int {
        var daysBeforeExpiry: Int
        switch alert {
        case expiryAlertOptions.oneDayBefore.rawValue:
            daysBeforeExpiry = 1
        case expiryAlertOptions.twoDaysBeofore.rawValue:
            daysBeforeExpiry = 2
        case expiryAlertOptions.threeDaysBefore.rawValue:
            daysBeforeExpiry = 3
        case expiryAlertOptions.oneWeekBefore.rawValue:
            daysBeforeExpiry = 7
        case expiryAlertOptions.twoWeeksBefore.rawValue:
            daysBeforeExpiry = 14
        default:
            daysBeforeExpiry = 0
        }
        return daysBeforeExpiry
    }
    
    func scheduleAlert(id: String, name: String, alert: String, expiryDate: Date) {
        let timeRemaining = getTimeRemaining(alert: alert)
        
        // Configure notification content
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Food Expiry Alert"
        notificationContent.body = "\(name) is expiring in \(timeRemaining)!"
        
        // Calculate the date for alert
        let daysBeforeExpiry = getDaysBeforeExpiry(expiryDate: expiryDate)
        let daysBeforeAlert = daysBeforeExpiry - getAlertDaysBeforeExpiry(alert: alert)
        let alertDate = Calendar.current.date(byAdding: .day, value: daysBeforeAlert, to: Date()) ?? Date()
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: alertDate)
        dateComponents.hour = 6
        dateComponents.minute = 32
        print("Alert for \(name) set for: \(dateComponents.year!)-\(dateComponents.month!)-\(dateComponents.day!) \(dateComponents.hour!):\(dateComponents.minute!)")
        
        // Schedule notification
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // Get the amount of time remaining before food expiry as a string
    func getTimeRemaining(alert: String) -> String {
        var timeRemaining: String
        switch alert {
        case expiryAlertOptions.oneDayBefore.rawValue:
            timeRemaining = "1 day"
        case expiryAlertOptions.twoDaysBeofore.rawValue:
            timeRemaining = "2 days"
        case expiryAlertOptions.threeDaysBefore.rawValue:
            timeRemaining = "3 days"
        case expiryAlertOptions.oneWeekBefore.rawValue:
            timeRemaining = "1 week"
        case expiryAlertOptions.twoWeeksBefore.rawValue:
            timeRemaining = "2 weeks"
        default:
            timeRemaining = "NA"
        }
        return timeRemaining
    }
    
    func cancelAlert(id: String) {
        // Cancel the local notification with the specified id
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}


/**
 References:
 - Scheduling local notification: https://www.hackingwithswift.com/books/ios-swiftui/scheduling-local-notifications
 - Scheduling local notification on a specific date: https://stackoverflow.com/questions/44632876/swift-3-how-to-set-up-local-notification-at-specific-date
 - Scheduling local notification at a specific time: https://stackoverflow.com/questions/52009454/how-do-i-send-local-notifications-at-a-specific-time-in-swift
 - Calculating date from now: https://www.appsdeveloperblog.com/add-days-months-or-years-to-current-date-in-swift/
 - Calculating difference between 2 dates: https://iostutorialjunction.com/2019/09/get-number-of-days-between-two-dates-swift.html
 - Converting Date to DateComponents: https://stackoverflow.com/questions/42042215/convert-date-to-datecomponents-in-function-to-schedule-local-notification-in-swi
 - Cancelling local notification: https://stackoverflow.com/questions/31951142/how-to-cancel-a-localnotification-with-the-press-of-a-button-in-swift
 */
