//
//  DeviceActivityManager.swift
//  DeviceActivityMonitorDemo
//
//  Created by Itsuki on 2025/10/22.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

@Observable
class DeviceActivityManager {
    
    var monitoringActivities: [String] = []
    
    private static let nameIdentifier = "itsuki.enjoy.DeviceActivityMonitorDemo"
    // A data store that stores settings to the current user or device.
    private let managedSettingsStore: ManagedSettingsStore = ManagedSettingsStore(named: .init(nameIdentifier))
    
    // A class that we use this to schedule monitoring within our main app,
    // and enables an application’s extension to start monitoring scheduled device activity.
    // * All instances are equivalent and manage the activities monitored by the application’s extension.
    private let deviceActivityCenter: DeviceActivityCenter = DeviceActivityCenter()
    
    private let eventName: DeviceActivityEvent.Name = DeviceActivityEvent.Name(rawValue: nameIdentifier)
    
    private let userDefaults: UserDefaults = UserDefaults(suiteName: "group.itsuki.enjoy.deviceActivityMonitor") ?? .standard
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()
    
    init() {
        monitoringActivities = deviceActivityCenter.activities.map({self.parseActivityName($0)})
    }
    
    func applyImmediateRestrictions(activitySelection: FamilyActivitySelection) {
        self.applyImmediateRestrictions(
            applicationTokens: activitySelection.applicationTokens,
            categoryTokens: activitySelection.categoryTokens,
            webDomainTokens: activitySelection.webDomainTokens
        )
    }
    
