//
//  ActivityDetailView.swift
//  DeviceActivityMonitorDemo
//
//  Created by Itsuki on 2025/10/23.
//

import SwiftUI
import DeviceActivity

struct ActivityDetailView: View {
    @Environment(DeviceActivityManager.self) private var manager
    @Environment(\.dismiss) private var dismiss

    var activityName: String

    var body: some View {
        let events = manager.getEvents(activityName: activityName, details: false)
        let schedule = manager.getSchedule(activityName: activityName)

        List {
            if let schedule {
                Section("Schedule") {
                    if let start = schedule.intervalStart.withCalendarTimeZone.date {
                        HStack {
                            Text("Start")
                            Spacer()
                            Text(start, style: .date)
                            Text(start, style: .time)
                        }
                    }
                    
                    if let end = schedule.intervalEnd.withCalendarTimeZone.date {
                        HStack {
                            Text("End")
                            Spacer()
                            Text(end, style: .date)
                            Text(end, style: .time)
                        }
                    }
                    
                    HStack {
                        Text("Repeat")
                        Spacer()
                        Text(String("\(schedule.repeats)").capitalized)
                    }
                    
                    if let warningTime = schedule.warningTime {
                        let hour = warningTime.hour ?? 0
                        let min = warningTime.minute ?? 0
                        let second = warningTime.second ?? 0
                        let duration = TimeInterval.hms(hour, min, second)
                        
                        let formatted = duration.formattedString ?? duration.formattedDigits
                        HStack {
                            Text("Warning time")
                            Spacer()
                            Text(formatted)
                        }

                    }
                    
                }

            }
            
            Section("Events") {
                if events.isEmpty {
                    Text("No events added for the current monitor.")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                
                ForEach(Array(events.keys), id: \.rawValue) { eventName in
                    if let event: DeviceActivityEvent = events[eventName] {
                        VStack(alignment: .leading) {
                            Text(eventName.rawValue)
                                .fontWeight(.semibold)
                            
                            let hour = event.threshold.hour ?? 0
                            let min = event.threshold.minute ?? 0
                            let second = event.threshold.second ?? 0

                            let duration = TimeInterval.hms(hour, min, second)
                                
                            let formatted = duration.formattedString ?? duration.formattedDigits
                            HStack {
                                Text("Usage Threshold: ")
                                    .fontWeight(.semibold)
                                Text(formatted)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            
                            
                            Text(event.activityDescription)
                                .multilineTextAlignment(.leading)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                        }
                    }
                    
                }
                
            }
            
            
            Section {
                Button(action: {
                    self.manager.stopMonitor(activityName: activityName)
                    self.dismiss()
                }, label: {
                    Text("Remove Activity Monitor")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(ConcentricRectangle())
                })
                .buttonStyle(.borderless)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .listRowInsets(.all, 0)
                .listRowBackground(Color.red)

            }
        }
        .contentMargins(.top, 8)
        .navigationTitle(activityName)
        .navigationBarTitleDisplayMode(.large)
    }
}
