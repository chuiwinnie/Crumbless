//
//  SelectExpiryAlertDelegate.swift
//  FIT3178-Crumbless
//
//  Created by Winnie Chui on 24/5/2023.
//

import Foundation

protocol SelectExpiryAlertDelegate: AnyObject {
    var selectedExpiryAlertOption: String? { get set }
}
