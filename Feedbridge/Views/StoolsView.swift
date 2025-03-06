//
//  StoolsView.swift
//  Feedbridge
//
//  Created by Shreya D'Souza on 3/5/25.
//

import SwiftUI
import Charts
// swiftlint:disable closure_body_length
// swiftlint:disable type_body_length
struct StoolsView: View {
    @Environment(\.presentationMode) var presentationMode
    let entries: [StoolEntry]

    var body: some View {
        NavigationView {
            VStack {
                fullStoolChart
                stoolEntriesList
            }
            .navigationTitle("Stools")
        }
    }
    
//    StoolChart

    private var fullStoolChart: some View {
        Chart {
            ForEach(entries.sorted(by: { $0.dateTime < $1.dateTime })) { entry in
                BarMark(
                    x: .value("Date", entry.dateTime),
                    y: .value("Volume", stoolVolumeVal(entry.volume))
                )
                .foregroundStyle(stoolColor(entry.color))
            }
        }
        .chartYScale(domain: [0, 3]) // Set the Y-axis scale range from 0 to 3
        .frame(height: 300)
        .padding()
    }
    
    private func stoolVolumeVal(_ volume: StoolVolume) -> Int {
        switch volume {
        case .light: return 1
        case .medium: return 2
        case .heavy: return 3
        }
    }
    
    private func stoolColor(_ color: StoolColor) -> Color {
        switch color {
        case .black: return .black
        case .darkGreen: return .green
        case .green: return .mint
        case .brown: return .brown
        case .yellow: return .yellow
        case .beige: return .orange
        }
    }

    private var stoolEntriesList: some View {
        List(entries.sorted(by: { $0.dateTime > $1.dateTime })) { entry in
            VStack(alignment: .leading) {
                Text("\(entry.volume.rawValue.capitalized) and \(entry.color.rawValue.capitalized)")
                    .font(.headline)
                    .foregroundColor(.gray)
                Text(entry.dateTime, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

    

    private func stoolVolumeValue(_ volume: StoolVolume) -> Double {
        switch volume {
        case .light: return 1.0
        case .medium: return 2.0
        case .heavy: return 3.0
        }
    }
}

struct DailyAverageStoolVolume: Identifiable {
    let id = UUID()
    let date: Date
    let averageVolume: Double
}