    func applyImmediateRestrictions(applicationTokens: Set<ApplicationToken>, categoryTokens: Set<ActivityCategoryToken>, webDomainTokens: Set<WebDomainToken>) {
        print(#function)
        managedSettingsStore.shield.applications = applicationTokens
        managedSettingsStore.shield.applicationCategories = .specific(categoryTokens)
        managedSettingsStore.shield.webDomains = webDomainTokens
    }
    
    
    func removeRestrictions() {
        print(#function)
        managedSettingsStore.shield.applications = nil
        managedSettingsStore.shield.applicationCategories = nil
        managedSettingsStore.shield.webDomains = nil
    }
    
    
    // If the specified applications, categories, and webDomains have been in use longer than the event’s `threshold` within the activity’s scheduled interval (start - end), we will shield those applications.
    func startMonitor(activitySelection: FamilyActivitySelection, shieldThreshold: TimeInterval, start: Date, end: Date, repeatDaily: Bool, activityName: String) throws {
        print(#function)
        let (start, end) = repeatDaily ? createRepeatDailySchedule(start: start, end: end) : createOneTimeSchedule(start: start, end: end)

        // The unique name of an activity.
        let deviceActivityName = makeActivityName(activityName)
        
        try self.saveSelection(activitySelection, activityName: deviceActivityName, eventName: self.eventName)

        let schedule = DeviceActivitySchedule(
            intervalStart: start,
            intervalEnd:end,
            repeats: true,
            warningTime: nil
        )
        
        // If our app didn’t specify any applications, categories, or webDomains,
        // the event includes all applications, categories, and web domains.
        //
        // BUG?: On Simulator, Threshold other than 0 not triggering DeviceActivityMonitor.eventDidReachThreshold
        let event = DeviceActivityEvent(
            applications: activitySelection.applicationTokens,
            categories: activitySelection.categoryTokens,
            webDomains: activitySelection.webDomainTokens,
            threshold: createThreshold(shieldThreshold),
            // For example, if your app calls startMonitoring(_:during:events:) at 1:30pm with a schedule of 1:00pm to 2:00pm,
            // then this boolean determines whether any activity between 1:00pm and 1:30pm will contribute to its threshold.
            includesPastActivity: true,
        )
        
        // If the app already monitored the activity, this method overwrites the previous schedule and events.
        // Attempting to monitor too many activities or activities that are too tightly scheduled can cause this method to throw an error.
        try self.deviceActivityCenter.startMonitoring(
            deviceActivityName,
            during: schedule,
            // If this parameter is empty,
            // the application extension only receives callbacks for the start and end times of the schedule’s interval.
            events: [
                eventName : event
            ]
        )
        
        self.monitoringActivities.append(activityName)
    }
    
    func stopMonitor(activityName: String) {
        print(#function)
        return self.stopMonitor(activityName: makeActivityName(activityName))
    }
    
    func stopMonitor(activityName: DeviceActivityName) {
        print(#function)
        
        let events = self.getEvents(activityName: activityName, details: false)
        events.keys.forEach({
            let key = makeUserDefaultsKey(activityName: activityName, eventName: $0)
            self.removeSavedSelection(key: key)
        })

        // If the array for the activity name is empty, ie: no activities are explicitly specified,
        // this method stops monitoring all activities.
        // Also, by calling this method, any shields (restrictions) applied for the activities (within the DeviceActivityMonitor extension) will be removed automatically
        self.deviceActivityCenter.stopMonitoring([activityName])
        self.monitoringActivities.removeAll(where: {$0 == parseActivityName(activityName)})
    }
    
    
    func getEvents(activityName: String, details: Bool) -> [DeviceActivityEvent.Name : DeviceActivityEvent] {
        return self.getEvents(activityName: makeActivityName(activityName), details: details)
    }
    
    func getEvents(activityName: DeviceActivityName, details: Bool) -> [DeviceActivityEvent.Name : DeviceActivityEvent] {
        // IMPORTANT:
        // the token-related fields for events returned with events(for:) will always be empty
        var events = self.deviceActivityCenter.events(for: activityName)
        print(events)
        if !details {
            return events
        }

        for (key, value) in events {
            let userDefaultsKey = self.makeUserDefaultsKey(activityName: activityName, eventName: key)
            let tokens = self.getSavedSelection(key: userDefaultsKey)
            events[key] = DeviceActivityEvent(
                applications: tokens.applicationTokens,
                categories: tokens.categoryTokens,
                webDomains: tokens.webDomainTokens,
                threshold: value.threshold, includesPastActivity: value.includesPastActivity
            )
        }
        
        return events
    }
    
    
    func getSchedule(activityName: String) -> DeviceActivitySchedule? {
        return self.getSchedule(activityName: makeActivityName(activityName))
    }
    
    func getSchedule(activityName: DeviceActivityName) -> DeviceActivitySchedule? {
        return self.deviceActivityCenter.schedule(for: activityName)
    }

}




// MARK: Permission
extension DeviceActivityManager {
    func requestFamilyControlAuthorization() async {
        let center = AuthorizationCenter.shared
        if center.authorizationStatus == .notDetermined {
            do {
                // to request authorization parental controls for FamilyControlsMember.child, use .child instead.
                try await center.requestAuthorization(for: .individual)
            } catch(let error) {
                print(error)
            }
        }
    }
}


// MARK: UserDefaults
extension DeviceActivityManager {
    private func getSavedSelection(key: String) -> FamilyActivitySelection {
        guard let data = userDefaults.data(forKey: key), let selection = try? self.jsonDecoder.decode(FamilyActivitySelection.self, from: data) else {
            return FamilyActivitySelection()
        }
        return selection
    }
    
    private func saveSelection(_ selection: FamilyActivitySelection, activityName: DeviceActivityName, eventName: DeviceActivityEvent.Name) throws {
        let data = try self.jsonEncoder.encode(selection)
        userDefaults.set(data, forKey: self.makeUserDefaultsKey(activityName: activityName, eventName: eventName))
    }
    
    
    private func removeSavedSelection(key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    private func makeUserDefaultsKey(activityName: DeviceActivityName, eventName: DeviceActivityEvent.Name) -> String {
        return "\(activityName.rawValue).\(eventName.rawValue)"
    }
}


// MARK: Helpers
extension DeviceActivityManager {
    
    private func makeActivityName(_ activityName: String) -> DeviceActivityName {
        return DeviceActivityName("\(DeviceActivityManager.nameIdentifier).\(activityName)")
    }
    
    private func parseActivityName(_ activityName: DeviceActivityName) -> String {
        return activityName.rawValue.replacing("\(DeviceActivityManager.nameIdentifier).", with: "")
    }
    
    
    private func createThreshold(_ threshold: TimeInterval) -> DateComponents {
        let (h, m, _) = threshold.hms
        var component = DateComponents()
        component.hour = h
        component.minute = m
        return component
    }
    
    private func createOneTimeSchedule(start: Date, end: Date) -> (DateComponents, DateComponents) {
        let start = Calendar.current.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour, .minute], from: start)
        let end = Calendar.current.dateComponents([.calendar, .timeZone, .year, .month, .day, .hour, .minute], from: end)
        return (start, end)
    }
    
    private func createRepeatDailySchedule(start: Date, end: Date) -> (DateComponents, DateComponents) {
        let start = Calendar.current.dateComponents([.calendar, .timeZone, .hour, .minute], from: start)
        let end = Calendar.current.dateComponents([.calendar, .timeZone, .hour, .minute], from: end)
        return (start, end)
    }
}
