//
//  TimerDurationPicker.swift
//  DeviceActivityMonitorDemo
//
//  Created by Itsuki on 2025/10/22.
//

import SwiftUI

struct TimerDurationPicker: View {
    @Binding var hour: Int
    @Binding var min: Int
    
    private let labelOffset = 40.0
    
    private var formatter: MeasurementFormatter {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.locale = Locale.current
        formatter.unitOptions = .providedUnit
        return formatter
    }
    
    var body: some View {
        HStack(spacing: 0) {
            componentPicker(unit: .hours, selection: $hour)
            componentPicker(unit: .minutes, selection: $min)
        }
        .pickerStyle(.wheel)

    }
    
    func title(_ unit: UnitDuration) -> String {
        return formatter.string(from: unit)
    }
    
    func range(_ unit: UnitDuration) -> Range<Int> {
        switch unit {
        case .hours:
            0..<24
        case .minutes:
            0..<60
        default:
            0..<0
        }
    }
    
    func componentPicker(unit: UnitDuration, selection: Binding<Int>) -> some View {
        
        return Picker("", selection: selection) {
            ForEach(range(unit), id: \.self) {
                Text("\($0)")
            }
        }
        .overlay {
            Text(title(unit))
                .font(.caption)
                .frame(width: labelOffset, alignment: .leading)
                .offset(x: labelOffset)
        }
    }
}
