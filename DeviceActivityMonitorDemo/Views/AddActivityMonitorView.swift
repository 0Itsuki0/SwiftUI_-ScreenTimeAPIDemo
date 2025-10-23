//
//  AddActivityMonitorView.swift
//  DeviceActivityMonitorDemo
//
//  Created by Itsuki on 2025/10/23.
//

import SwiftUI
import FamilyControls

struct AddActivityMonitorView: View {
    enum ScheduleType: Equatable {
        case oneTime
        case repeatDaily
    }
    
    @Environment(DeviceActivityManager.self) private var manager
    @Environment(\.dismiss) private var dismiss

    @State private var showActivitySelectionView: Bool = false
    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    
    @State private var useSchedule: Bool = false
    
    @State private var scheduleType: ScheduleType = .oneTime
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(24*60*60)
    
    @State private var activityName: String = "ItsukiTest"
    @State private var thresholdTimeMin: Int = 0
    @State private var thresholdTimeHour: Int = 0
    
    @State private var error: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        showActivitySelectionView = true
                    }, label: {
                        Text("Pick Activities")
                    })

                }
                
                Section {
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Schedule Monitor")
                            Text("When off, apply shields immediately.")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $useSchedule)
                    }
                    
                    if useSchedule {
                        HStack {
                            Text("Schedule Type")
                            
                            Spacer()
                            
                            Picker(selection: $scheduleType, content: {
                                Text("One Time")
                                    .tag(ScheduleType.oneTime)
                                Text("Repeat Daily")
                                    .tag(ScheduleType.repeatDaily)
                            }, label: {
                                
                            })
                        }
                        
                            
                        HStack {
                            Text("Start")
                            Spacer()
                            DatePicker("", selection: $startDate, displayedComponents: self.scheduleType == .oneTime ? [.hourAndMinute, .date] : [.hourAndMinute])
                        }
                        
                        HStack {
                            Text("End")
                            Spacer()
                            DatePicker("", selection: $endDate, displayedComponents: self.scheduleType == .oneTime ? [.hourAndMinute, .date] : [.hourAndMinute])
                        }
                        
                        HStack(spacing: 8) {
                            Text("Activity Name")
                            TextField("", text: $activityName)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.gray)

                        }
                        
                        HStack(spacing: 8) {
                            Text("Usage Time Threshold")
                            TimerDurationPicker(hour: $thresholdTimeHour, min: $thresholdTimeMin)
                        }
                        
                    }
                    
                }

                
                Section {
                    Button(action: {
                        if !self.useSchedule {
                            self.manager.applyImmediateRestrictions(activitySelection: self.activitySelection)
                            self.dismiss()
                            return
                        }
                        
                        let activityName = self.activityName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !activityName.isEmpty else {
                            self.error = "Empty Activity Name."
                            return
                        }
                        do {
                            try self.manager.startMonitor(activitySelection: self.activitySelection, shieldThreshold: .hms(self.thresholdTimeHour, self.thresholdTimeMin, 0), start: self.startDate, end: self.endDate, repeatDaily: self.scheduleType == .repeatDaily, activityName: activityName)
                            self.dismiss()
                        } catch(let error) {
                            self.error = error.localizedDescription
                        }
                    }, label: {
                        Text(self.useSchedule ? "Apply Shields" : "Add Monitor")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(ConcentricRectangle())
                    })
                    .buttonStyle(.borderless)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .listRowInsets(.all, 0)
                    .listRowBackground(Color.blue)

                }
                
                
                if let error {
                    Section {
                        Text(error)
                            .fontWeight(.semibold)
                            .foregroundStyle(.red)
                            .listRowBackground(Color.clear)
                    }
                    .listSectionSpacing(0)
                }
            }
            .contentMargins(.top, 8)
            .navigationTitle("Add Monitor")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showActivitySelectionView, content: {
                FamilyActivitySelectionView(selection: $activitySelection)
            })

        }

    }
}
