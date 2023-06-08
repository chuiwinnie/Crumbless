//
//  SelectDateFormatDelegate.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 7/6/2023.
//

import Foundation

// Delegate for selecting the preferred date format
protocol SelectDateFormatDelegate: AnyObject {
    var selectedDateFormatOption: String? {get set}
}
