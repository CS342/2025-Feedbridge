//
//  WeightChartView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import Charts
import SwiftUI
// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
struct WeightChart: View {
    let entries: [WeightEntry]

    var body: some View {
        Chart {
            ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                let day = Calendar.current.startOfDay(for: entry.dateTime)
                LineMark(
                    x: .value("Date", day),
                    y: .value("Weight (kg)", entry.asKilograms.value)
                )
                .foregroundStyle(.orange)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartPlotStyle { plotArea in
            plotArea.background(Color.clear)
        }
    }
}
