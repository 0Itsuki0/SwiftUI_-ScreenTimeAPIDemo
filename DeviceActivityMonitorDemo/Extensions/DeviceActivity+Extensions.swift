//
//  DeviceActivity+Extensions.swift
//  DeviceActivityMonitorDemo
//
//  Created by Itsuki on 2025/10/23.
//

import DeviceActivity
import Foundation

extension DeviceActivityEvent {
    var activityDescription: String {
        if self.includesAllActivity {
            return "All Activities included"
        }
        return "\(self.applications.count) applications \n\(self.categories.count) categories \n\(self.webDomains.count) web domains"
    }
}

