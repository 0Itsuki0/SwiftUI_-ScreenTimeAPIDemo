//
//  DateComponents+Extensions.swift
//  DeviceActivityMonitorDemo
//
//  Created by Itsuki on 2025/10/23.
//

import Foundation

extension DateComponents {
    var withCalendarTimeZone: DateComponents {
        var new = self
        new.timeZone = .current
        new.calendar = .current
        return new
    }
}
