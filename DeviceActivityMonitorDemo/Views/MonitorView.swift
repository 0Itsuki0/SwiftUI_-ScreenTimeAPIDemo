//
//  MonitorView.swift
//  DeviceActivityMonitorDemo
//
//  Created by Itsuki on 2025/10/23.
//

import SwiftUI

struct MonitorView: View {
    @Environment(DeviceActivityManager.self) private var manager

    @State private var showAddActivityMonitorView: Bool = false
   
    var body: some View {

        NavigationStack {
            List {
                
                Section("Activity Monitors") {
                    if manager.monitoringActivities.isEmpty {
                        Text("No monitors added.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    ForEach(manager.monitoringActivities, id :\.self) { activity in
                        
                        NavigationLink(destination: {
                            ActivityDetailView(activityName: activity)
                                .environment(self.manager)
                        }, label: {
                            Text(activity)
                        })
                    }
                    .onDelete(perform: { indexSet in
                        self.deleteActivity(indexSet)
                    })
                    .navigationLinkIndicatorVisibility(.hidden)
                }
                
                Section {
                    Button(action: {
                        manager.removeRestrictions()
                    }, label: {
                        Text("Remove Any Restrictions")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(ConcentricRectangle())
                    })
                    .buttonStyle(.borderless)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .listRowInsets(.all, 0)
                    .listRowBackground(Color.blue)

                }
            }
            .contentMargins(.top, 8)
            .navigationTitle("Device Activity")
            .navigationBarTitleDisplayMode(.large)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(action: {
                        showAddActivityMonitorView = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                })
            })
            .sheet(isPresented: $showAddActivityMonitorView, content: {
                AddActivityMonitorView()
                    .environment(self.manager)
            })
        }
    }
    
    private func deleteActivity(_ indexSet: IndexSet) {
        let activities = indexSet.map({self.manager.monitoringActivities[$0]})
        for activity in activities {
            self.manager.stopMonitor(activityName: activity)
        }
    }
}
