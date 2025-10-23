//
//  ContentView.swift
//  DeviceActivityMonitorDemo
//
//  Created by Itsuki on 2025/10/21.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @State private var manager = DeviceActivityManager()
    
    @ObservedObject private var center = AuthorizationCenter.shared
    
    var body: some View {
        Group {
            switch center.authorizationStatus {
            case .notDetermined:
                ContentUnavailableView(label: {
                    Label("Unknown Access", systemImage: "questionmark.app")
                }, description: {
                    Text("The app requires access to family control.")
                        .multilineTextAlignment(.center)
                }, actions: {
                    Button(action: {
                        Task {
                            await self.manager.requestFamilyControlAuthorization()
                        }
                    }, label: {
                        Text("request access")
                    })
                })

            case .denied:
                ContentUnavailableView(label: {
                    Label("Access Denied", systemImage: "xmark.square")
                }, description: {
                    Text("The app doesn't have permission to family control. Please grant the app access in Settings.")
                        .multilineTextAlignment(.center)
                })

            case .approved:
                MonitorView()
                    .environment(self.manager)
           
            @unknown default:
                ContentUnavailableView(label: {
                    Label("Unknown", systemImage: "ellipsis.rectangle")
                }, description: {
                    Text("Unknown authorization status.")
                        .multilineTextAlignment(.center)
                })
            }

        }
    }
}
